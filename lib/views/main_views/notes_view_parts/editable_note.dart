import 'package:api_client/models/note.dart';
import 'package:api_client/utils/api_utils.dart';
import 'package:api_client/views/main_views/notes_view.dart';
import 'package:flutter/material.dart';

class EditableNote extends StatefulWidget {
  const EditableNote({super.key, required this.note,
    required this.onDeleted, required this.onUpdated, required this.onLogicallyDeleted});

  final Note note;
  final Function(Note note) onDeleted;
  final Function(Note note) onLogicallyDeleted;
  final Function(Note note) onUpdated;

  @override
  State<EditableNote> createState() => _EditableNoteState();
}

class _EditableNoteState extends State<EditableNote> {

  NoteForm? form;
  bool isEditing = false;

  void switchEditMode() {
    form = NoteForm()
      ..name.text = widget.note.name
      ..text.text = widget.note.text
      ..categoryId = widget.note.category.id;

    setState(() { isEditing = true; }); 
  }
  void switchViewMode() {
    form = null;
    setState(() { isEditing = false; }); 
  }

  Widget _buildView(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.note.name, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 4),
        Text(widget.note.text, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 4),
        Text("[${widget.note.category.name}]", style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 4),
        Text("<${widget.note.user.name}>", textAlign: TextAlign.end, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 4),
        Text(widget.note.createdAt.toLocal().toString(), style: const TextStyle(fontSize: 16)),
        ...(widget.note.editedAt == null ? [] : [
          const SizedBox(height: 4),
          Text("(изменено: ${widget.note.editedAt!.toLocal()})", style: const TextStyle(fontSize: 16)),
        ]),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Expanded(child: ElevatedButton(onPressed: (){ switchEditMode(); }, style: const ButtonStyle(), child: const Text("Изменить"))),
          const SizedBox(width: 6),
          ...(widget.note.isDeleted ? [] : [Expanded(child: ElevatedButton(onPressed: () async {
            if (await ApiUtils.deleteNote(widget.note.id, forever: false) == null) {
              widget.onLogicallyDeleted(widget.note);
            }
          }, style: const ButtonStyle(), child: const Text("Скрыть"))),
          const SizedBox(width: 2)]),
          Expanded(child: ElevatedButton(onPressed: () async {
            if (await ApiUtils.deleteNote(widget.note.id) == null) {
              widget.onDeleted(widget.note);
            }
          }, style: const ButtonStyle(), child: const Text("Удалить")))
        ],)
      ],
    );
  }

  Widget _buildEdit(BuildContext context) {
    return Container(margin: const EdgeInsets.fromLTRB(10, 10, 10, 10), child: 
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Form(key: form!.formKey,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            TextFormField(
              controller: form!.name,
              validator: (value) {
                if (value == null || value.isEmpty) return "Пустое поле";
                return null;
              },           
              decoration: InputDecoration(
                isDense: true,
                labelText: "Название",
                border: const OutlineInputBorder(),
                suffixIcon: GestureDetector(onTap: () { form!.name.clear(); }, child: const Icon(Icons.clear))
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: form!.text,          
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
            ], onChanged: (int? i){ setState(() { if (i != null) form!.categoryId = i; }); })
          ]),
        ),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Expanded(child: ElevatedButton(onPressed: () async {
            
            if (!form!.formKey.currentState!.validate()) return;
            (await ApiUtils.updateNote(widget.note.id, form!.name.text,  form!.text.text, form!.categoryId))
            .fold((note) {
              setState(() {
                widget.note
                  ..name = note.name
                  ..text = note.text
                  ..createdAt = note.createdAt
                  ..editedAt = note.editedAt
                  ..isDeleted = note.isDeleted
                  ..user = note.user
                  ..category = note.category;

                widget.onUpdated(note); 

                form = null;
                isEditing = false; 
                //switchViewMode();
              });              
            }, (err) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err))));              
          }, style: const ButtonStyle(), child: const Text("Изменить"))),
          const SizedBox(width: 6),
          Expanded(child: ElevatedButton(onPressed: (){ switchViewMode(); }, style: const ButtonStyle(), child: const Text("Отмена")))
        ],)
      ])
    );
  }

  @override
  Widget build(BuildContext context) => !isEditing ? _buildView(context) : _buildEdit(context);
}