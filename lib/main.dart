import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:semartparking/view/Splashscreen.dart';
import 'auth/Login.dart';
import 'auth/Signin.dart';
import 'package:semartparking/auth/Auth.dart';
import 'view/Home.dart';
import 'view/Parkinginfo.dart';
import 'view/Garer.dart';

void main() => runApp(
      ChangeNotifierProvider<AuthService>(
        child: MyApp(),
        builder: (BuildContext context) {
          return AuthService();
        },
      ),
    );
    

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Parking',
      routes: <String, WidgetBuilder>{
        '/Login': (BuildContext context) => Login(),
        '/Signin': (BuildContext context) => Signin(),
        //   '/Home': (BuildContext context) => Home(),
        '/Parkinginfo': (BuildContext context) => Parkinginfo(),
        '/Garer': (BuildContext context) => Garer(),
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<FirebaseUser>(
        future: Provider.of<AuthService>(context).getUser(),
        builder: (context, AsyncSnapshot<FirebaseUser> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.error != null) {
              print("error");
              return Text(snapshot.error.toString());
            }
            return snapshot.hasData ? Home(snapshot.data) : SplashScreen();
          } else {
            return LoadingCircle();
          }
        },
      ),
    );
  }
}

class LoadingCircle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: CircularProgressIndicator(),
        alignment: Alignment(0.0, 0.0),
      ),
    );
  }
}
