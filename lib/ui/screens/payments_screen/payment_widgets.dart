import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:folio_software/models/payment_model.dart';
import 'package:folio_software/models/sells_model.dart';
import 'package:folio_software/services/pdf_invoice_api.dart';
import 'package:folio_software/services/sells_services.dart';
import 'package:folio_software/ui/screens/payments_screen/payment_dialog.dart';

import '../../../services/datetime_services.dart';
import '../../widgets/colors.dart';
import '../../widgets/general_widgets.dart';

class PaymentWidgets {
  final BuildContext context;
  final List<PaymentModel> payments;
  final refresh;
  PaymentWidgets(this.context, this.payments, this.refresh);

  Widget searchWidget(
      initSearch, DateTimeRange? dateRange, String? search, getSells) {
    Widget datePickerButton(bool isFrom) {
      return GestureDetector(
        onTap: () async {
          DateTimeRange? result = await showDateRangePicker(
            context: context,
            firstDate: DateTime(2022, 1, 1), // the earliest allowable
            lastDate: DateTime(2030, 12, 31),
            // .add(Duration(days: 1)), // the latest allowable
            currentDate: DateTime.now(),
            saveText: 'Continuar',
          );
          initSearch(result, null);
        },
        child: Container(
          height: 50,
          width: 200,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Icon(Icons.calendar_month),
                SizedBox(
                  width: 10,
                ),
                Text(dateRange != null
                    ? isFrom
                        ? DatetimeService().getNumberDate(dateRange.start)
                        : DatetimeService().getNumberDate(dateRange.end)
                    : isFrom
                        ? 'De'
                        : 'Hasta'),
              ],
            ),
          ),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5), color: Colors.grey[100]),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(children: [
            datePickerButton(true),
            SizedBox(
              width: 10,
            ),
            datePickerButton(false),
          ]),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 50,
                  child: TextField(
                    onChanged: (value) => initSearch(null, value),
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                        hintText: 'Buscar',
                        prefixIcon: Icon(Icons.search)),
                  ),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.grey[100]),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              GestureDetector(
                onTap: () async {
                  var res = await showDialog(
                    context: context,
                    builder: (context) =>
                        PaymentDialog(payment: PaymentModel()),
                  );
                  print(res);
                  if (res == true) {
                    getSells();
                  }
                },
                child: Container(
                  height: 50,
                  child: Center(
                    child: Text(
                      'Nueva venta',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white),
                    ),
                  ),
                  width: 150,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5), color: appColor),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget paymentsTable(
      {required page,
      required updatePage,
      required initSearch,
      required List<PaymentModel> tempSearchPayments,
      DateTimeRange? dateRange,
      String? search,
      required getPayments}) {
    List<PaymentModel> tempRetos =
        tempSearchPayments.isEmpty ? payments : tempSearchPayments;
    if ((page * 10) + 1 > tempRetos.length) {
      tempRetos = tempRetos.sublist((page - 1) * 10);
    } else {
      tempRetos = tempRetos.sublist((page - 1) * 10, (page * 10) + 1);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.grey[400]!, spreadRadius: .8, blurRadius: 5)
            ]),
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            searchWidget(initSearch, dateRange, search, getPayments),
            GeneralWidgets(context).tableWidget(
                context: context,
                columns: [
                  'Folio:',
                  'Reservación:',
                  'Fecha:',
                  'Monto:',
                  'Metodo de pago:',
                  'Receptor:',
                  'Acciones:',
                ]
                    .map((e) => DataColumn(
                        label: Text(e,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16))))
                    .toList(),
                rows: tempRetos
                    .map((e) => DataRow(cells: [
                          // DataCell(Text('${e.id}')),
                          DataCell(Text('${e.id}')),
                          DataCell(Text('${e.reservationCode}')),
                          DataCell(Text(
                              '${e.date == null ? '-' : DatetimeService().getNumberDate(e.date!)}')),
                          DataCell(Text('\$${e.payment}')),
                          DataCell(Text('${e.paymentMethod}')),
                          DataCell(Text('${e.reciver}')),
                          DataCell(Row(
                            children: [
                              IconButton(
                                  onPressed: (() async {
                                    var res = await showDialog(
                                      context: context,
                                      builder: (context) =>
                                          PaymentDialog(payment: e),
                                    );
                                    print(res);
                                    if (res == true) {
                                      getPayments();
                                    }
                                  }),
                                  icon: Icon(Icons.edit)),
                              IconButton(
                                  onPressed: (() async {
                                    await FirebaseFirestore.instance
                                        .collection('pagos')
                                        .doc(e.id)
                                        .delete();
                                    QuerySnapshot<Map<String, dynamic>> vSnap =
                                        await FirebaseFirestore.instance
                                            .collection('ventas')
                                            .where('reservationCode',
                                                isEqualTo: e.reservationCode)
                                            .get();
                                    num p = vSnap.docs[0]['pago'] - e.payment!;
                                    await FirebaseFirestore.instance
                                        .collection('ventas')
                                        .doc(vSnap.docs[0].id)
                                        .update({'pago': p});
                                    payments.removeWhere(
                                        (element) => element.id == e.id);
                                    refresh();
                                  }),
                                  icon: Icon(Icons.delete)),
                              IconButton(
                                  onPressed: () async {
                                    print(e.reservationCode);
                                    DocumentSnapshot<Map<String, dynamic>>
                                        sSnap = await FirebaseFirestore.instance
                                            .collection('ventas')
                                            .doc('${e.reservationCode}')
                                            .get();
                                    Uint8List pdfBytes = await PdfInvoiceApi()
                                        .generate(
                                            e,
                                            SellsModel.fromMap(
                                                sSnap.data()!, sSnap.id));
                                    PdfInvoiceApi().openPDF(
                                      pdfBytes,
                                      e,
                                    );
                                  },
                                  icon: Icon(Icons.download))
                            ],
                          )),
                        ]))
                    .toList(),
                updatePage: updatePage,
                page: page,
                totalItems: payments.length),
          ],
        ),
      ),
    );
  }
}
