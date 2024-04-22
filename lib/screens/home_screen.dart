import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes_app/screens/category_editor_screen.dart';
import 'package:notes_app/screens/login_screen.dart';
import 'package:notes_app/screens/noteViewer_screen.dart';
import 'package:notes_app/services/firebase_service.dart';
import 'package:notes_app/services/search_service.dart';
import 'package:notes_app/style/appStyle.dart';
import 'package:notes_app/widgets/category_drawer_widget.dart';
import 'package:notes_app/widgets/delete_alert_widget.dart';
import 'package:notes_app/widgets/noteCardWidget.dart';
import 'noteCreatorScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var snapshot = FirebaseFirestore.instance.collection('Notes');

  @override
  void initState() {
    super.initState();
  }

  void _showLogoutModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Logout'),
              onTap: () async {
                // Sign out the user and navigate to the login screen
                await FirebaseAuth.instance.signOut();
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.bgColor,
      appBar: AppBar(
        forceMaterialTransparency: true,
        centerTitle: true,
        title: Text('My Notes',
            style: GoogleFonts.playfairDisplay(
                color: AppStyle.mainColor, fontWeight: FontWeight.w600)),
        leading: Builder(
          builder: (context) {
            return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: Icon(
                Icons.sort,
                color: AppStyle.mainColor,
                size: 30,
              ),
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              SearchService searchService = SearchService();
              showSearch(context: context, delegate: searchService);
            },
            icon: Icon(
              Icons.search,
              color: AppStyle.mainColor,
              size: 30,
            ),
          ),
          GestureDetector(
            onTap: () {
              _showLogoutModal(context);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12.0),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppStyle.mainColor,
                image: FirebaseAuth.instance.currentUser?.photoURL != null
                    ? DecorationImage(
                        image: NetworkImage(
                            FirebaseAuth.instance.currentUser!.photoURL!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: FirebaseAuth.instance.currentUser?.photoURL == null
                  ? Icon(Icons.person,
                      color: Colors
                          .white) // Use default icon if no photo available
                  : null,
            ),
          ),
        ],
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
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: GridView(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 5,
                              childAspectRatio: 0.9),
                      children: snapshot.data!.docs
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
                                                FireBaseService
                                                    fireBaseService =
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
                                                        color:
                                                            AppStyle.mainColor,
                                                        fontSize: 18),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                note,
                              ))
                          .toList(),
                    ),
                  ),
                );
              }
              return Center(
                  child: Text(
                'No Notes Yet, click on + to add a new note',
                style: GoogleFonts.nunito(color: AppStyle.mainColor),
              ));
            },
          )
        ],
      ),
      drawer: Drawer(
        backgroundColor: AppStyle.secondaryColor,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Container(
                    height: 85,
                    child: DrawerHeader(
                        padding: EdgeInsets.all(20),
                        // decoration: BoxDecoration(color: AppStyle.tertiaryColor),
                        child: Text("the Notes App",
                            style: AppStyle.mainFont
                                .copyWith(fontWeight: FontWeight.w700))),
                  ),
                  ListTile(
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(40),
                            bottomRight: Radius.circular(40))),
                    onTap: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ));
                    },
                    leading: Icon(
                      Icons.note_outlined,
                      color: AppStyle.mainColor,
                    ),
                    title: Text(
                      'All Notes',
                      style: GoogleFonts.nunito(
                          color: AppStyle.mainColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w600),
                    ),
                    style: ListTileStyle.drawer,
                    selected: true,
                    selectedTileColor: AppStyle.tertiaryColor,
                  ),
                  Divider(
                    indent: 55,
                    color: AppStyle.tertiaryColor,
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "Categories",
                      style: AppStyle.mainFont.copyWith(fontSize: 28),
                    ),
                  ),
                  StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser?.uid)
                          .collection('Categories')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.hasData) {
                          return Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Wrap(
                                runSpacing: 20,
                                spacing: 10,
                                children: snapshot.data!.docs
                                    .map((category) => CategoryWidget(
                                          snapshot: category,
                                        ))
                                    .toList()),
                          );
                        }
                        return Text('No Category Yet');
                      }),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(),
                ),
              ),
              child: ListTile(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoryScreen(),
                      ));
                },
                title: Text(
                  'Create Or Edit Categories',
                  style: AppStyle.mainFont,
                ),
                leading: Icon(
                  Icons.edit,
                  color: AppStyle.mainColor,
                ),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NoteCreatorScreen(),
              ));
        },
        backgroundColor: AppStyle.mainColor,
        child: Icon(
          Icons.add,
          color: AppStyle.secondaryColor,
        ),
      ),
    );
  }
}
