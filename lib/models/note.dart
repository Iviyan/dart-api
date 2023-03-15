import 'package:api_client/models/category.dart';
import 'package:api_client/models/user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'note.freezed.dart';
part 'note.g.dart';

@Freezed(addImplicitFinal: false)
class Note with _$Note{
  factory Note({
    required int id,
    required String name,
    required String text,
    required DateTime createdAt,
    required DateTime? editedAt,
    required bool isDeleted,
    required User user,
    required Category category,
  }) = _Note;

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);
}