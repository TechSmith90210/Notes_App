import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/services/firebase_service.dart';

class CategorySelectionScreen extends StatefulWidget {
  final QueryDocumentSnapshot snapshot;
  final List<String> selectedCategories;

  const CategorySelectionScreen(
      {Key? key, required this.snapshot, required this.selectedCategories})
      : super(key: key);

  @override
  State<CategorySelectionScreen> createState() =>
      _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  late FireBaseService fireBaseService;

  @override
  void initState() {
    super.initState();
    fireBaseService = FireBaseService();
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
              widget.selectedCategories,
            );
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        child: StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance.collection('Categories').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No categories available.'));
            }
            final List<String> allCategories = snapshot.data!.docs
                .map((doc) => doc['name'] as String)
                .toList();
            return ListView.builder(
              shrinkWrap: true,
              itemCount: allCategories.length,
              itemBuilder: (context, index) {
                final category = allCategories[index];
                final isChecked = widget.selectedCategories.contains(category);
                return CheckboxListTile(
                  title: Text(category),
                  value: isChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value != null) {
                        if (value) {
                          widget.selectedCategories.add(category);
                        } else {
                          widget.selectedCategories.remove(category);
                        }
                      }
                    });
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
