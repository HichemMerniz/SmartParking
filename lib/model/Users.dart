import 'package:cloud_firestore/cloud_firestore.dart';

class Users {
  String _idUser;
  String _name;
  String _phone;
  String _email;
  String _photoProfil;

  //Constucter -----------------
  Users(this._idUser, this._name, this._email, this._photoProfil, this._phone);
  final database = Firestore.instance;
  setUser(String _idUser, String _name, String _email, String _photoProfil,
      String _phone) async {
    //Script
    return await database
        .collection("Users")
        .document(_idUser)
        .setData({
          'idUser': _idUser,
          'name': _name,
          'phone:': _phone,
          'email': _email,
          'photoProfil': _photoProfil,
          'idPlace': "",
        })
        .then((documentReference) {})
        .catchError((e) {
          print(e);
        });
  }
}
