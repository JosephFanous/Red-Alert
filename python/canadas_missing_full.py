'''
canadasmissing.py

This script retrieves data used by https://www.canadasmissing.ca/index-eng.htm through web scraping.
It clears the current database, retrieves every record of missing persons on the site, and uploads
the new records.

This is the file that should be used to retrieve data, NOT canadas_missing_partial.py

geckodriver.exe is used by this file to open a Firefox browser for scraping

'''

#imports for firebase use
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore

#imports for selenium, a web scraping tool
from selenium import webdriver
from selenium.webdriver.common.keys import Keys

#python imports
import time     #time.sleep() is used to wait for page loading
from datetime import datetime   #used to format date

#this function takes the province and returns the code for it
#'--' is returned if the location provided is not within Canada
def getProvinceCode(province):
    if(province == "Ontario"):
        return "ON"
    elif(province == "British Columbia"):
        return "BC"
    elif(province == "Québec"):
        return "QC"
    elif(province == "Manitoba"):
        return "MB"
    elif(province == "Saskatchewan"):
        return "SK"
    elif(province == "Alberta"):
        return "AB"
    elif(province == "Yukon"):
        return "YK"
    elif(province == "Northwest Territories"):
        return "NT"
    elif(province == "Nunavut"):
        return "NU"
    elif(province == "Newfoundland &amp; Labrador"):
        return "NL"
    elif(province == "Nova Scotia"):
        return "NS"
    elif(province == "New Brunswick"):
        return "NB"
    elif(province == "Prince Edward Island"):
        return "PE"
    else:
        return "--"

#the site stores names in all upper case, so this function is used
#to restore the name to normal casing
def getCasedName(name):
    name = name.lower()
    return name.capitalize()

#get credentials to connect with firebase
cred = credentials.Certificate('pythonServiceAccountKey.json')
firebase_admin.initialize_app(cred)

#connect to db and create an object that references the persons table
db = firestore.client()
ref = db.collection(u'persons')
refAll = ref.stream()   #this is used to delete current items

#clear the current database by deleting all records in persons.
#I chose to wipe the database rather than performing updates to it because
#the scraper will return all records anyways, and it would also be hard to check
#for persons deleted from the site being scraped.
for item in refAll:
    print("%s deleted" %(item.id))
    item.reference.delete()

id = 1000   #starting id for the person being added
#this will probably need to be changed, there may be inconsistancies for saved persons
#because the id is arbitrary

#open a new instance of Firefox and navigate to the site
#this is how Selenium performs scraping
driver = webdriver.Firefox()
driver.get("https://www.services.rcmp-grc.gc.ca/missing-disparus/search-recherche.jsf")

#perform the correct selections to get missing persons from the search
elem = driver.find_element_by_id("selectall")
elem.click()
elem = driver.find_element_by_id("searchForm:mpaSearch")
elem.click()
elem = driver.find_element_by_id("searchForm:mpcSearch")
elem.click()

#find and click the form submit button
check = driver.find_element_by_name("searchForm:j_idt158")
check.click()

time.sleep(5)   #wait for the page to load

#while there is a next button on the page (aka, while there is another page to navigate to)
while(driver.find_element_by_xpath("//*[@rel='next']/ancestor::li[1]").get_attribute("class") != "disabled"):
    
    #use xpaths to find the required information
    #each list will end up being the same length - the number of people on the current page
    nameList = driver.find_elements_by_xpath("//figure/figcaption/h4/a")     #get all names on current page
    dateList = driver.find_elements_by_xpath("//figure/figcaption/p[2]")     #get all missingSince dates on current page
    locationList = driver.find_elements_by_xpath("//figure/figcaption/p[3]") #get all provinces/cities on current page
    imageList = driver.find_elements_by_xpath("//figure/div/a/img")          #get all images on the current page

    #for each person on the page
    for i in range(len(nameList)):
        #if there is no comma, the missing person is usually last seen in another country; skip these
        if(',' in locationList[i].get_attribute("innerHTML")):
            record = {
                #arbitrary id, starting at 1000 and incrementing
                'id': id,
                #get the first/last name from list, split at the comma and remove the leading space
                'firstName': (nameList[i].get_attribute("text").split(",",1)[1])[1:],
                #get the first/last name from list, split at the comma, get first value, and call getCasedName()
                'lastName': getCasedName(nameList[i].get_attribute("text").split(",",1)[0]),
                #get the image from src
                'image': imageList[i].get_attribute("src"),
                #get the date from innerHTML of list, split away the label and spaces, and format into datetime using strptime
                'missingSince': datetime.strptime(dateList[i].get_attribute("innerHTML").split(";",1)[1].strip(), "%B %d, %Y"),
                #get the city/province from innerHTML, split away the label and province
                'city': locationList[i].get_attribute("innerHTML").split(",",1)[0].split(";",1)[1].strip().replace("é", "e"),
                #get the city/province from innerHTML, split away the label and city, and call getProvinceCode()
                'province': getProvinceCode((locationList[i].get_attribute("innerHTML").strip().split(",",1)[1])[1:]),
            }
            id = id + 1 #add 1 to id for next record

            #print the record to console for debugging purposes
            for key in record:
                print("|%s: %s|" %(key, record[key]))

            #add the record to firebase
            ref.add(record)

    #click the button to move to the next page
    elem = driver.find_element_by_xpath("//*[@rel='next']")
    driver.execute_script("arguments[0].click();", elem)
    time.sleep(5)

print("--- Data Retrieval Complete ---")
driver.close()  #close the browser used by Selenium
