import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes_app/style/appStyle.dart';
import 'package:notes_app/screens/category_notes_screen.dart';

class CategoryWidget extends StatefulWidget {
  QueryDocumentSnapshot snapshot;

  CategoryWidget({
    super.key,
    required this.snapshot,
  });

  @override
  State<CategoryWidget> createState() => _CategoryWidgetState();
}

class _CategoryWidgetState extends State<CategoryWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryNotesScreen(
                snapshot: widget.snapshot,
              ),
            ));
      },
      child: Container(
        padding: EdgeInsets.all(7),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: AppStyle.mainColor)),
        child: Text(
          widget.snapshot['name'],
          style: GoogleFonts.nunito(fontSize: 18),
        ),
      ),
    );
  }
}
