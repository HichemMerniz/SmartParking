import "dart:math";

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:semartparking/view/Garer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:semartparking/view/Resrver.dart';
import 'package:semartparking/model/Places.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Parkinginfo extends StatefulWidget {
  Parkinginfo({this.document, this.currentUser});
  final DocumentSnapshot document;
  final FirebaseUser currentUser;
  @override
  _ParkinginfoState createState() => _ParkinginfoState();
}

class _ParkinginfoState extends State<Parkinginfo> {
  final random = new Random();
  GoogleMapController mapController;
  final Set<Marker> _markers = new Set();
  final db = Firestore.instance;
  String idPlace;
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  String _currentAddress;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

/*Garer----------------------------------*/
  void displayBottomSheetGarer(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.4,
            child: Center(
              child: Text("Welcome in Smart parking!"),
            ),
          );
        });
  }

/*Reserver----------------------------------*/
  void displayBottomSheetReserver(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return Container(
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: GridView.count(
                      crossAxisCount: 3,
                      children: List.generate(
                          int.parse(this.widget.document['nbrPlaces']),
                          (index) {
                        return Center(
                          child: Text(
                            'Item $index',
                            style: Theme.of(context).textTheme.headline5,
                          ),
                        );
                      }),
                    ),
                  )
                ],
              ));
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getAddressFromLatLng();
  }

  @override
  Widget build(BuildContext context) {
    double lat = this.widget.document['addressParking'].latitude;
    double long = this.widget.document['addressParking'].longitude;
    LatLng _center = LatLng(lat, long);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        centerTitle: true,
        title: Text("Parking information"),
      ),
      backgroundColor: Colors.blue[50],
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(30.0),
            child: Container(
              alignment: Alignment.topCenter,
              height: MediaQuery.of(context).size.height / 5,
              width: MediaQuery.of(context).size.width,
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                markers: this.myMarker(),
                initialCameraPosition: CameraPosition(
                  target: _center,
                  zoom: 18.0,
                ),
              ),
            ),
          ),
          Align(
              alignment: Alignment.center,
              child: Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(30.0),
                      child: Align(
                          alignment: Alignment.topLeft,
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Text("Parking name: ",
                                      style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20.0)),
                                  Text("${this.widget.document['nomParking']}",
                                      style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20.0)),
                                ],
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              Row(
                                children: <Widget>[
                                  Text("Number of Places: ",
                                      style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20.0)),
                                  Text(
                                      "${this.widget.document['nbrPlaces']} Places ",
                                      style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          color: Colors.black,
                                          fontSize: 20.0)),
                                ],
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              Row(
                                children: <Widget>[
                                  Text("Parking address : ",
                                      style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20.0)),
                                  Expanded(
                                    child: Text("$_currentAddress",
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            color: Colors.black,
                                            fontSize: 20.0)),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 60.0,
                              ),
                              Center(
                                child: Row(
                                  //mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    RaisedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Reserver(
                                                    document:
                                                        this.widget.document,
                                                    currentUser:
                                                        this.widget.currentUser,
                                                  )),
                                        );
                                      },
                                      child: Text("Reserve",
                                          style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            color: Colors.white,
                                          )),
                                      color: Colors.orange,
                                    ),
                                    RaisedButton(
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Dialog(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20.0)),
                                                child: Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height /
                                                            2,
                                                    child: Column(
                                                      children: <Widget>[
                                                        Container(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(12.0),
                                                            child: Image.asset(
                                                              'Assets/garer.jpg',
                                                              height: 120,
                                                              width: 120,
                                                            ),
                                                          ),
                                                          width:
                                                              double.infinity,
                                                          decoration: BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              shape: BoxShape
                                                                  .rectangle,
                                                              borderRadius: BorderRadius.only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          12),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          12))),
                                                        ),
                                                        Container(
                                                          child: StreamBuilder<
                                                              QuerySnapshot>(
                                                            stream: db
                                                                .collection(
                                                                    "Places")
                                                                .where(
                                                                    'idParking',
                                                                    arrayContains: this
                                                                        .widget
                                                                        .document
                                                                        .documentID)
                                                                .where('etat',
                                                                    isEqualTo:
                                                                        0)
                                                                .snapshots(),
                                                            builder: (BuildContext
                                                                    context,
                                                                AsyncSnapshot<
                                                                        QuerySnapshot>
                                                                    snapshot) {
                                                              if (!snapshot
                                                                  .hasData) {
                                                                return Center(
                                                                    child: Text(
                                                                        "There is no Place",
                                                                        style: TextStyle(
                                                                            fontFamily:
                                                                                'Montserrat',
                                                                            color:
                                                                                Colors.black,
                                                                            fontWeight: FontWeight.bold,
                                                                            fontSize: 20.0)));
                                                              } else {
                                                                return Expanded(
                                                                  child: ListView
                                                                      .builder(
                                                                          itemCount: snapshot
                                                                              .data
                                                                              .documents
                                                                              .length,
                                                                          itemBuilder:
                                                                              (_, int index) {
                                                                            var i =
                                                                                random.nextInt(snapshot.data.documents.length);
                                                                            if (snapshot.data.documents.length ==
                                                                                0) {
                                                                              return Center(child: Text("There is no Place", style: TextStyle(fontFamily: 'Montserrat', color: Colors.black, fontSize: 20.0)));
                                                                            } else {
                                                                              return Center(
                                                                                child: Flex(
                                                                                  direction: Axis.vertical,
                                                                                  children: <Widget>[
                                                                                    Text("Park in this place: "),
                                                                                    Text(snapshot.data.documents[i]["nomPlace"], style: TextStyle(fontFamily: 'Montserrat', color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20.0)),
                                                                                    Text("Floor: " + this.widget.document['nbrEtages'], style: TextStyle(fontFamily: 'Montserrat', color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20.0))
                                                                                  ],
                                                                                ),
                                                                              );
                                                                            }
                                                                          }),
                                                                );
                                                              }
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    )),
                                              );
                                            });
                                      },
                                      child: Text("Park",
                                          style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            color: Colors.white,
                                          )),
                                      color: Colors.green,
                                    ),
                                    RaisedButton(
                                      onPressed: () async {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Dialog(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20.0)),
                                                child: Container(
                                                  height: 150,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 12.0),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text('Confirmation',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Montserrat',
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize:
                                                                    20.0)),
                                                        Text(
                                                            'Would you want cancel reservation ? '),
                                                        SizedBox(
                                                          height: 20.0,
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: <Widget>[
                                                            RaisedButton(
                                                              onPressed:
                                                                  getIDPlace,
                                                              child: Text(
                                                                "Cancel",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                              color: Colors.red,
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            });
                                      },
                                      child: Text("Cancel",
                                          style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            color: Colors.white,
                                          )),
                                      color: Colors.red,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          )),
                    )
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Set<Marker> myMarker() {
    double lat = this.widget.document['addressParking'].latitude;
    double long = this.widget.document['addressParking'].longitude;
    LatLng _center = LatLng(lat, long);
    setState(() {
      _markers.add(Marker(
        // This marker id can be anything that uniquely identifies each marker.
        markerId: MarkerId(_center.toString()),
        position: _center,
        infoWindow: InfoWindow(
          title: "${this.widget.document['nomParking']}",
          snippet: "${this.widget.document['nbrPlaces']}",
        ),
        icon: BitmapDescriptor.defaultMarker,
      ));
    });

    return _markers;
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          this.widget.document['addressParking'].latitude,
          this.widget.document['addressParking'].longitude);

      Placemark place = p[0];

      setState(() {
        _currentAddress = "${place.locality}, ${place.country}";
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> getIDPlace() async {
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
}
