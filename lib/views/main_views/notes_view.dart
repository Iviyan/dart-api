import 'package:api_client/models/note.dart';
import 'package:api_client/utils/api_utils.dart';
import 'package:api_client/views/main_views/notes_view_parts/editable_note.dart';
import 'package:api_client/views/main_views/notes_view_parts/new_note.dart';
import 'package:flutter/material.dart';

RegExp nameRegExp = RegExp(r'^[a-zа-яё]{1,30}$', caseSensitive: false, multiLine: false);

class _NotesViewState extends State<NotesView> {

  TextEditingController search = TextEditingController();
  bool includeDeleted = false;

  late Future<List<Note>> notes;

  @override
  void initState() {
    super.initState();

    notes = initNotes();
  }

  Future<List<Note>> initNotes() async {
    final notes = await ApiUtils.getNotes(name: search.text == "" ? null : search.text, includeDeleted: includeDeleted);
    return notes.fold((res) => res, (err) => throw err);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(
      child: FutureBuilder<List<Note>>(
        initialData: null,
        future: notes,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) return const Text("Загрузка...");
          if (snapshot.hasError) return Text("Ошибка загрузки\n${snapshot.error.toString()}");
          return SingleChildScrollView(child: Column(children: [
            Container(
                decoration: BoxDecoration(border: Border.all()),
                width: double.infinity,
                padding: const EdgeInsets.all(4),
                margin: const EdgeInsets.all(4),
                child: NewNote(onCreateNote: (note) { setState(() {
                  snapshot.data!.add(note);
                }); })
            ),
            Container(
                decoration: BoxDecoration(border: Border.all()),
                width: double.infinity,
                padding: const EdgeInsets.all(4),
                margin: const EdgeInsets.all(4),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: TextField(controller: search,
                      decoration: InputDecoration(
                        isDense: true,
                        labelText: "Название",
                        border: const OutlineInputBorder(),
                        suffixIcon: GestureDetector(onTap: () { search.clear(); }, child: const Icon(Icons.clear))
                      ))
                    ),
                    const SizedBox(width: 6),
                    ElevatedButton(onPressed: (){ setState(() {
                      notes = initNotes();
                    }); }, child: const Text("Поиск"))
                  ]),
                  const SizedBox(height: 6),
                  Row(children: [
                    Checkbox(value: includeDeleted, onChanged: (value) { 
                      setState(() {
                       includeDeleted = value ?? false;
                       notes = initNotes();
                      }); 
                    }),
                    const Text("Показывать срытые")
                  ])
                ]),
            ),
            ...snapshot.data!.map((n) => 
              Container(
                decoration: BoxDecoration(border: Border.all()),
                width: double.infinity,
                padding: const EdgeInsets.all(4),
                margin: const EdgeInsets.all(4),
                child: EditableNote(note: n,
                  onDeleted: (note) {
                    setState(() { snapshot.data!.remove(note); }); 
                  },
                  onLogicallyDeleted: (note) {
                    if (!includeDeleted) {
                      setState(() { snapshot.data!.remove(note); });
                    } 
                  },
                  onUpdated: (note) {})
                )
            ).toList()
          ]));
        },)
    ));
  }
}

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @protected
  @override
  State<StatefulWidget> createState() => _NotesViewState();
}

class NoteForm {
  TextEditingController name = TextEditingController();
  TextEditingController text = TextEditingController();
  int categoryId = 1;

  final GlobalKey<FormState> formKey = GlobalKey();

  void clear() {
    name.clear();
    text.clear();
    categoryId = 1;
  }
}