import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Reserver extends StatefulWidget {
  Reserver({this.document, this.currentUser});
  final DocumentSnapshot document;
  final FirebaseUser currentUser;

  @override
  _ReserverState createState() => _ReserverState();
}

class _ReserverState extends State<Reserver> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  final db = Firestore.instance;
  final _etageController = TextEditingController();

  final _heurController = TextEditingController();
  final _minuteController = TextEditingController();
  int i;
  String idPlace;
  String idPlaceVerification;
  String documentEtat;
  String idResrvation;
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();

    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);

    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue[800],
          centerTitle: true,
          title: Text("Reserver",
              style: TextStyle(
                fontFamily: 'Montserrat',
                color: Colors.white,
                fontWeight: FontWeight.bold,
              )),
        ),
        backgroundColor: Colors.blue[50],
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Choose the place: ',
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
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData)
                      return new Text("There is no expense");
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
              //----------------------------------------------------------------------
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          "Select the floor: ",
                          style: TextStyle(
                              fontFamily: 'Montserrat',
                              color: Colors.black,
                              fontSize: 20.0),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 4,
                          child: TextFormField(
                            controller: _etageController,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter some number of the floor';
                              }
                            },
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
                    //---------------------------------------------------------------------
                    /**/
                    Row(children: <Widget>[
                      Text(
                        "Reservation duration: ",
                        style: TextStyle(
                            fontFamily: 'Montserrat',
                            color: Colors.black,
                            fontSize: 15.0),
                      ),
                      Row(
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width / 4,
                            child: TextFormField(
                              decoration: InputDecoration(hintText: "*Hours"),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter some number of time';
                                }
                              },
                              controller: _heurController,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width / 4,
                            child: TextFormField(
                              decoration: InputDecoration(hintText: "*Minutes"),
                              controller: _minuteController,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter some number of time';
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ]),
                  ],
                ),
              ),

              /**/
              //---------------------------------------------------------------------
              SizedBox(
                height: 50.0,
              ),
              Container(
                alignment: Alignment.center,
                child: RaisedButton(
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      _showNotificationWithDefaultSound();
                      getIdPlace(i, documentEtat);
                    }
                  },
                  child: Text("Reserve",
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.white,
                      )),
                  color: Colors.amber,
                ),
              )
            ],
          ),
        ));
  }

  generateStudentList(AsyncSnapshot<QuerySnapshot> snapshot) {
    return snapshot.data.documents
        .map<Widget>((doc) => Card(
              child: RaisedButton(
                onPressed: () {
                  if (doc["etat"] < 1) {
                    i = doc["etat"];
                    setState(() {
                      documentEtat = doc.documentID;
                      i += 1;
                      idPlace = doc["idPlace"];
                      print("id place =$idPlace");
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
    var min = int.parse(_minuteController.text) * 60;
    var heur = int.parse(_heurController.text) * 3600;
    int s = min + heur;
    await db.collection("Reservation").add({
      'idReservation': "",
      'date': FieldValue.serverTimestamp(),
      'etage': _etageController.text.toString(),
      'idParking': this.widget.document.documentID,
      'dure': s,
      'idUser': this.widget.currentUser.uid,
      'idPlace': idPlace
    }).then((documentReference) {
      db
          .collection("Reservation")
          .document(documentReference.documentID)
          .updateData({'idReservation': documentReference.documentID});
      setState(() {
        idResrvation = documentReference.documentID;
      });

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
          print("===>" + e);
        });
  }

  Future<void> setidPlace() {
    Firestore.instance
        .collection('Users')
        .document(this.widget.currentUser.uid)
        .updateData({'idPlace': idPlace.toString()});
  }

  Future _showNotificationWithDefaultSound() async {
    var min = int.parse(_minuteController.text) * 60;
    var heur = int.parse(_heurController.text) * 3600;
    int s = min + heur;
    Future.delayed(new Duration(seconds: s), () {
      cancelReservation();
    });
    var scheduledNotificationDateTime =
        new DateTime.now().add(new Duration(seconds: s));
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        '0', 'Smart Parking', 'Reservation completed ');
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    NotificationDetails platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.schedule(
        0,
        'Smart Parking',
        'Reservation completed',
        scheduledNotificationDateTime,
        platformChannelSpecifics);
  }

  Future<void> getIdPlace(int i, String selectDocument) async {
    await Firestore.instance
        .collection('Users')
        .document(this.widget.currentUser.uid)
        .get()
        .then((DocumentSnapshot document) {
      if (document.data['idPlace'] == "") {
        setidPlace();
        reserverPlace();
        editPlace(i, selectDocument);
        Fluttertoast.showToast(
            msg:
                "Resrvation completed after ${_heurController.text} h :${_minuteController.text} min ",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.amber[100],
            textColor: Colors.black);
      }
    });
  }

  Future<void> librePlace(String idPlace) async {
    await Firestore.instance
        .collection('Users')
        .document(this.widget.currentUser.uid)
        .updateData({
      'idPlace': "",
    });
  }

  Future<void> setEtatzero(String idPlace) async {
    await Firestore.instance.collection('Places').document(idPlace).updateData(
      {'etat': 0},
    ).then((value) => {librePlace(idPlace)});

    Fluttertoast.showToast(
        msg: "Cancel Reservation Successfully !!  ",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red[500],
        textColor: Colors.white);
  }

  Future<void> cancelReservation() async {
    await Firestore.instance
        .collection('Users')
        .document(this.widget.currentUser.uid)
        .get()
        .then((DocumentSnapshot document) {
      if (document.data['idPlace'] != "") {
        setState(() {
          idPlace = document.data['idPlace'];
        });
        setEtatzero(idPlace);
      }
    });
  }
}
