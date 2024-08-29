import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' as io;

class Note {
  final String content;

  Note({
    required this.content,
  });

  Map<String, dynamic> toMap() {
    return {
      'content': content,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      content: map['content'] ?? '',
    );
  }
}

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Контроль покупок',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const NotesPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  List<Note> notes = [];
  final contentController = TextEditingController();
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    loadNotes();
    loadThemeMode(); // Загрузка темы при инициализации
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
    if (io.Platform.isWindows) {
      io.exit(0);
    } else {
      SystemNavigator.pop();
    }
  }

  void btnAuthor() async {
    final Uri url = Uri.parse('https://taplink.cc/b9v6r');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Не удалось открыть сайт';
    }
  }

  void deleteNote(int index) {
    setState(() {
      notes.removeAt(index);
    });
    saveNotes();
  }

  void _toggleTheme() async {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', _themeMode == ThemeMode.dark);
  }

  Future<void> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? false;
    setState(() {
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
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
    return MaterialApp(
      title: 'Theme Switcher',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,
      home: MyHomePage(
          toggleTheme: _toggleTheme,
          contentController: contentController,
          notes: notes,
          addNote: addNote,
          btnAuthor: btnAuthor,
          exitApp: exitApp,
          deleteNote: deleteNote),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final VoidCallback toggleTheme;
  final TextEditingController contentController;
  final List<Note> notes;
  final VoidCallback addNote;
  final VoidCallback btnAuthor;
  final VoidCallback exitApp;
  final Function(int) deleteNote;

  const MyHomePage({
    super.key,
    required this.toggleTheme,
    required this.contentController,
    required this.notes,
    required this.addNote,
    required this.btnAuthor,
    required this.exitApp,
    required this.deleteNote,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Покупки'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 255, 245, 160),
        foregroundColor: const Color.fromARGB(255, 0, 0, 0),
        leading: IconButton(
          icon: const Icon(Icons.brightness_6),
          onPressed: toggleTheme,
        ),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 155, 252, 130),
                foregroundColor: const Color.fromARGB(255, 0, 0, 0),
              ),
              child: const Text('Добавить покупку')),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: btnAuthor,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 162, 223, 251),
              foregroundColor: const Color.fromARGB(255, 0, 0, 0),
            ),
            child: const Text('Автор'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: exitApp,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 255, 115, 115),
              foregroundColor: const Color.fromARGB(255, 0, 0, 0),
            ),
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
