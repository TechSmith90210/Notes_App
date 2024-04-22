import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes_app/models/note_model.dart';
import 'package:notes_app/screens/noteViewer_screen.dart';
import 'package:notes_app/services/firebase_service.dart';
import 'package:notes_app/style/appStyle.dart';
import 'package:notes_app/widgets/delete_alert_widget.dart';
import 'package:notes_app/widgets/noteCardWidget.dart';

class SearchService extends SearchDelegate {
  @override
  InputDecorationTheme? get searchFieldDecorationTheme => InputDecorationTheme(
        hintStyle: GoogleFonts.nunito(),
        labelStyle: GoogleFonts.nunito(),
        isDense: true,
      );
  @override
  String? get searchFieldLabel => 'Search';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String notesCollection = 'Notes';
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 10,
        ),
        StreamBuilder(
          stream: _firestore
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser?.uid)
              .collection(notesCollection)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasData) {
              final List<QueryDocumentSnapshot> results = snapshot.data!.docs
                  .where((note) =>
                      note['noteTitle']
                          .toString()
                          .toLowerCase()
                          .contains(query.toLowerCase().toString()) ||
                      note['noteBody']
                          .toString()
                          .toLowerCase()
                          .contains(query.toLowerCase().toString()))
                  .toList();
              if (results.isNotEmpty) {
                return Expanded(
                    child: GridView(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 5,
                      childAspectRatio: 0.9),
                  children: results
                      .map((note) => noteWidget(
                          () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      NoteViewerScreen(snapshot: note))),
                          () => showModalBottomSheet(
                                context: context,
                                showDragHandle: true,
                                builder: (context) {
                                  return InkWell(
                                    onTap: () async {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return DeleteNoteDialog(
                                            onDeletePressed: () async {
                                              FireBaseService fireBaseService =
                                                  FireBaseService();
                                              await fireBaseService
                                                  .deleteNote(note.id);
                                              Navigator.pop(context);
                                              Navigator.pop(context);
                                            },
                                          );
                                        },
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Row(
                                        children: [
                                          Container(
                                            height: 30,
                                            child: Text(
                                              "Delete Note",
                                              style:
                                                  GoogleFonts.playfairDisplay(
                                                      color: AppStyle.mainColor,
                                                      fontSize: 18),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                          note))
                      .toList(),
                ));
              } else {
                return Center(child: Text('No Notes Found'));
              }
            }
            return Center(child: Text('Search for something'));
          },
        ),
      ],
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 10,
        ),
        StreamBuilder(
          stream: _firestore
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser?.uid)
              .collection(notesCollection)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasData) {
              final List<QueryDocumentSnapshot> results = snapshot.data!.docs
                  .where((note) =>
                      note['noteTitle']
                          .toString()
                          .toLowerCase()
                          .contains(query.toLowerCase().toString()) ||
                      note['noteBody']
                          .toString()
                          .toLowerCase()
                          .contains(query.toLowerCase().toString()))
                  .toList();
              if (results.isNotEmpty) {
                return Expanded(
                    child: GridView(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 5,
                      childAspectRatio: 0.9),
                  children: results
                      .map((note) => noteWidget(
                          () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      NoteViewerScreen(snapshot: note))),
                          () => showModalBottomSheet(
                                context: context,
                                showDragHandle: true,
                                builder: (context) {
                                  return InkWell(
                                    onTap: () async {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return DeleteNoteDialog(
                                            onDeletePressed: () async {
                                              FireBaseService fireBaseService =
                                                  FireBaseService();
                                              await fireBaseService
                                                  .deleteNote(note.id);
                                              Navigator.pop(context);
                                              Navigator.pop(context);
                                            },
                                          );
                                        },
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Row(
                                        children: [
                                          Container(
                                            height: 30,
                                            child: Text(
                                              "Delete Note",
                                              style:
                                                  GoogleFonts.playfairDisplay(
                                                      color: AppStyle.mainColor,
                                                      fontSize: 18),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                          note))
                      .toList(),
                ));
              } else {
                return Center(child: Text('No Notes Found'));
              }
            }
            return Center(child: Text('Search for something'));
          },
        ),
      ],
    );
  }
}
