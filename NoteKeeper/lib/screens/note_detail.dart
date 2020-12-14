import 'package:flutter/material.dart';
import 'dart:async';
import 'package:NoteKeeper/models/note.dart';
import 'package:NoteKeeper/utils/database_helper.dart';
import 'package:intl/intl.dart';

class NoteDetail extends StatefulWidget{
  final String AppbarTitle;
  final Note note;

  NoteDetail(this.note,this.AppbarTitle);
  @override
  State<StatefulWidget> createState() {
    return NoteDetailState(this.note,this.AppbarTitle); 
  }
}

class NoteDetailState extends State<NoteDetail>{
  
  static var _priorities = ['High','Low'];
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();
  DatabaseHelper helper = DatabaseHelper();
  String appbarTitle;
  Note note;
  NoteDetailState(this.note,this.appbarTitle);
  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;
    titleController.text = note.title;
    descController.text = note.description;
    return Scaffold(
      appBar: AppBar(
        title: Text(appbarTitle),
      ),
      body: Padding(
        padding: EdgeInsets.only(top:15.0,left:10.0,right:10.0),
        child: ListView(
          children: <Widget>[

            // first element
            ListTile(
              title: DropdownButton(
                items: _priorities.map((String dropDownStringItem){
                  return DropdownMenuItem<String>(value: dropDownStringItem,child: Text(dropDownStringItem),);
                }).toList(),
                style: textStyle,
                value: getPriorityAsSttring(note.priority),
                onChanged: (valueSelected){
                  setState(() {
                   updatePriorityAsInt(valueSelected); 
                  });
                },
              ),
            ),
            
            // second element
            Padding(
              padding: EdgeInsets.only(top:15.0,bottom: 15.0),
              child: TextField(
                controller: titleController,
                style: textStyle,
                onChanged: (value){
                  updateTitle();
                },
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: textStyle,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0)
                  )
                ),
              ),
            ),

            // third element
            Padding(
              padding: EdgeInsets.only(top:15.0,bottom: 15.0),
              child: TextField(
                controller: descController,
                style: textStyle,
                onChanged: (value){
                  updateDesc();
                },
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: textStyle,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0)
                  )
                ),
              ),
            ),

            // fourth element

            Padding(
              padding: EdgeInsets.only(top:15.0,bottom: 15.0),
              child: Row(
                children: <Widget>[
                  // first button
                  Expanded(
                    child: RaisedButton(
                      color: Theme.of(context).primaryColorDark,
                      textColor: Theme.of(context).primaryColorLight,
                      child: Text('Save',textScaleFactor: 1.5,),
                      onPressed: (){
                        setState(() {
                          _save(); 
                        });
                      },
                    ),
                  ),

                  Container(width: 5.0,),

                  // second button
                  Expanded(
                    child: RaisedButton(
                      color: Theme.of(context).primaryColorDark,
                      textColor: Theme.of(context).primaryColorLight,
                      child: Text('Delete',textScaleFactor: 1.5,),
                      onPressed: (){
                        setState(() {
                          _delete(); 
                        });
                      },
                    ),
                  )

                ],
              ),
            )

          ],
        ),
      ),
    );
  }
  void updatePriorityAsInt(String value){
    switch(value){
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;     
    }
  }

  String getPriorityAsSttring(int value){
    switch(value){
      case 1:
        return _priorities[0];
        break;
      case 2:
        return _priorities[1];
        break;
    }
  }

  void updateTitle(){
    note.title = titleController.text;
  }

  void updateDesc(){
    note.description = descController.text;
  }

  void _save() async {
    MoveToLastScreen();
    note.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if(note.id != null){
      result = await helper.updateNote(note);
    }
    else{
      result = await helper.insertNote(note);
    }

    if(result != 0){
      _showAlertDialog('Status','Note Saved Successfully');
    }
    else{
      _showAlertDialog('Status','Problem Saving Note');
    }
  }

  void _delete() async {
    MoveToLastScreen();
    if(note.id == null){
      _showAlertDialog('Status', 'NO Note Was Deleted');
    }
    int result = await helper.deleteNote(note.id);
    if(result != 0){
      _showAlertDialog('Status', 'Note Deleted Successfully');
    }
    else{
      _showAlertDialog('Status', 'Error Occured while Deleting Note');
    }
  }

  void _showAlertDialog(String title,String msg){
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(msg),
    );
    showDialog(
      context: context,builder: (_)=>alertDialog
    );
  }

  void MoveToLastScreen(){
    Navigator.pop(context,true);
  }
}