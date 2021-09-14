import 'package:flutter/material.dart';

class SearchForm extends StatelessWidget {
  final _formKey;
  final name;

  SearchForm(this._formKey, this.name);

  @override
  Widget build(BuildContext context) {
    return searchForm();
  }

  Widget searchForm() => Form(
    key: _formKey,
    child: Container(
      width: 300,
      margin: EdgeInsets.only(left: 25, right: 25),
      child: TextFormField(
        decoration: const InputDecoration(
          prefixIcon: Icon(
            Icons.person,
            color: Colors.grey,
          ),
          hintText: 'John Smith',
          hintStyle: TextStyle(color: Colors.grey),
          labelText: 'Name',
          labelStyle: TextStyle(color: Colors.grey),
          contentPadding: EdgeInsets.symmetric(horizontal: 20),
          border: OutlineInputBorder(),
        ),
        style: TextStyle(
          color: Colors.grey,
        ),
        onSaved: (String value) => name.fullName = value,
      ),
    )
  );
}
