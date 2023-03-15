import 'package:api_client/models/note.dart';
import 'package:api_client/utils/api_utils.dart';
import 'package:api_client/views/main_views/notes_view.dart';
import 'package:flutter/material.dart';

class NewNote extends StatefulWidget {
  const NewNote({super.key, required this.onCreateNote});

  final Function(Note note) onCreateNote;

  @override
  State<NewNote> createState() => _NewNoteState();
}

class _NewNoteState extends State<NewNote> {

  NoteForm form = NoteForm();
  bool isEditing = false;


  Widget _buildEdit(BuildContext context) {
    return Container(margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),  child: 
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Form(key: form.formKey,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            TextFormField(
              controller: form.name,
              validator: (value) {
                if (value == null || value.isEmpty) return "Пустое поле";
                return null;
              },           
              decoration: InputDecoration(
                isDense: true,
                labelText: "Название",
                border: const OutlineInputBorder(),
                suffixIcon: GestureDetector(onTap: () { form.name.clear(); }, child: const Icon(Icons.clear))
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: form.text,          
              decoration: InputDecoration(
                isDense: true,
                labelText: "Текст",
                border: const OutlineInputBorder(),
                suffixIcon: GestureDetector(onTap: () { form!.text.clear(); }, child: const Icon(Icons.clear))
              ),
            ),
            const SizedBox(height: 6),
            DropdownButton<int>(value: form!.categoryId, isExpanded: true, items: const [
              DropdownMenuItem(value: 1, child: Text("Покупки")),
              DropdownMenuItem(value: 2, child: Text("Задачи")),
            ], onChanged: (int? i){ setState(() { if (i != null) form.categoryId = i; }); })
          ]),
        ),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Expanded(child: ElevatedButton(onPressed: () async {
            if (!form.formKey.currentState!.validate()) return;
            (await ApiUtils.createNote(form.name.text,  form.text.text, form.categoryId))
            .fold((note) {
              setState(() {
                isEditing = false; 
                form.clear();
              });              
              widget.onCreateNote(note);
            }, (err) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err))));              
          }, style: const ButtonStyle(), child: const Text("Добавить"))),
          const SizedBox(width: 6),
          Expanded(child: ElevatedButton(onPressed: (){ setState(() { isEditing = false; }); }, style: const ButtonStyle(), child: const Text("Отмена")))
        ],)
      ])
    );
  }

  @override
  Widget build(BuildContext context) => !isEditing 
    ? ElevatedButton(onPressed: () { setState(() { isEditing = true; }); }, child: const Text("Добавить"))
    : _buildEdit(context);
}
