import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/services/firebase_service.dart';

class CategorySelectionScreen extends StatefulWidget {
  final QueryDocumentSnapshot snapshot;

  const CategorySelectionScreen({Key? key, required this.snapshot})
      : super(key: key);

  @override
  State<CategorySelectionScreen> createState() =>
      _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  late FireBaseService fireBaseService;
  List<String> selectedCategories = [];

  @override
  void initState() {
    super.initState();
    fireBaseService = FireBaseService();
    _getCurrentCategories();
  }

  Future<void> _getCurrentCategories() async {
    final categories = await fireBaseService.getCategoriesForNote(widget.snapshot.id);
    setState(() {
      selectedCategories = categories;
    });
  }

  Future<List<String>> _fetchCategories() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection('Categories')
        .get();
    final List<String> allCategories = snapshot.docs
        .map((doc) => doc['name'] as String)
        .toList();
    return allCategories;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: Text('Select Categories'),
        leading: IconButton(
          onPressed: () async {
            await fireBaseService.addNoteToCategory(
              widget.snapshot.id,
              selectedCategories,
            );
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: FutureBuilder<List<String>>(
        future: _fetchCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No categories available.'));
          }
          final List<String> allCategories = snapshot.data!;
          return ListView.builder(
            shrinkWrap: true,
            itemCount: allCategories.length,
            itemBuilder: (context, index) {
              final category = allCategories[index];
              final isChecked = selectedCategories.contains(category);
              return CheckboxListTile(
                title: Text(category),
                value: isChecked,
                onChanged: (bool? value) {
                  setState(() {
                    if (value != null) {
                      if (value) {
                        selectedCategories.add(category);
                      } else {
                        selectedCategories.remove(category);
                      }
                    }
                  });
                },
              );
            },
          );
        },
      ),
    );
  }
}
