import 'dart:developer';
import 'package:NoteKeeper/screens/note_detail.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:NoteKeeper/models/note.dart';
import 'package:NoteKeeper/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class NoteList extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return NoteListState();
  }
}

class NoteListState extends State<NoteList>{
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> noteList;
  int count;

  @override
  Widget build(BuildContext context) {
    
    if(noteList == null){
      noteList = List<Note>();
      updateListView();
    }

    return WillPopScope(
      onWillPop: (){
        MoveToLastScreen();
      },
     child:  Scaffold(
      appBar: AppBar(
        title: Text('Total ${this.count} Notes',textDirection: TextDirection.ltr,),
        leading: IconButton(icon: Icon(Icons.arrow_back,),
        onPressed: (){
          MoveToLastScreen();
        },
      ),),

      body: getNoteListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          NavigateToNoteDetail(Note('','',2),'Add Note');
        },
        tooltip: 'Add Note',
        child: Icon(Icons.add),
      ),
    ));    
  }

  ListView getNoteListView(){
    TextStyle titleStyle = Theme.of(context).textTheme.subhead;
    return ListView.builder(
      itemCount: this.count,
      itemBuilder: (BuildContext context,int position){
        return Card(
          color: Colors.white,
          elevation: 2.0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: getPriorityColor(this.noteList[position].priority),
              child: getPriorityIcon(this.noteList[position].priority),
            ),
            title: Text(this.noteList[position].title, style: titleStyle,),
            subtitle: Text(this.noteList[position].description),
            trailing: GestureDetector(
              child: Icon(Icons.delete,color: Colors.grey),
              onTap: (){
                _delete(context, this.noteList[position]);
              },
            ),
            onTap: (){
              NavigateToNoteDetail(this.noteList[position],'Edit Note');        
            },
          ),
        );
      },
    );
  }

  void NavigateToNoteDetail(Note note,String title) async {
    bool result = await Navigator.push(context, MaterialPageRoute(builder: (context){
      return NoteDetail(note,title);
    }));
    if(result){
      updateListView();
    }
  }

  void MoveToLastScreen(){
    Navigator.pop(context);
  }

  Color getPriorityColor(int priority){
    switch(priority){
      case 1:
        return Colors.red;
        break;
      case 2:
        return Colors.yellow;
        break;
      default:
        return Colors.yellow;
    }
  }

  Icon getPriorityIcon(int priority){
    switch(priority){
      case 1:
        return Icon(Icons.play_arrow);
        break;
      case 2:
        return Icon(Icons.keyboard_arrow_right);
        break;
      default:
        return Icon(Icons.keyboard_arrow_right);
    }
  }

  void _delete(BuildContext context,Note note) async {
    int result = await databaseHelper.deleteNote(note.id);
    if(result != 0){
      _showSnackBar(context, 'Note Deleted Successfully');
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context,String msg){
    final snackBar = SnackBar(content: Text(msg));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void updateListView(){
    final Future<Database> dbFuture = databaseHelper.initilazeDatabase();
    dbFuture.then((database){

      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList){
        setState(() {
          this.noteList = noteList;
          this.count = noteList.length;
        });
      }); 
    
    });
  }

}