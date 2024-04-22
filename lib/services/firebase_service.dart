import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notes_app/models/note_model.dart';
import 'package:uuid/uuid.dart';

class FireBaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String usersCollection = 'users';
  final String categoriesCollection = 'Categories';
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user UID
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  //methods for adding, updating and deleting notes
  Future<void> addNote(String userId, String title, String body) async {
    var uuid = Uuid().v4();
    try {
      await _firestore
          .collection(usersCollection)
          .doc(userId)
          .collection('Notes')
          .doc(uuid)
          .set({
        "id": uuid,
        "noteTitle": title,
        "noteBody": body,
        'creationDate': Timestamp.now(),
        "Categories": []
      });
    } catch (e) {
      print("Error Adding Note: $e");
    }
  }

  Future<void> updateNote(Note note) async {
    String? userId = getCurrentUserId();
    if (userId == null) return;

    try {
      await _firestore
          .collection(usersCollection)
          .doc(userId)
          .collection('Notes')
          .doc(note.id)
          .update({
        "noteTitle": note.title,
        "noteBody": note.body,
        'creationDate': Timestamp.now(),
      });
    } catch (e) {
      print("Error updating note: $e");
    }
  }

  Future<void> deleteNote(String uid) async {
    String? userId = getCurrentUserId();
    if (userId == null) return;

    try {
      await _firestore
          .collection(usersCollection)
          .doc(userId)
          .collection('Notes')
          .doc(uid)
          .delete();
    } catch (e) {
      print('Error:$e');
    }
  }

  // create, edit and delete categories
  Future<void> createCategory(String name) async {
    var uuid = Uuid().v4();
    String? userId = getCurrentUserId();
    if (userId == null) return;

    try {
      await _firestore
          .collection(categoriesCollection)
          .doc(uuid)
          .set({'id': uuid, 'name': name, 'creationDate': Timestamp.now()});
    } catch (e) {
      print('Error:$e');
    }
  }

  Future<void> updateCategory(String uid, String name) async {
    String? userId = getCurrentUserId();
    if (userId == null) return;

    try {
      await _firestore
          .collection(categoriesCollection)
          .doc(uid)
          .update({'name': name});
    } catch (e) {
      print('Error:$e');
    }
  }

  Future<void> deleteCategory(String uid) async {
    String? userId = getCurrentUserId();
    if (userId == null) return;

    try {
      await _firestore.collection(categoriesCollection).doc(uid).delete();
      print('Category deleted successfully: $uid');
    } catch (e) {
      print('Error deleting category: $e');
    }
  }

  Future<List<String>> getNoteCategories(String noteId) async {
    try {
      final noteDoc = await _firestore.collection('Notes').doc(noteId).get();
      final data = noteDoc.data();
      if (data != null && data['Categories'] != null) {
        final List<dynamic> categories = data['Categories'];
        return categories.map((category) => category.toString()).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching note categories: $e');
      throw e;
    }
  }
  Future<void> addNoteToCategory(String uid, List<dynamic> category) async {
    String? userId = getCurrentUserId();
    if (userId == null) return;

    try {
      await _firestore
          .collection(usersCollection)
          .doc(userId)
          .collection('Notes')
          .doc(uid)
          .update({'Categories': category});
    } catch (e) {
      print('Error updating categories: $e');
      // Handle the error if necessary
    }
  }
}
