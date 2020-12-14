import 'package:NoteKeeper/models/note.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper{
  static DatabaseHelper _databaseHelper;
  static Database _database;
  String noteTable = 'note_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colDate = 'date';
  String colPriority = 'priority';

  DatabaseHelper._createInstance();
  
  factory DatabaseHelper(){
    if(_databaseHelper == null){
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper;
  }

  void _createDb(Database db,int newVersion) async {
    await db.execute('CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT,$colTitle TEXT,$colDescription TEXT,$colPriority INTEGER,$colDate TEXT)');
  }

  Future<Database> get database async {
    if(_database == null){
      _database = await initilazeDatabase();
    }
    return _database;
  }

  Future<Database> initilazeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path+'notes.db';
    return await openDatabase(path,version:1,onCreate: _createDb);  
  }

  // fetch data
  Future<List<Map<String,dynamic>>> getNoteMapList() async {
    Database db = await this.database;
    //var result = await db.rawQuery('SELECT * FROM  $noteTable order by $colPriority ASC');
    var result = await db.query(noteTable,orderBy: '$colPriority ASC');
    return result;
  }

  // insert data
  Future<int> insertNote(Note note) async {
    Database db = await this.database;
    var result = await db.insert(noteTable, note.toMap());
    return result;
  }

  // update date
  Future<int> updateNote(Note note) async{
    Database db = await this.database;
    var result = await db.update(noteTable, note.toMap(),where: '$colId = ?',whereArgs: [note.id]);
    return result;
  }

  // delete data
  Future<int> deleteNote(int id) async {
    Database db = await this.database;
    var result = await db.rawDelete('DELETE FROM $noteTable WHERE $colId = $id');
    return result;
  }

  // number of note object in database
  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String,dynamic>> x = await db.rawQuery('SELECT COUNT (*) FROM $noteTable');
    int result = Sqflite.firstIntValue(x);
    return  result;
  }

  // get map list (map<list>)  and  convert to note list (list<note>)
  Future<List<Note>> getNoteList() async {
    var noteMapList  = await getNoteMapList();
    int count = noteMapList.length;

    List<Note> noteList = List<Note>();
    for(int i = 0; i < count; i++){
      noteList.add(Note.fromMapObject(noteMapList[i]));
    }
    return noteList;
  }
}