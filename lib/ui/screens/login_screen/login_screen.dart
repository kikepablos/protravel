import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:folio_software/models/user_model.dart';
import 'package:folio_software/services/state_service.dart';
import 'package:line_icons/line_icon.dart';

import '../../widgets/colors.dart';
import '../../widgets/dialogs.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onSignedIn;
  final VoidCallback onSignedOut;
  LoginPage({Key? key, required this.onSignedIn, required this.onSignedOut})
      : super(key: key);
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isHidden = true;
  String? password;
  String? email;

  Future<void> validateAndSubmit() async {
    try {
      Dialogs().showLoadingDialog('inicando sesion', context);
      UserCredential user = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email!, password: password!);
      String uid = user.user!.uid;
      Navigator.pop(context);
      DocumentSnapshot<Map<String, dynamic>> userData =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      UserModel userModel = UserModel.froMap(userData.data()!, userData.id);
      setState(() {
        UpdateUser(userModel);
      });
      widget.onSignedIn();
      Navigator.maybePop(context);
      Navigator.pop(context);
    } catch (e) {
      print(e);
      Navigator.pop(context);
      Dialogs()
          .showErrorDialog('Ha sucedido un error al iniciar sesion', context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: secundaryColor,
      body: Center(
        child: Container(
          alignment: Alignment.center,
          width: 500,
          child: Padding(
            padding: const EdgeInsets.only(left: 40, right: 40, bottom: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Container(
                //   child: Image.asset('assets/logo.png'),
                //   width: double.infinity,
                // ),
                // Padding(
                //   padding: const EdgeInsets.only(left: 20, right: 20, top: 50),
                //   child: Text(
                //     'Folios',
                //     textAlign: TextAlign.center,
                //     style: TextStyle(
                //         fontFamily: 'BungeeInline',
                //         color: Colors.white,
                //         fontSize: 52),
                //   ),
                // ),
                SizedBox(
                  child: Image.asset('assets/logo_white.png'),
                ),
                // SizedBox(
                //   height: 20,
                // ),
                Text(
                  "Inicia Sesion",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  style: TextStyle(color: Colors.white),
                  onChanged: (val) => email = val,
                  decoration: InputDecoration(
                    focusColor: Colors.white,
                    // fillColor: appColor,
                    iconColor: Colors.white,
                    labelText: 'Correo',
                    prefixIcon: Icon(
                      Icons.mail,
                      color: Colors.white,
                    ),
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 1.0),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 1.0),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.white, width: 2.0),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Necesitas llenar este espacio';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  style: TextStyle(color: Colors.white),
                  onChanged: (val) => password = val,
                  decoration: InputDecoration(
                      focusColor: Colors.white,
                      prefixIconColor: Colors.white,
                      fillColor: Colors.white,
                      suffixIconColor: Colors.white,
                      iconColor: Colors.white,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            isHidden = isHidden ? false : true;
                          });
                        },
                        icon: Icon(isHidden
                            ? LineIcon.eyeSlash().icon
                            : LineIcon.eye().icon),
                        color: Colors.white,
                      ),
                      labelText: 'Contraseña',
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 1.0),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 1.0),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.white, width: 2.0),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      prefixIcon: Icon(
                        Icons.lock,
                        color: Colors.white,
                      )),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Necesitas llenar este espacio';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                        ),
                        onPressed: () {
                          validateAndSubmit();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Iniciar sesion",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: appColor),
                          ),
                        ))),
              ],
            ),
          ),
          height: 440,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: appColor,
            boxShadow: [
              BoxShadow(
                  color: Colors.green[900]!, spreadRadius: .8, blurRadius: 5)
            ],
          ),
        ),
      ),
    );
  }
}
