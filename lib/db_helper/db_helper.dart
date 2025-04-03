import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:notes_app/modal_class/notes.dart';
import 'package:notes_app/modal_class/attachment.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class DatabaseHelper {
  static DatabaseHelper? _databaseHelper; // Singleton DatabaseHelper
  static Database? _database; // Singleton Database

  // Table names
  String noteTable = 'note_table';
  String attachmentTable = 'attachment_table';

  // Note table columns
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colPriority = 'priority';
  String colColor = 'color';
  String colDate = 'date';

  // Attachment table columns
  String colAttachmentId = 'attachment_id';
  String colNoteId = 'note_id';
  String colFilePath = 'file_path';
  String colFileName = 'file_name';
  String colFileType = 'file_type';
  String colFileSize = 'file_size';
  String colCreatedAt = 'created_at';

  // Database version - increment when schema changes
  int dbVersion = 2;

  DatabaseHelper._createInstance(); // Named constructor to create instance of DatabaseHelper

  factory DatabaseHelper() {
    _databaseHelper ??= DatabaseHelper._createInstance();
    return _databaseHelper!;
  }

  Future<Database> get database async {
    _database ??= await initializeDatabase();
    return _database!;
  }

  Future<Database> initializeDatabase() async {
    // Get the directory path for both Android and iOS to store database.
    Directory directory = await getApplicationDocumentsDirectory();
    String path = '${directory.path}/notes.db';
    print('Database path: $path');

    // Open/create the database at a given path
    var notesDatabase = await openDatabase(path,
        version: dbVersion, onCreate: _createDb, onUpgrade: _onUpgrade);
    return notesDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    // Create note table
    await db.execute(
        'CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, '
        '$colDescription TEXT, $colPriority INTEGER, $colColor INTEGER, $colDate TEXT)');

    // Create attachment table
    await db.execute(
        'CREATE TABLE $attachmentTable($colAttachmentId INTEGER PRIMARY KEY AUTOINCREMENT, '
        '$colNoteId INTEGER, $colFilePath TEXT, $colFileName TEXT, $colFileType TEXT, '
        '$colFileSize INTEGER, $colCreatedAt TEXT, '
        'FOREIGN KEY($colNoteId) REFERENCES $noteTable($colId) ON DELETE CASCADE)');
  }

  // Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add attachment table if upgrading from version 1
      await db.execute(
          'CREATE TABLE $attachmentTable($colAttachmentId INTEGER PRIMARY KEY AUTOINCREMENT, '
          '$colNoteId INTEGER, $colFilePath TEXT, $colFileName TEXT, $colFileType TEXT, '
          '$colFileSize INTEGER, $colCreatedAt TEXT, '
          'FOREIGN KEY($colNoteId) REFERENCES $noteTable($colId) ON DELETE CASCADE)');

      // Enable foreign key support
      await db.execute('PRAGMA foreign_keys = ON');
    }
  }

  // Fetch Operation: Get all note objects from database
  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await database;
    var result = await db.query(noteTable, orderBy: '$colPriority ASC');
    return result;
  }

  // Insert Operation: Insert a Note object to database
  Future<int> insertNote(Note note) async {
    Database db = await database;
    var result = await db.insert(noteTable, note.toMap());
    return result;
  }

  // Update Operation: Update a Note object and save it to database
  Future<int> updateNote(Note note) async {
    var db = await database;
    var result = await db.update(noteTable, note.toMap(),
        where: '$colId = ?', whereArgs: [note.id]);
    return result;
  }

  // Delete Operation: Delete a Note object from database
  Future<int> deleteNote(int id) async {
    var db = await database;
    int result =
        await db.rawDelete('DELETE FROM $noteTable WHERE $colId = $id');
    return result;
  }

  // Get number of Note objects in database
  Future<int> getCount() async {
    Database db = await database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $noteTable');
    int result = Sqflite.firstIntValue(x) ?? 0;
    return result;
  }

  // Get the 'Map List' [ List<Map> ] and convert it to 'Note List' [ List<Note> ]
  Future<List<Note>> getNoteList() async {
    var noteMapList = await getNoteMapList(); // Get 'Map List' from database
    int count =
        noteMapList.length; // Count the number of map entries in db table

    List<Note> noteList = [];
    // For loop to create a 'Note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      noteList.add(Note.fromMapObject(noteMapList[i]));
    }

    return noteList;
  }

  // ATTACHMENT OPERATIONS

  // Add new attachment to a note
  Future<int> insertAttachment(Attachment attachment) async {
    Database db = await database;
    var result = await db.insert(attachmentTable, attachment.toMap());
    return result;
  }

  // Get all attachments for a specific note
  Future<List<Attachment>> getAttachmentsForNote(int noteId) async {
    Database db = await database;
    var result = await db.query(attachmentTable,
        where: '$colNoteId = ?',
        whereArgs: [noteId],
        orderBy: '$colCreatedAt DESC');

    List<Attachment> attachments = [];
    for (var item in result) {
      attachments.add(Attachment.fromMapObject(item));
    }

    return attachments;
  }

  // Delete a specific attachment
  Future<int> deleteAttachment(int attachmentId) async {
    var db = await database;
    int result = await db.delete(attachmentTable,
        where: '$colAttachmentId = ?', whereArgs: [attachmentId]);
    return result;
  }

  // Delete all attachments for a note
  Future<int> deleteAllAttachmentsForNote(int noteId) async {
    var db = await database;
    int result = await db
        .delete(attachmentTable, where: '$colNoteId = ?', whereArgs: [noteId]);
    return result;
  }

  // Get note with its attachments
  Future<Map<String, dynamic>> getNoteWithAttachments(int noteId) async {
    var db = await database;
    var noteResult =
        await db.query(noteTable, where: '$colId = ?', whereArgs: [noteId]);

    if (noteResult.isEmpty) {
      return {};
    }

    var note = Note.fromMapObject(noteResult.first);
    var attachments = await getAttachmentsForNote(noteId);

    return {'note': note, 'attachments': attachments};
  }
}
