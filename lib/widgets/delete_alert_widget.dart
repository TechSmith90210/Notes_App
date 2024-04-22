import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes_app/style/appStyle.dart';

class DeleteNoteDialog extends StatelessWidget {
  final VoidCallback onDeletePressed;

  DeleteNoteDialog({required this.onDeletePressed});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Delete Note"),
      content: Text("Are you sure you want to delete this note?"),
      actions: [
        TextButton(
          child: Text(
            "Cancel",
            style: GoogleFonts.nunito(color: AppStyle.mainColor),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: Text("Delete",
              style: GoogleFonts.nunito(color: Colors.redAccent)),
          onPressed: onDeletePressed,
        ),
      ],
    );
  }
}
