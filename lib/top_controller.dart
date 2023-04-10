import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:folio_software/models/user_model.dart';
import 'package:folio_software/services/state_service.dart';
import 'package:folio_software/ui/screens/dashboard_screen/dashboard_screen.dart';
import 'package:folio_software/ui/screens/payments_screen/payments_screen.dart';
import 'package:folio_software/ui/screens/sells_screen/sells_screen.dart';
import 'package:folio_software/ui/widgets/controller_bar.dart';

import 'ui/screens/users_screen/users_screen.dart';

class TopController extends StatefulWidget {
  final onSignedOut;
  TopController({Key? key, this.onSignedOut}) : super(key: key);
  @override
  _TopControllerState createState() => _TopControllerState();
}

class _TopControllerState extends State<TopController> {
  int selectedIndex = 0;

  updateIndex(i) {
    setState(() {
      selectedIndex = i;
    });
  }

  @override
  void initState() {
    getUser();
    super.initState();
  }

  getUser() async {
    String userUID = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot<Map<String, dynamic>> userSnap =
        await FirebaseFirestore.instance.collection('users').doc(userUID).get();
    FirebaseFirestore.instance
        .collection('users')
        .doc(userUID)
        .update({'lastLogin': DateTime.now()});
    setState(() {
      UpdateUser(UserModel.froMap(userSnap.data()!, userSnap.id));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          controllerBar(
              context, selectedIndex, updateIndex, widget.onSignedOut),
          Expanded(
              child: [
            SellScreen(),
            PaymentScreen(),
            UserScreen()
          ][selectedIndex])
        ],
      ),
    );
  }
}
