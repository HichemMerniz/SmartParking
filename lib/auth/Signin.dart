import 'package:flutter/material.dart';
import 'package:semartparking/widget/Customshape.dart';
import 'package:semartparking/widget/responsive_ui.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:semartparking/view/Home.dart';
import 'package:semartparking/model/Users.dart';

class Signin extends StatefulWidget {
  @override
  _SigninState createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  // ui variable
  double _height;
  double _width;
  double _pixelRatio;
  bool _large;
  bool _medium;
  bool _blackVisible = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  // firebase variable
  FirebaseUser _user;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = new GoogleSignIn();
  final database = Firestore.instance;
  String _email, _password, _nom, _prenom, _phone;
  /*
Email Auth ------------------------------------------------------------------------------
 */

  Future<void> signUp() async {
    final formState = _formKey.currentState;
    if (formState.validate()) {
      formState.save();
      _user = (await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: _email, password: _password))
          .user;
      _user.sendEmailVerification();
      /*   data base firstore create user  */

      await database
          .collection("Users")
          .document(_user.uid)
          .setData({
            'idUser': _user.uid,
            'name': _nom,
            'phone': _phone.toString(),
            'email': _user.email,
            'photoProfil': _user.photoUrl,
            'idPlace': "",
          })
          .then((documentReference) {})
          .catchError((e) {
            print(e);
          });

      Navigator.of(context).pushReplacementNamed('/Login');
    }
  }

  /********************************************** */

  @override
  Widget build(BuildContext context) {
    final nomField = TextFormField(
      obscureText: false,
      validator: (input) {
        if (input.isEmpty) {
          return 'You should to type your full name ';
        }
      },
      onSaved: (input) => _nom = input,
      showCursor: true,
      keyboardType: TextInputType.text,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          hintText: "Full Name",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );

    final emailField = TextFormField(
      obscureText: false,
      validator: (input) {
        if (input.isEmpty) {
          return 'You should to type your email ';
        }
      },
      onSaved: (input) => _email = input,
      showCursor: true,
      keyboardType: TextInputType.emailAddress,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          hintText: "Email",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );

    final phoneField = TextFormField(
      obscureText: false,
      validator: (input) {
        if (input.isEmpty) {
          return 'You should to type your email ';
        }
      },
      onSaved: (input) => _phone = input,
      showCursor: true,
      keyboardType: TextInputType.phone,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          hintText: "Phone",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );

    final passwordField = TextFormField(
      obscureText: true,
      validator: (input) {
        if (input.length < 6) {
          return 'Your password needs to be realesd 6  ';
        }
      },
      onSaved: (input) => _password = input,
      keyboardType: TextInputType.visiblePassword,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          hintText: "Password",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );

    final loginButon = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Color(0xff01A0C7),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        onPressed: () {
          if (_formKey.currentState.validate()) {
            signUp();
          }
        },
        child: Text("Signin",
            textAlign: TextAlign.center,
            style: style.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            )),
      ),
    );
    //****************************************************************************** */
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    _pixelRatio = MediaQuery.of(context).devicePixelRatio;
    _large = ResponsiveWidget.isScreenLarge(_width, _pixelRatio);
    _medium = ResponsiveWidget.isScreenMedium(_width, _pixelRatio);
    return Material(
      child: Container(
        height: _height,
        width: _width,
        padding: EdgeInsets.only(bottom: 5),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              clipShape(),
              Center(
                child: Container(
                  color: Colors.white70,
                  child: Padding(
                      padding: const EdgeInsets.all(36.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              height: 10.0,
                            ),
                            SizedBox(
                              child: Row(
                                children: <Widget>[
                                  Text('Signin',
                                      style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20.0)),
                                ],
                              ),
                            ),
                            SizedBox(height: 20.0),
                            nomField,
                            SizedBox(height: 20.0),
                            emailField,
                            SizedBox(height: 20.0),
                            phoneField,
                            SizedBox(height: 20.0),
                            passwordField,
                            SizedBox(
                              height: 25.0,
                            ),
                            loginButon,
                          ],
                        ),
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget clipShape() {
    //double height = MediaQuery.of(context).size.height;
    return Stack(
      children: <Widget>[
        Opacity(
          opacity: 0.75,
          child: ClipPath(
            clipper: CustomShapeClipper(),
            child: Container(
              height: _large
                  ? _height / 4
                  : (_medium ? _height / 3.75 : _height / 3.5),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[100], Colors.blue[900]],
                ),
              ),
            ),
          ),
        ),
        Opacity(
          opacity: 0.5,
          child: ClipPath(
            clipper: CustomShapeClipper2(),
            child: Container(
              height: _large
                  ? _height / 4.5
                  : (_medium ? _height / 4.25 : _height / 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[100], Colors.blue[900]],
                ),
              ),
            ),
          ),
        ),
        Container(
          alignment: Alignment.bottomCenter,
          margin: EdgeInsets.only(
              top: _large
                  ? _height / 30
                  : (_medium ? _height / 25 : _height / 20)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              IconButton(
                  icon: Icon(Icons.arrow_back),
                  color: Colors.white,
                  iconSize: 30.0,
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/Login');
                  }),
            ],
          ),
        ),
      ],
    );
  }
}
