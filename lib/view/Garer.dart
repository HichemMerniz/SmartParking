import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Garer extends StatefulWidget {
  Garer({this.document, this.currentUser});
  final FirebaseUser currentUser;
  final DocumentSnapshot document;

  @override
  _GarerState createState() => _GarerState();
}

class _GarerState extends State<Garer> {
  final db = Firestore.instance;
  final _etageController = TextEditingController();
  int i;
  String idPlace;
  String documentEtat;
  @override
  void initState() {
    super.initState();
    print(this.widget.document.documentID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue[800],
          centerTitle: true,
          title: Text("Garer",
              style: TextStyle(
                fontFamily: 'Montserrat',
                color: Colors.white,
                fontWeight: FontWeight.bold,
              )),
        ),
        backgroundColor: Colors.blue[50],
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Choisi La place : ',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 30.0,
                )),
            SizedBox(
              height: 20.0,
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.3,
              child: StreamBuilder<QuerySnapshot>(
                stream: db
                    .collection("Places")
                    .where('idParking',
                        arrayContains: this.widget.document.documentID)
                    .where('etat', isEqualTo: 0)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) return new Text("There is no expense");
                  return Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      scrollDirection: Axis.horizontal,
                      children: generateStudentList(snapshot),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Select Etage: ",
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      color: Colors.black,
                      fontSize: 20.0),
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 4,
                  child: TextField(
                    controller: _etageController,
                    keyboardType: TextInputType.number,
                  ),
                ),
                Text(
                  "/1",
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 20.0,
                      color: Colors.grey),
                )
              ],
            ),
            SizedBox(
              height: 50.0,
            ),
            Container(
              alignment: Alignment.center,
              child: RaisedButton(
                onPressed: () {
                  getIdPlace(i, documentEtat);
                },
                child: Text("Garer",
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      color: Colors.white,
                    )),
                color: Colors.green,
              ),
            )
          ],
        ));
  }

  generateStudentList(AsyncSnapshot<QuerySnapshot> snapshot) {
    return snapshot.data.documents
        .map<Widget>((doc) => Card(
              child: RaisedButton(
                onPressed: () {
                  if (doc["etat"] < 2) {
                    i = doc["etat"];
                    setState(() {
                      documentEtat = doc.documentID;
                      i = 2;
                      idPlace = doc["idPlace"];
                    });
                    (context as Element).reassemble();
                  }
                },
                color: doc["etat"] == 0
                    ? Colors.green
                    : doc["etat"] == 2 ? Colors.red : Colors.amber,
                child: Text(doc["nomPlace"],
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    )),
              ),
            ))
        .toList();
  }

  Future<void> reserverPlace() async {
    await db.collection("Reservation").add({
      'idReservation': "",
      'date': FieldValue.serverTimestamp(),
      'etage': _etageController.text.toString(),
      'idParking': this.widget.document.documentID
    }).then((documentReference) {
      db
          .collection("Reservation")
          .document(documentReference.documentID)
          .updateData({'idReservation': documentReference.documentID});

      print(documentReference.documentID);
    }).catchError((e) {
      print(e);
    });
  }

  Future<void> editPlace(int i, String selectDocument) async {
    await db
        .collection("Places")
        .document(selectDocument)
        .updateData({
          'etat': i,
        })
        .then((documentReference) {})
        .catchError((e) {
          print(e);
        });
  }

  Future<void> setidPlace() {
    Firestore.instance
        .collection('Users')
        .document(this.widget.currentUser.uid)
        .updateData({'idPlace': idPlace.toString()});
  }

  Future getIdPlace(int i, String selectDocument) async {
    await Firestore.instance
        .collection('Users')
        .document(this.widget.currentUser.uid)
        .get()
        .then((DocumentSnapshot document) {
      if (document.data['idPlace'] == "") {
        setidPlace();
        reserverPlace();
        editPlace(i, selectDocument);
      }
    });
  }
}
