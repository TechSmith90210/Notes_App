import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes_app/services/firebase_service.dart';
import 'package:notes_app/style/appStyle.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NoteCreatorScreen extends StatefulWidget {
  const NoteCreatorScreen({Key? key}) : super(key: key);

  @override
  State<NoteCreatorScreen> createState() => _NoteCreatorScreenState();
}

class _NoteCreatorScreenState extends State<NoteCreatorScreen> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _bodyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: AppStyle.bgColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                maxLines: null,
                controller: _titleController,
                style: GoogleFonts.playfairDisplay(
                  color: AppStyle.mainColor,
                  fontSize: 35,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter Title',
                  hintStyle: GoogleFonts.playfairDisplay(
                    color: AppStyle.mainColor,
                    fontSize: 35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextField(
                maxLines: null,
                controller: _bodyController,
                style: GoogleFonts.nunito(
                  color: AppStyle.mainColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter Body',
                  hintStyle: GoogleFonts.nunito(
                    color: AppStyle.mainColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser == null) {
            print('User not authenticated');
            return;
          }

          if (_titleController.text.trim().isNotEmpty ||
              _bodyController.text.trim().isNotEmpty) {
            final userId = currentUser.uid;
            FireBaseService fireBaseService = FireBaseService();
            await fireBaseService.addNote(
              userId,
              _titleController.text.trim(),
              _bodyController.text.trim(),
            );
            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Enter title or body',
                  style: GoogleFonts.nunito(color: AppStyle.secondaryColor),
                ),
              ),
            );
          }
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.save),
      ),
    );
  }
}
