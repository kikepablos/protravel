import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:folio_software/models/sells_model.dart';
import 'package:folio_software/models/user_model.dart';
import 'package:folio_software/ui/screens/users_screen/user_widgets.dart';
import 'package:folio_software/ui/widgets/dialogs.dart';

import '../../widgets/general_widgets.dart';

class UserScreen extends StatefulWidget {
  UserScreen({Key? key}) : super(key: key);

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  List<UserModel> users = [];
  List<SellsModel> sells = [];
  DateTimeRange? dateRange;
  Map sellMap = {};

  @override
  void initState() {
    getUsers();
    super.initState();
  }

  getUsers() async {
    QuerySnapshot<Map<String, dynamic>> uSnap =
        await FirebaseFirestore.instance.collection('users').get();
    // print(uSnap.docs.length);\
    QuerySnapshot<Map<String, dynamic>> sSnap;

    // print(sSnap.docs.length);
    if (dateRange == null) {
      sSnap = await FirebaseFirestore.instance.collection('ventas').get();
      sells =
          sSnap.docs.map((e) => SellsModel.fromMap(e.data(), e.id)).toList();
    } else {
      sSnap = await FirebaseFirestore.instance
          .collection('ventas')
          .where('date', isGreaterThanOrEqualTo: dateRange!.start)
          .where('date', isLessThanOrEqualTo: dateRange!.end)
          .get();
      sells =
          sSnap.docs.map((e) => SellsModel.fromMap(e.data(), e.id)).toList();
    }
    setState(() {
      users = uSnap.docs.map((e) => UserModel.froMap(e.data(), e.id)).toList();
      sellMap = Map.fromIterable(
        users,
        key: (element) => element.uid,
        value: (element) {
          List<SellsModel> uSells =
              sells.where((s) => s.sellerUID == element.uid).toList();
          if (uSells.length == 0) {
            return {'sells': 0, 'comision': 0};
          }
          num tSells =
              uSells.map((e) => e.totalPrice).reduce((a, b) => a! + b!)!;
          return {'sells': tSells, 'comision': tSells * element.commision};
        },
      );
    });
  }

  upadateRange(DateTimeRange? range) {
    setState(() {
      dateRange = range;
    });
    getUsers();
  }

  refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (sellMap.isEmpty) {
      return Container(
        child: Dialogs().loadingWidget(),
      );
    }
    UserWidgets userWidgets =
        UserWidgets(context, users, refresh, sells, sellMap);
    return Container(
      height: MediaQuery.of(context).size.height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GeneralWidgets(context).appBarWidget(
              'Usuarios', 'Informacion general sobre tus usuarios'),
          SizedBox(
            height: 20,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    userWidgets.topWidget(dateRange, upadateRange),
                    SizedBox(
                      height: 20,
                    ),
                    userWidgets.graphWidget(),
                    SizedBox(
                      height: 20,
                    ),
                    userWidgets.usersTable(upadateRange)
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
