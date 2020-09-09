import 'package:flutter/material.dart';
import 'package:semartparking/view/Home.dart';
import 'package:semartparking/widget/Customshape.dart';
import 'package:semartparking/widget/responsive_ui.dart';
import 'Signin.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:semartparking/model/Users.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // ui variable
  double _height;
  double _width;
  double _pixelRatio;
  bool _large;
  bool _medium;
  bool _blackVisible = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _email, _password;
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  // firebase variable
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = new GoogleSignIn();
  final database = Firestore.instance;

  /*
Email Auth ------------------------------------------------------------------------------
 */

  Future<void> signIn() async {
    final formState = _formKey.currentState;
    if (formState.validate()) {
      formState.save();
      try {
        FirebaseUser user = (await FirebaseAuth.instance
                .signInWithEmailAndPassword(email: _email, password: _password))
            .user;
        /*   data base firstore create user  */
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Home(user)),
        );
      } catch (e) {
        print("Error");
      }
    }
  }

  Future<void> sendEmailVerification() async {
    FirebaseUser user = await _auth.currentUser();
    user.sendEmailVerification();
  }

  Future<bool> isEmailVerified() async {
    FirebaseUser user = await _auth.currentUser();
    return user.isEmailVerified;
  }
  /********************************************** */

  @override
  Widget build(BuildContext context) {
    //****************************************************************************** Ui */
    final emailField = TextFormField(
      obscureText: false,
      validator: (input) {
        if (input.isEmpty) {
          return 'You should insert your email ';
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
            signIn();
          }
        },
        child: Text("Login",
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
                              height: 80.0,
                              child: Row(
                                children: <Widget>[
                                  Text('Welcome in ',
                                      style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20.0)),
                                  Text('Smart ',
                                      style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20.0)),
                                  Text('Parking',
                                      style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          color: Colors.black,
                                          fontSize: 20.0)),
                                ],
                              ),
                            ),
                            Text(
                                ' Application can help you in your day we alweys get you better ',
                                style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    color: Colors.black,
                                    fontSize: 16.0)),
                            SizedBox(height: 34.0),
                            emailField,
                            SizedBox(height: 20.0),
                            passwordField,
                            SizedBox(
                              height: 25.0,
                            ),
                            loginButon,
                            SizedBox(
                              height: 15.0,
                            ),
                            Text("If you don't have count you should to"),
                            InkWell(
                                child: Text(
                                  " Create Compte ",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.of(context)
                                      .pushReplacementNamed('/Signin');
                                }),
                            SizedBox(height: 25),
                            SignInButton(
                              Buttons.Google,
                              onPressed: () {
                                _gSignin();
                              },
                            ),
                            SizedBox(height: 25),
                            //_signInButton(),
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
          // child: Image.asset(
          //   'assets/MY TRIP.png',
          //   height: _height / 3.5,
          //   width: _width / 3.5,
          // ),
        ),
      ],
    );
  }

  // Google Authentification
  Future<String> _gSignin() async {
    GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    AuthResult authResult = await _auth.signInWithCredential(credential);
    FirebaseUser user = authResult.user;

    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);

/*   data base firstore create user  */
    Users _user = new Users(user.uid, user.displayName, user.email,
        user.photoUrl, user.phoneNumber);
    _user.setUser(user.uid, user.displayName, user.email, user.photoUrl,
        user.phoneNumber);

/* ----------------------------------- */
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Home(user)),
    );
    print("uid" + user.uid);
    return 'signInWithGoogle succeeded: $user';
  }
}
