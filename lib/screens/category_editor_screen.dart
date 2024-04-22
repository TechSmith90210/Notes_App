import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes_app/services/firebase_service.dart';
import 'package:notes_app/style/appStyle.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  Map<String, bool> _isEditing = {};
  Map<String, TextEditingController> _controllers = {};
  TextEditingController _categoryController = TextEditingController();
  FireBaseService _firebase = FireBaseService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add/Edit Categories',
          style: GoogleFonts.playfairDisplay(),
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("New Category"),
                    content: TextField(
                      controller: _categoryController,
                      decoration: InputDecoration(
                        hintText: 'Eg. Groceries',
                        hintStyle: GoogleFonts.nunito(),
                        isDense: true,
                      ),
                    ),
                    actions: [
                      TextButton(
                        child: Text(
                          "Cancel",
                          style: GoogleFonts.nunito(color: AppStyle.mainColor),
                        ),
                        onPressed: () {
                          _categoryController.clear();
                          Navigator.pop(context);
                        },
                      ),
                      TextButton(
                        child: Text("Save",
                            style: GoogleFonts.nunito(color: Colors.blueGrey)),
                        onPressed: () async {
                          if (_categoryController.text.trim().isNotEmpty) {
                            await _firebase
                                .createCategory(_categoryController.text);
                            _categoryController.clear();
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ],
                  );
                },
              );
            },
            title: Text(
              'Add Category',
              style: GoogleFonts.nunito(),
            ),
            leading: Icon(
              Icons.add,
              color: Colors.blueGrey,
            ),
          ),
          Divider(
            color: AppStyle.tertiaryColor,
            thickness: 2,
            height: 3,
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser?.uid)
                .collection('Categories')
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasData) {
                return ListView(
                  shrinkWrap: true,
                  children: snapshot.data!.docs.map((category) {
                    final categoryID = category.id;
                    final categoryName = category['name'] ?? '';
                    _controllers[categoryID] ??=
                        TextEditingController(text: categoryName);
                    return Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.label_outline),
                          title: _isEditing[categoryID] == true
                              ? TextField(
                                  controller: _controllers[categoryID],
                                  autofocus: true,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Enter category name',
                                  ),
                                )
                              : Text(categoryName),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_isEditing[categoryID] == true)
                                IconButton(
                                  onPressed: () async {
                                    final updatedName =
                                        _controllers[categoryID]!.text;
                                    if (updatedName.isNotEmpty) {
                                      await _firebase.updateCategory(
                                          categoryID, updatedName);
                                    }
                                    setState(() {
                                      _isEditing[categoryID] = false;
                                    });
                                  },
                                  icon: Icon(Icons.close),
                                )
                              else
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _isEditing[categoryID] = true;
                                    });
                                  },
                                  icon: Icon(Icons.edit),
                                ),
                              IconButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text("Delete Note"),
                                        content: Text(
                                            "Are you sure you want to delete this note?"),
                                        actions: [
                                          TextButton(
                                            child: Text(
                                              "Cancel",
                                              style: GoogleFonts.nunito(
                                                  color: AppStyle.mainColor),
                                            ),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                          TextButton(
                                            child: Text("Delete",
                                                style: GoogleFonts.nunito(
                                                    color: Colors.redAccent)),
                                            onPressed: () async {
                                              await _firebase
                                                  .deleteCategory(categoryID);
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                icon: Icon(Icons.delete),
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          indent: 58,
                          color: AppStyle.tertiaryColor,
                          thickness: 1,
                        )
                      ],
                    );
                  }).toList(),
                );
              }
              return Center(child: Text('No categories available'));
            },
          )
        ],
      ),
    );
  }
}
