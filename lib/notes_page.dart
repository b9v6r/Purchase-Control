import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'note.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  List<Note> notes = [];
  final contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  void addNote() {
    final String content = contentController.text;

    if (content.isNotEmpty) {
      setState(() {
        notes.add(Note(
          content: content,
        ));
      });

      contentController.clear();
      saveNotes();
    }
  }

  void exitApp() {
    SystemNavigator.pop();
  }

  void btnAuthor() async {
    final Uri url = Uri.parse('https://taplink.cc/b9v6r');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Не удалось открыть $url';
    }
  }

  void deleteNote(int index) {
    setState(() {
      notes.removeAt(index);
    });
    saveNotes();
  }

  Future<void> saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = json.encode(
      notes.map((note) => note.toMap()).toList(),
    );
    await prefs.setString('notes', encodedData);
  }

  Future<void> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString('notes');
    if (encodedData != null) {
      setState(() {
        notes = (json.decode(encodedData) as List<dynamic>)
            .map<Note>((item) => Note.fromMap(item))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Покупки'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 255, 245, 160),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: contentController,
              decoration: const InputDecoration(hintText: 'Покупка'),
            ),
          ),
          ElevatedButton(
            onPressed: addNote,
            child: const Text('Добавить покупку'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: btnAuthor,
            child: const Text('Автор'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: exitApp,
            child: const Text('Выход'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(notes[index].content),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => deleteNote(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
