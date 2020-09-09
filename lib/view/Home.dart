import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:semartparking/view/Parkinginfo.dart';
import 'package:fluttertoast/fluttertoast.dart';

Future<String> fetchStr() async {
  await new Future.delayed(const Duration(seconds: 3), () {});
  return 'Data';
}

class Home extends StatefulWidget {
  final Future<String> str = fetchStr();
  final FirebaseUser currentUser;

  Home(this.currentUser);
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool click = true;
  final GoogleSignIn _googleSignIn = new GoogleSignIn();
  String nomPlace;
  String idPlace;
  @override
  void initState() {
    getIDPlace();
    super.initState();
  }

  final db = Firestore.instance;
  Future<void> getIDPlace() async {
    await Firestore.instance
        .collection('Users')
        .document(this.widget.currentUser.uid)
        .get()
        .then((DocumentSnapshot document) {
      if (document.data['idPlace'] != "") {
        setState(() {
          idPlace = document.data['idPlace'];
          getNomPlace(idPlace);
        });
      }
    });
  }

  Future<void> getNomPlace(String idPlace) async {
    await Firestore.instance
        .collection('Places')
        .document(idPlace)
        .get()
        .then((DocumentSnapshot document) {
      setState(() {
        nomPlace = document.data['nomPlace'];
        print(nomPlace);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[800],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            click = true;
          });
          (context as Element).reassemble();
          getIDPlace();
        },
        child: Icon(Icons.refresh),
      ),
      body: ListView(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(10.0),
                child: Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    child: CircleAvatar(
                      maxRadius: 30.00,
                      minRadius: 30.00,
                      backgroundImage: this.widget.currentUser.photoUrl == ""
                          ? Image.asset(
                              'Assets/garer.jpg',
                              height: 120,
                              width: 120,
                            )
                          : NetworkImage(
                              this.widget.currentUser.photoUrl.toString(),
                            ),
                    ),
                    onTap: () {
                      setState(() {
                        getIDPlace();
                        _showDialog();
                      });
                    },
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    onPressed: () async {
                      await _googleSignIn.signOut();
                      Navigator.of(context).pushReplacementNamed('/Login');
                      print("User Sign Out");
                      Fluttertoast.showToast(
                          msg: "User sign out successfully ",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.grey[500],
                          textColor: Colors.white);
                    },
                    icon: Icon(
                      Icons.exit_to_app,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
          Padding(
            padding: EdgeInsets.only(left: 40.0),
            child: Row(
              children: <Widget>[
                Text('Smart ',
                    style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 30.0)),
                Text('Parking',
                    style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.white,
                        fontSize: 30.0))
              ],
            ),
          ),
          SizedBox(height: 40.0),
          Container(
            height: MediaQuery.of(context).size.height - 185.0,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50.0),
                  topRight: Radius.circular(50.0)),
            ),
            child: Stack(
              children: <Widget>[
                SizedBox(height: 50.0),
                Center(
                  child: Center(
                    child: FutureBuilder<String>(
                      future: this.widget.str,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Flexible(
                              child: StreamBuilder<QuerySnapshot>(
                                  stream: Firestore.instance
                                      .collection('Parkings')
                                      .snapshots(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<QuerySnapshot> snapshot) {
                                    if (snapshot.hasError)
                                      return Text('Error: ${snapshot.error}');
                                    switch (snapshot.connectionState) {
                                      case ConnectionState.waiting:
                                        return Text('Loading...');
                                      default:
                                        return ListView(
                                          padding: EdgeInsets.all(20.0),
                                          children: snapshot.data.documents
                                              .map((DocumentSnapshot document) {
                                            return Card(
                                                color: Colors.blue[300],
                                                borderOnForeground: true,
                                                elevation: 12.0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                                child: ListTile(
                                                  trailing: IconButton(
                                                      icon: Icon(
                                                        Icons.arrow_forward_ios,
                                                        color: Colors.white,
                                                      ),
                                                      onPressed: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  Parkinginfo(
                                                                      document:
                                                                          document,
                                                                      currentUser: this
                                                                          .widget
                                                                          .currentUser)),
                                                        );
                                                      }),
                                                  selected: true,
                                                  title: Text(
                                                      document['nomParking'],
                                                      style: TextStyle(
                                                        fontFamily:
                                                            'Montserrat',
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      )),
                                                  subtitle: Text(
                                                    document['nbrPlaces']
                                                        .toString(),
                                                    style: TextStyle(
                                                      fontFamily: 'Montserrat',
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ));
                                          }).toList(),
                                        );
                                    }
                                  }));
                        } else if (snapshot.hasError) {
                          return Text("${snapshot.error}");
                        }

                        return CircularProgressIndicator();
                      },
                    ),
                  ),
                ),
                Divider(
                  height: 1.0,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDialog() async {
    await showGeneralDialog(
      barrierLabel: "Profil",
      barrierDismissible: false,
      useRootNavigator: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 700),
      context: context,
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.topCenter,
          child: Container(
            height: 500,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
            ),
            child: SizedBox.expand(
                child: Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    maxRadius: 30.00,
                    minRadius: 30.00,
                    backgroundImage: this.widget.currentUser.photoUrl == ""
                        ? Image.asset(
                            'Assets/garer.jpg',
                            height: 120,
                            width: 120,
                          )
                        : NetworkImage(
                            this.widget.currentUser.photoUrl.toString(),
                          ),
                  ),
                  Text(this.widget.currentUser.displayName,
                      style: TextStyle(
                          fontFamily: 'Montserrat',
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0)),
                  Text(this.widget.currentUser.email,
                      style: TextStyle(
                          fontFamily: 'Montserrat',
                          color: Colors.black,
                          //  fontWeight: FontWeight.bold,
                          fontSize: 15.0)),
                  //***************************************** */
                  //***************************************** */
                  //***************************************** */
                  SizedBox(height: 20.0),
                  StreamBuilder<QuerySnapshot>(
                    stream: db
                        .collection("Places")
                        .where('idPlace', isEqualTo: idPlace)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData) return Text("There is no expense");
                      return Flexible(
                          child: nomPlace == null
                              ? Center(
                                  child: Text("No Place on resrve",
                                      style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20.0)),
                                )
                              : Text("You reserve : " + nomPlace,
                                  style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20.0)));
                    },
                  ),

                  /****************************************** */
                ],
              ),
            )),
            margin: EdgeInsets.only(top: 50, bottom: 50, left: 12, right: 12),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position:
              Tween(begin: Offset(1, 0), end: Offset(0, 0)).animate(anim1),
          child: child,
        );
      },
    );
  }
}
