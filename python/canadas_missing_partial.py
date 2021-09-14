'''
canadas_missing_old.py

IMPORTANT: Since the creation of canadas_missing_full.py, this script is now redundant. This script only retrieves
20 records, and should only be used if a small amount of data is needed for testing purposes. Note that this script
does not remove old records from the database, and may produce duplicate records.

This script retrieves data used by https://www.canadasmissing.ca/index-eng.htm, by accessing the json script used to
populate the page. This is used to retrieve real data for use in the application.

'''

import requests     #used to do a request to the page that produces the json
import json         #used to parse through the content
from datetime import datetime   #used to format the date

#imports for use with firebase
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore

#get credentials to connect with firebase
cred = credentials.Certificate('pythonServiceAccountKey.json')
firebase_admin.initialize_app(cred)

#connect to db and create an object that references the persons table
db = firestore.client()
ref = db.collection(u'persons')

#request to get the json
response = requests.get("https://www.services.rcmp-grc.gc.ca/missing-disparus/cases-en.json?cases=20")
print(response.status_code)

#parse json into list
data = json.loads(response.content)
persons = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20} #will store the data to insert

#for each item retrieved
for person in data["content"]:
    
    #build the record for each item retrieved
    #firebase accepts dictionaries as data items
    record = {
        'id': int(person['id']),
        'firstName': (person['title'].split(",",1)[1])[1:],
        'lastName': person['title'].split(",",1)[0],
        'image': 'https://www.services.rcmp-grc.gc.ca' + person['image'],
        'missingSince': datetime.strptime(person['missingSince'], '%Y-%m-%d'),
        'city': person['city'],
        'province': (person['province'])[:2]
    }

    #output data to console
    for key in record:
        print("%s: %s" %(key, record[key]))

    ref.add(record) #add current record to firebase