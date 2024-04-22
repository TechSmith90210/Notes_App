import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes_app/style/appStyle.dart';

class AppBarWidget extends StatelessWidget {
  const AppBarWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(80),
      child: SafeArea(
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: AppBar(
            backgroundColor: AppStyle.secondaryColor,
            title: Text(
              'My Notes',
              style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.w500,
                color: AppStyle.mainColor,
              ),
            ),
            leading: IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: Icon(
                Icons.sort,
                color: AppStyle.mainColor,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.search,
                  color: AppStyle.mainColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
