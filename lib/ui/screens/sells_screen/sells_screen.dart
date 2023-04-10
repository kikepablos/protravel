import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:folio_software/models/sells_model.dart';
import 'package:folio_software/services/extensions.dart';
import 'package:folio_software/services/state_service.dart';
import 'package:folio_software/ui/screens/sells_screen/sells_widget.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../widgets/general_widgets.dart';

class SellScreen extends StatefulWidget {
  SellScreen({Key? key}) : super(key: key);

  @override
  State<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> {
  AppStore store = VxState.store;
  List<SellsModel> sells = [];
  List<SellsModel> tempSearchSells = [];
  int? page = 1;
  DateTimeRange? dateRange;
  String status = 'Todas';
  String? search;

  updatePage(val) {
    setState(() {
      page = val;
    });
  }

  @override
  void initState() {
    getSells();
    super.initState();
  }

  getSells() async {
    QuerySnapshot<Map<String, dynamic>> sellsSnap = await FirebaseFirestore
        .instance
        .collection('ventas')
        .orderBy('date', descending: true)
        .get();

    setState(() {
      sells = sellsSnap.docs
          .map((e) => SellsModel.fromMap(e.data(), e.id))
          .toList();
    });
  }

  initSearch(DateTimeRange? range, String? stat, String? sea) {
    if (range != null) {
      setState(() {
        dateRange = range;
      });
    }
    setState(() {
      status = stat ?? 'Todas';
    });

    if (sea != null) {
      setState(() {
        search = sea;
      });
    }
    handleSearch();
  }

  handleSearch() {
    List<SellsModel> tempSearch = sells;

    if (dateRange != null) {
      print(dateRange);
      tempSearch = tempSearch
          .where((element) =>
              element.date!.isAfter(dateRange!.start) &&
              element.date!.isBefore(dateRange!.end))
          .toList();
    }
    if (status != 'Todas') {
      tempSearch =
          tempSearch.where((element) => element.status == status).toList();
    } else {
      tempSearch = sells.toList();
    }
    if (search != null) {
      tempSearch = tempSearch
          .where((element) =>
              element.clientName!.toLowerCase().contains(search!) ||
              element.reservationCode!.toLowerCase().contains(search!))
          .toList();
    }

    setState(() {
      tempSearchSells = tempSearch;
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
              .appBarWidget('Ventas', 'Informacion general sobre tus ventas'),
          SizedBox(
            height: 20,
          ),
          SellsWidget(context, sells, refresh).sellsTable(
              page: page,
              updatePage: updatePage,
              initSearch: initSearch,
              tempSearchSells: tempSearchSells,
              dateRange: dateRange,
              status: status,
              search: search,
              getSells: getSells)
        ],
      ),
    );
  }
}
