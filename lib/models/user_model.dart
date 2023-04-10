import 'package:flutter/material.dart';

class UserModel {
  String? name;
  String? lastName;
  String? uid;
  double? commision;
  String? rol;
  String? email;
  String? password;
  DateTime? lastLogin;
  DateTime? created;

  UserModel(
      {this.commision,
      this.password,
      this.email,
      this.lastName,
      this.name,
      this.rol,
      this.uid,
      this.created,
      this.lastLogin});

  UserModel.froMap(Map<String, dynamic> data, id)
      : this(
          name: data['name'],
          lastName: data['lastName'],
          uid: id,
          commision: data['commision'] ?? 0,
          rol: data['rol'],
          email: data['email'],
          password: data['password'] ?? 'Folios123',
          lastLogin: data['lastLogin'] == null
              ? data['created'].toDate()
              : data['lastLogin'].toDate(),
          created: data['created'].toDate(),
        );

  String getFullName() {
    return name! + ' ' + lastName!;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'lastName': lastName,
      'id': uid,
      'commision': commision,
      'rol': rol,
      'password': password,
      'email': email,
      'lastLogin': lastLogin,
      'created': created,
    };
  }
}
