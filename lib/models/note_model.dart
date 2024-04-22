import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  String id;
  String title;
  String body;
  Timestamp creationDate;

  Note(
      {required this.id,
      required this.title,
      required this.body,
      required this.creationDate});

  //deserializing the note (converting firebase document to Note object)
  factory Note.fromDocumentSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

    //create and return a note object
    return Note(
        id: snapshot.id,
        title: data['noteTitle'] ?? '',
        body: data['noteBody'] ?? '',
        creationDate: data['creationDate'] ?? Timestamp.now());
  }
}