// ignore_for_file: unused_element

import 'package:conduit/conduit.dart';
import 'package:conduit_open_api/src/v3/schema.dart';
import 'package:conduit_common/src/openapi/documentable.dart';
import 'package:webapp/model/category.dart';
import 'package:webapp/model/user.dart';

class Note extends ManagedObject<_Note> implements _Note {}

@Table(name: "notes", useSnakeCaseColumnName: true)
class _Note { 
  _Note({this.id = 0, this.name = "", this.text = "",
   // ignore: always_put_required_named_parameters_first
   required this.createdAt, this.editedAt, this.isDeleted = false
   });

  @Column(primaryKey: true) int? id;
  @Column() String? name;
  @Column() String? text;
  @Relate(#notes)
  Category? category;
  @Relate(#notes)
  User? user;
  @Column() DateTime? createdAt;
  @Column(nullable: true) DateTime? editedAt;
  @Column() bool? isDeleted;
}

class NewNote implements Serializable {
  NewNote({this.name = "", this.text = "", this.categoryId = 0});

  String? name;
  String? text;
  int categoryId;

  @override
  Map<String, dynamic>? asMap() => {"name": name, "text": text, "categoryId": categoryId};

  @override APISchemaObject documentSchema(APIDocumentContext context) => throw UnimplementedError();
  @override void read(Map<String, dynamic> object, {Iterable<String>? accept, Iterable<String>? ignore, Iterable<String>? reject, Iterable<String>? require}) => readFromMap(object);

  @override
  void readFromMap(Map<String, dynamic> object) {
    text = object["text"] as String?;
    name = object["name"] as String?;
    categoryId = object["categoryId"] as int;
  }  
}


class NoteHistoryRecord extends ManagedObject<_NoteHistoryRecord> implements _NoteHistoryRecord {}

@Table(name: "notes_history", useSnakeCaseColumnName: true)
class _NoteHistoryRecord { 
  _NoteHistoryRecord(this.text, {this.createdAt});

  @Column(primaryKey: true) DateTime? createdAt = DateTime.now();
  @Column() String? text;
}