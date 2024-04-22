import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes_app/screens/noteViewer_screen.dart';
import 'package:notes_app/services/firebase_service.dart';
import 'package:notes_app/style/appStyle.dart';
import 'package:notes_app/widgets/delete_alert_widget.dart';
import 'package:notes_app/widgets/noteCardWidget.dart';

class CategoryNotesScreen extends StatefulWidget {
  final QueryDocumentSnapshot snapshot;

  const CategoryNotesScreen({
    Key? key,
    required this.snapshot,
  }) : super(key: key);

  @override
  State<CategoryNotesScreen> createState() => _CategoryNotesScreenState();
}

class _CategoryNotesScreenState extends State<CategoryNotesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.snapshot['name']),
        forceMaterialTransparency: true,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser?.uid)
                .collection('Notes')
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasData) {
                // Filter notes based on category name
                final filteredNotes = snapshot.data!.docs.where((note) {
                  final categories = note['Categories'] as List<dynamic>? ?? [];
                  return categories.contains(widget.snapshot['name']);
                }).toList();

                if (filteredNotes.isEmpty) {
                  return Center(
                    child: Text(
                      'No Notes in this category',
                      style: GoogleFonts.nunito(color: AppStyle.mainColor),
                    ),
                  );
                }

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: GridView(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 5,
                        childAspectRatio: 0.9,
                      ),
                      children: filteredNotes
                          .map(
                            (note) => noteWidget(
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      NoteViewerScreen(snapshot: note),
                                ),
                              ),
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
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              note,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                );
              } else {
                return Center(child: Text('Error fetching notes'));
              }
            },
          ),
        ],
      ),
    );
  }
}
