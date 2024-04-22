import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes_app/models/note_model.dart';
import 'package:notes_app/screens/category_selection_screen.dart';
import 'package:notes_app/services/firebase_service.dart';
import 'package:notes_app/style/appStyle.dart';
import 'package:intl/intl.dart';
import 'package:notes_app/widgets/delete_alert_widget.dart';

class NoteViewerScreen extends StatefulWidget {
  final QueryDocumentSnapshot snapshot;

  const NoteViewerScreen({
    Key? key,
    required this.snapshot,
  }) : super(key: key);

  @override
  State<NoteViewerScreen> createState() => _NoteViewerScreenState();
}

class _NoteViewerScreenState extends State<NoteViewerScreen> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _bodyController = TextEditingController();
  late List<dynamic> categories = [];
  @override
  void initState() {
    super.initState();
    _titleController.text = widget.snapshot['noteTitle'];
    _bodyController.text = widget.snapshot['noteBody'];
  }

  Future<void> _saveNoteandNavigateBack() async {
    FireBaseService fireBaseService = FireBaseService();
    Note note = Note(
      id: widget.snapshot.id,
      title: _titleController.text,
      body: _bodyController.text,
      creationDate: widget.snapshot['creationDate'],
    );

    if (note.title.isNotEmpty || note.body.isNotEmpty) {
      if (note.title != widget.snapshot['noteTitle'] ||
          note.body != widget.snapshot['noteBody']) {
        await fireBaseService.updateNote(note);
      }
    } else {
      fireBaseService.deleteNote(widget.snapshot.id);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    Timestamp timestamp = widget.snapshot["creationDate"];
    DateTime dateTime = timestamp.toDate();
    String formattedCreationTime =
        DateFormat('dd MMM, yyyy hh:mm a').format(dateTime);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppStyle.bgColor,
        title: Text(
          widget.snapshot['noteTitle'],
          style: GoogleFonts.nunito(color: AppStyle.mainColor, fontSize: 18),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () async {
            await _saveNoteandNavigateBack();
          },
          icon: Icon(Icons.arrow_back_sharp),
        ),
        actions: [
          IconButton(
              onPressed: () {
                List<String> selectedCategories =
                    categories.map((e) => e.toString()).toList();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategorySelectionScreen(
                      // selectedCategories: selectedCategories,
                      snapshot: widget.snapshot,
                    ),
                  ),
                );
              },
              icon: Icon(Icons.label)),
          IconButton(
              onPressed: () async {
                showDialog(
                  context: context,
                  builder: (context) {
                    return DeleteNoteDialog(
                      onDeletePressed: () async {
                        FireBaseService fireBaseService = FireBaseService();
                        await fireBaseService.deleteNote(widget.snapshot.id);
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                    );
                  },
                );
              },
              icon: const Icon(Icons.delete))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child: ListView(
          children: [
            TextField(
              controller: _titleController,
              maxLines: null,
              style: GoogleFonts.playfairDisplay(
                  color: AppStyle.mainColor,
                  fontSize: 35,
                  fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter Title',
                hintStyle: GoogleFonts.playfairDisplay(
                    color: AppStyle.mainColor,
                    fontSize: 35,
                    fontWeight: FontWeight.w600),
              ),
            ),
            TextField(
              controller: _bodyController,
              maxLines: null,
              style: GoogleFonts.nunito(
                  color: AppStyle.mainColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w400),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter Body',
                hintStyle: GoogleFonts.nunito(
                    color: AppStyle.mainColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w400),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser?.uid)
                    .collection('Notes')
                    .doc(widget.snapshot.id)
                    .snapshots(),
                builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasData && snapshot.data!.exists) {
                    final data = snapshot.data!.data() as Map<String, dynamic>?;
                    final categories = (data?['Categories'] as List<dynamic>?) ?? [];

                    if (categories.isNotEmpty) {
                      return Wrap(
                        spacing: 5,
                        children: categories.map((category) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: Chip(
                              visualDensity: VisualDensity.comfortable,
                              label: Text(category.toString()),
                            ),
                          );
                        }).toList(),
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox.shrink(),
                      );
                    }
                  }
                  return Text('No Data');
                },
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _saveNoteandNavigateBack();
        },
        backgroundColor: Colors.blueGrey,
        child: const Icon(Icons.save),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Last Edited: $formattedCreationTime',
              style: TextStyle(color: AppStyle.mainColor),
            ),
          ],
        ),
      ),
    );
  }
}
