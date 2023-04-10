import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:folio_software/models/payment_model.dart';
import 'package:folio_software/models/sells_model.dart';
import 'package:folio_software/services/extensions.dart';
import 'package:folio_software/ui/screens/payments_screen/payment_widgets.dart';
import '../../widgets/general_widgets.dart';

class PaymentScreen extends StatefulWidget {
  PaymentScreen({Key? key}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  List<PaymentModel> payments = [];
  List<PaymentModel> tempSearchPayments = [];
  int? page = 1;
  DateTimeRange? dateRange;
  String? search;

  updatePage(val) {
    setState(() {
      page = val;
    });
  }

  @override
  void initState() {
    super.initState();
    getPayments();
  }

  getPayments() async {
    QuerySnapshot<Map<String, dynamic>> pSnap = await FirebaseFirestore.instance
        .collection('pagos')
        .orderBy('date', descending: true)
        .get();
    setState(() {
      payments =
          pSnap.docs.map((e) => PaymentModel.fromMap(e.data(), e.id)).toList();
    });
    // List<String?> reservationC =
    //     payments.map((e) => e.reservationCode).toSet().toList();
    // Map fMap = {};
    // reservationC.forEach((element) {
    //   List<PaymentModel> r =
    //       payments.where((e) => e.reservationCode == element).toList();
    //   num? total = r.map((e) => e.payment).toList().reduce((a, b) => a! + b!);
    //   fMap[element] = total;
    // });

    // QuerySnapshot<Map<String, dynamic>> sSnap =
    //     await FirebaseFirestore.instance.collection('ventas').get();
    // List<SellsModel> sells =
    //     sSnap.docs.map((e) => SellsModel.fromMap(e.data(), e.id)).toList();

    // sells.forEach((element) {
    //   if (fMap.containsKey(element.reservationCode)) {
    //     element.pago = fMap[element.reservationCode];
    //   }
    //   FirebaseFirestore.instance
    //       .collection('ventas')
    //       .doc(element.id)
    //       .update(element.toJson());
    // });
  }

  initSearch(DateTimeRange? range, String? sea) {
    if (range != null) {
      setState(() {
        dateRange = range;
      });
    }

    if (sea != null) {
      setState(() {
        search = sea;
      });
    }
    handleSearch();
  }

  handleSearch() {
    List<PaymentModel> tempSearch = payments;

    if (dateRange != null) {
      print(dateRange);
      tempSearch = tempSearch
          .where((element) =>
              element.date!.isAfter(dateRange!.start) &&
              element.date!.isBefore(dateRange!.end))
          .toList();
    }
    if (search != null) {
      tempSearch = tempSearch
          .where((element) =>
              element.reservationCode!.toLowerCase().contains(search!))
          .toList();
    }

    setState(() {
      tempSearchPayments = tempSearch;
    });
  }

  refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GeneralWidgets(context)
              .appBarWidget('Pagos', 'Informacion general sobre tus pagos'),
          SizedBox(
            height: 20,
          ),
          PaymentWidgets(context, payments, refresh).paymentsTable(
              page: page,
              updatePage: updatePage,
              initSearch: initSearch,
              tempSearchPayments: tempSearchPayments,
              getPayments: getPayments)
        ],
      ),
    );
  }
}
