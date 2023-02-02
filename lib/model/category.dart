import 'package:conduit/conduit.dart';
import 'package:webapp/model/note.dart';

class Category extends ManagedObject<_Category> implements _Category {}

@Table(name: "categories", useSnakeCaseColumnName: true)
class _Category {
  _Category({this.id = 0, this.name = ""});

  @Column(primaryKey: true) int? id;
  @Column() String name;

  ManagedSet<Note>? notes;
}