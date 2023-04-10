import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:folio_software/models/payment_model.dart';
import 'package:folio_software/models/sells_model.dart';
import 'package:folio_software/ui/screens/dashboard_screen/dashboard_widgets.dart';

import '../../widgets/general_widgets.dart';

class DashboardScreen extends StatefulWidget {
  DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<SellsModel> sells = [];
  List<PaymentModel> payments = [];

  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    QuerySnapshot<Map<String, dynamic>> pSnap = await FirebaseFirestore.instance
        .collection('pagos')
        .orderBy('date', descending: true)
        .get();
    QuerySnapshot<Map<String, dynamic>> sellsSnap = await FirebaseFirestore
        .instance
        .collection('ventas')
        .orderBy('date', descending: true)
        .get();

    setState(() {
      sells = sellsSnap.docs
          .map((e) => SellsModel.fromMap(e.data(), e.id))
          .toList();
      payments =
          pSnap.docs.map((e) => PaymentModel.fromMap(e.data(), e.id)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    DashboardWidgets dashboardWidgets =
        DashboardWidgets(context, sells, payments);
    return Container(
        height: MediaQuery.of(context).size.height,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GeneralWidgets(context).appBarWidget(
              'Dashboard', 'Informacion general sobre tu negocio'),
          SizedBox(
            height: 20,
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  dashboardWidgets.topWidget(),
                  SizedBox(
                    height: 20,
                  ),
                  dashboardWidgets.topCharts()
                ],
              ),
            ),
          ),
        ]));
  }
}
