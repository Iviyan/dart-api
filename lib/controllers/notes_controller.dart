import 'package:webapp/model/category.dart';
import 'package:webapp/model/note.dart';
import 'package:webapp/model/user.dart';
import 'package:webapp/utils/app_response.dart';

import '../webapp.dart';

class NotesController extends ResourceController {
  NotesController(this.managedContext);

  final ManagedContext managedContext;

  @Operation.post()
  Future<Response> createNote(@Bind.body(require: ["name", "text" , "category"]) NewNote newNote) async {
    try {
      final User user = User(); user.id = request!.attachments["userId"] as int;
      final Category category = Category(); category.id = newNote.categoryId;
      final qCreateNote = Query<Note>(managedContext)
        ..values.name = newNote.name
        ..values.text = newNote.text
        ..values.category = category
        ..values.user = user
        ..values.createdAt = DateTime.now().toUtc()
      ;

      final note = await qCreateNote.insert(); 

      await log("Note ${note.id} was created");

      return getNote(note.id!);
    } on QueryException catch (e) {
      return AppResponse.serverError(e, message: 'Error creating a note');
    }
  }

  @Operation.get()
  Future<Response> getNotes({
    @Bind.query("name") String? name,
    @Bind.query("include_deleted") String? includeDeleted,
    @Bind.query("count") int count = 0,
    @Bind.query("last_id") int lastId = 0
  }) async {
    try {
      final qNote = Query<Note>(managedContext)
        ..sortBy((x) => x.id, QuerySortOrder.ascending)
        ..where((x) => x.id).greaterThan(lastId)
        ..fetchLimit = count
        ..join(object: (x) => x.user)
          .returningProperties((x) => [x.id, x.login, x.name])
        ..join(object: (x) => x.category);

      if (name != null)
        qNote.where((x) => x.name).contains(name, caseSensitive: false);

      if (includeDeleted != "true" && includeDeleted != "1")
        qNote.where((x) => x.isDeleted).equalTo(false);
      
      final notes = await qNote.fetch(); 

      return Response.ok(notes.map((n) => n.asResponse()).toList());
    } on QueryException catch (e) {
      return AppResponse.serverError(e);
    }
  }
  
  @Operation.get("id")
  Future<Response> getNote(@Bind.path("id") int id) async {
    try {
      final qNote = Query<Note>(managedContext)
        ..where((x) => x.id).equalTo(id)
        ..join(object: (x) => x.user)
          .returningProperties((x) => [x.id, x.login, x.name])
        ..join(object: (x) => x.category);
      final note = await qNote.fetchOne();

      return note != null ? Response.ok(note.asResponse()) : AppResponse.notFound();
    } on QueryException catch (e) {
      return AppResponse.serverError(e);
    }
  }

  @Operation.put("id")
  Future<Response> updateNote(
    @Bind.path("id") int id,
    @Bind.body() NewNote newNote
  ) async {
    final userId = request!.attachments["userId"] as int;

    try {
      final note = await (Query<Note>(managedContext)
        ..where((x) => x.id).equalTo(id)
        ..returningProperties((x) => [x.user])
      ).fetchOne();

      if (note == null) return AppResponse.notFound(title: "Not found");
      if (note.user!.id != userId) return AppResponse.forbidden(title: "You can edit only your notes");

      final Category category = Category(); category.id = newNote.categoryId;
      final qCreateNote = Query<Note>(managedContext)
        ..where((x) => x.id).equalTo(id)
        ..values.name = newNote.name
        ..values.text = newNote.text
        ..values.category = category
      ;

      final updatedNote = (await qCreateNote.update())[0]; 
      //final updatedNote = updatedNotes.isNotEmpty ? updatedNotes[0] : null;

      await log("Note $id was updated");

      return getNote(id);
    } on QueryException catch (e) {
      return AppResponse.serverError(e, message: 'Error updating a note');
    }
  }

  @Operation.delete("id")
  Future<Response> deleteNote(
    @Bind.path("id") int id,
    {@Bind.query("forever") String? forever}
  ) async {
    final userId = request!.attachments["userId"] as int;

    try {
      final note = await (Query<Note>(managedContext)
        ..where((x) => x.id).equalTo(id)
        ..returningProperties((x) => [x.user])
      ).fetchOne();

      if (note == null) return AppResponse.notFound(title: "Not found");
      if (note.user!.id != userId) return AppResponse.forbidden(title: "You can delete only your notes");

      final qNoteAction = Query<Note>(managedContext)
        ..where((x) => x.id).equalTo(id);
      if (forever == "true" || forever == "1") {
        await qNoteAction.delete(); 

        await log("Note $id was deleted");
      } else {
        qNoteAction.values.isDeleted = true;
        await qNoteAction.updateOne();

        await log("Note $id was marked as deleted");
      }
      return Response.ok({});
    } on QueryException catch (e) {
      return AppResponse.serverError(e, message: 'Error deleting a note');
    }
  }

  @Operation.post("id")
  Future<Response> restoreNote(@Bind.path("id") int id) async {
    final userId = request!.attachments["userId"] as int;

    try {
      final note = await (Query<Note>(managedContext)
        ..where((x) => x.id).equalTo(id)
        ..returningProperties((x) => [x.user, x.isDeleted])
      ).fetchOne();

      if (note == null) return AppResponse.notFound(title: "Not found");
      if (note.user!.id != userId) return AppResponse.forbidden(title: "You can respore only your notes");
      if (note.isDeleted == false) return AppResponse.badRequest(title: "Note not deleted");

      final qNoteAction = Query<Note>(managedContext)
        ..where((x) => x.id).equalTo(id)
        ..values.isDeleted = false;
      final restoredNote = await qNoteAction.updateOne();

      await log("Note $id was restored");
      
      return Response.ok(restoredNote?.asResponse());
    } on QueryException catch (e) {
      return AppResponse.serverError(e, message: 'Error restoring a note');
    }
  }

  Future log(String text) => (Query<NoteHistoryRecord>(managedContext)..values.text = text).insert();
}