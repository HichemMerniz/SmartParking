import 'package:cloud_firestore/cloud_firestore.dart';

class Places {
  String idPlace;
  String numPlace;
  int etatPlace;
  String idParking;

  final db = Firestore.instance;

  //Places(this.numPlace, this.etatPlace, this.idParking);

  Future<void> addPlace(int i) async {
    await db.collection("Places").add({
      'nomPlace': "place $i",
      'etat': 0,
      'idParking': [],
    }).then((documentReference) {
      db.collection("Places").add({
        'idPlace': documentReference.documentID,
      });
      print(documentReference.documentID);
    }).catchError((e) {
      print(e);
    });
  }
}
