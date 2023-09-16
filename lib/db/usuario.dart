//import 'package:flutter/material.dart';

class UserModel {
  final int id = 0;
  final String name = "";
  final String password = "";
  final String rpassword = "";
  final String res = "";

  UserModel(
      {int? id,
      String? name,
      String? password,
      String? rpassword,
      String? res});

  UserModel copyWith(
      {int? id,
      String? name,
      String? password,
      String? rpassword,
      String? res}) {
    return UserModel(
        id: id ?? this.id,
        name: name ?? this.name,
        password: password ?? this.password,
        rpassword: rpassword ?? this.rpassword,
        res: res ?? this.res);
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
        id: map['id'],
        name: map['name'],
        password: map['password'],
        rpassword: map['rpassword'],
        res: map['res']);
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'password': password,
        'rpassword': rpassword,
        'res': res
      };
}
