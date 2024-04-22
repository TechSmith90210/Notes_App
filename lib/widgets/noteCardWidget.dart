import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes_app/style/appStyle.dart';

Widget noteWidget(Function()? onTap, Function()? onLongPress,
    QueryDocumentSnapshot snapshot) {
  List<dynamic>? categories = snapshot['Categories'];
  int remainingCategoriesCount = (categories?.length ?? 0) - 2;

  return InkWell(
    onTap: onTap,
    onLongPress: onLongPress,
    child: Container(
      padding: EdgeInsets.all(14),
      margin: EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: AppStyle.mainColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            snapshot['noteTitle'],
            style: GoogleFonts.playfairDisplay(
              color: AppStyle.secondaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 22,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            snapshot['noteBody'],
            style: AppStyle.secondaryFont,
            overflow: TextOverflow.ellipsis,
            maxLines: 4,
          ),
          SizedBox(
            height: 5,
          ),
          if (categories != null && categories.length > 0)
            Wrap(
              spacing: 3,
              runSpacing: 2,
              children: [
                ...categories.take(2).map<Widget>((category) => Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppStyle.tertiaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        category.toString(),
                        style: TextStyle(color: Colors.black, fontSize: 12),
                      ),
                    )),
                if (remainingCategoriesCount > 0)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppStyle.tertiaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '+$remainingCategoriesCount',
                      style: TextStyle(color: Colors.black, fontSize: 12),
                    ),
                  ),
              ],
            ),
        ],
      ),
    ),
  );
}
