import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:folio_software/ui/widgets/colors.dart';
import 'package:line_icons/line_icon.dart';

Widget controllerBar(context, selectedIndex, updateIndex, onSignOut) {
  List<IconData> icons = [
    // Icons.dashboard_rounded,
    LineIcon.receipt().icon!,
    LineIcon.wavyMoneyBill().icon!,
    LineIcon.users().icon!,
  ];
  List<String> titles = [
    'Ventas',
    'Pagos',
    'Usuarios',
  ];
  return Container(
    height: MediaQuery.of(context).size.height,
    width: MediaQuery.of(context).size.width * 0.15,
    decoration: BoxDecoration(
      color: appColor,
      // boxShadow: [
      //   BoxShadow(
      //     color: Colors.grey.withOpacity(0.5),
      //     spreadRadius: 5,
      //     blurRadius: 7,
      //     offset: Offset(0, 3), // changes position of shadow
      //   ),
      // ],
    ),
    child: Padding(
      padding: const EdgeInsets.only(
        top: 20,
      ),
      child: Column(
        children: [
          // Padding(
          //   padding: const EdgeInsets.only(left: 20, right: 20, top: 50),
          //   child: Text(
          //     'Folios',
          //     textAlign: TextAlign.center,
          //     style: TextStyle(color: Colors.white, fontSize: 32),
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Image.asset('assets/logo_white.png'),
          ),
          SizedBox(
            height: 80,
          ),
          for (var i = 0; i < titles.length; i++)
            Padding(
              padding: const EdgeInsets.only(left: 20.0, bottom: 10),
              child: GestureDetector(
                onTap: () => updateIndex(i),
                child: Container(
                  height: 40,
                  color: Colors.transparent,
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    children: [
                      Icon(icons[i],
                          size: 30,
                          color: selectedIndex == i
                              ? Colors.white
                              : Colors.grey[400]),
                      SizedBox(width: 10),
                      Expanded(
                          child: Text(
                        titles[i],
                        style: TextStyle(
                            color: selectedIndex == i
                                ? Colors.white
                                : Colors.grey[400],
                            fontWeight: selectedIndex == i
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 16),
                      )),
                      if (selectedIndex == i)
                        Container(
                          width: 3,
                          height: 40,
                          color: Colors.white,
                        )
                    ],
                  ),
                ),
              ),
            ),
          Expanded(child: Container()),
          TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                onSignOut();
              },
              child: Text('Cerrar sesión'))
        ],
      ),
    ),
  );
}
