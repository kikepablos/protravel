import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:folio_software/models/payment_model.dart';
import 'package:folio_software/models/sells_model.dart';
import 'package:folio_software/services/state_service.dart';
import 'package:folio_software/ui/screens/payments_screen/payment_dialog.dart';
import 'package:intl/intl.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../../services/datetime_services.dart';
import '../../../services/pdf_invoice_api.dart';
import '../../widgets/general_widgets.dart';

class NextPaymentDialogs extends StatefulWidget {
  final SellsModel sells;
  NextPaymentDialogs({Key? key, required this.sells}) : super(key: key);

  @override
  State<NextPaymentDialogs> createState() => _NextPaymentDialogsState();
}

class _NextPaymentDialogsState extends State<NextPaymentDialogs> {
  num initalPayment = 0;
  AppStore store = VxState.store;
  var formatter = NumberFormat('###,###,###,000.00');
  List<Map> payments = [];
  List<PaymentModel> cPayments = [];

  @override
  void initState() {
    getPayments();
    super.initState();
  }

  getPayments() async {
    QuerySnapshot<Map<String, dynamic>> pSnap = await FirebaseFirestore.instance
        .collection('pagos')
        .where('reservationCode', isEqualTo: widget.sells.reservationCode)
        .get();

    setState(() {
      cPayments =
          pSnap.docs.map((e) => PaymentModel.fromMap(e.data(), e.id)).toList();
    });
  }

  // initPayments() {
  //   switch (widget.sells.package) {
  //     case 'Magni Charter':
  //       num initPayment = widget.sells.travelers! * 200;
  //       num half = (widget.sells.totalPrice! - initPayment) / 2;
  //       payments.add({
  //         'name': 'Pago inicial',
  //         'date': widget.sells.date,
  //         'amount': initPayment
  //       });
  //       payments.add({
  //         'name': '50%',
  //         'date': widget.sells.travelDate!.subtract(Duration(days: 30)),
  //         'amount': half
  //       });
  //       payments.add({
  //         'name': 'Liquidación',
  //         'date': widget.sells.travelDate!.subtract(Duration(days: 15)),
  //         'amount': half
  //       });
  //       break;
  //     case 'Euromundo':
  //       num initPayment = widget.sells.travelers! * 500;
  //       num second = widget.sells.travelers! *
  //           (widget.sells.season == 'Temporada Baja' ? 2000 : 3000);
  //       ;
  //       payments.add({
  //         'name': 'Pago inicial',
  //         'date': widget.sells.date,
  //         'amount': initPayment
  //       });
  //       payments.add({
  //         'name': 'Segundo Pago',
  //         'date': widget.sells.date!.subtract(Duration(
  //             days: widget.sells.season == 'Temporada Alta' ? 60 : 35)),
  //         'amount': second
  //       });
  //       payments.add({
  //         'name': 'Liquidación',
  //         'date': widget.sells.date!.subtract(
  //             Duration(days: widget.sells.season == 'Temporada Alta' ? 30 : 8)),
  //         'amount': widget.sells.totalPrice! - initPayment - second
  //       });
  //       break;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        backgroundColor: Colors.white,
        child: SizedBox(
            // height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width * 0.4,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Desgloce de pagos',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 22),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    RichText(
                      text: TextSpan(
                        text: 'Codigo de reservación: ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                        children: <TextSpan>[
                          TextSpan(
                              text: '${widget.sells.reservationCode}',
                              style: TextStyle(fontWeight: FontWeight.normal)),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    RichText(
                      text: TextSpan(
                        text: 'Vendedor: ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                        children: <TextSpan>[
                          TextSpan(
                              text: '${widget.sells.sellerName}',
                              style: TextStyle(fontWeight: FontWeight.normal)),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    RichText(
                      text: TextSpan(
                        text: 'Viajeros: ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                        children: <TextSpan>[
                          TextSpan(
                              text: '${widget.sells.travelers}',
                              style: TextStyle(fontWeight: FontWeight.normal)),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    RichText(
                      text: TextSpan(
                        text: 'Paquete: ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                        children: <TextSpan>[
                          TextSpan(
                              text: '${widget.sells.package}',
                              style: TextStyle(fontWeight: FontWeight.normal)),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    if (widget.sells.package == 'Euromundo')
                      Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: RichText(
                          text: TextSpan(
                            text: 'Temporada: ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                            children: <TextSpan>[
                              TextSpan(
                                  text: '${widget.sells.season}',
                                  style:
                                      TextStyle(fontWeight: FontWeight.normal)),
                            ],
                          ),
                        ),
                      ),

                    RichText(
                      text: TextSpan(
                        text: 'Fecha del Viaje: ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                        children: <TextSpan>[
                          TextSpan(
                              text:
                                  '${DatetimeService().getNumberDate(widget.sells.travelDate!)}',
                              style: TextStyle(fontWeight: FontWeight.normal)),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    RichText(
                      text: TextSpan(
                        text: 'Precio total: ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                        children: <TextSpan>[
                          TextSpan(
                              text:
                                  '\$${formatter.format(widget.sells.totalPrice)}',
                              style: TextStyle(fontWeight: FontWeight.normal)),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Text(
                      'Estructura de pagos:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                    ),
                    DataTable(
                      columns: [
                        'Pago:',
                        'Cantidad:',
                        'Fecha Limite:',
                        'Status:'
                      ]
                          .map((e) => DataColumn(
                              label: Text(e,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16))))
                          .toList(),
                      showBottomBorder: true,
                      rows: widget.sells.payments!
                          .map((e) => DataRow(cells: [
                                DataCell(Text(e['name'])),
                                DataCell(
                                    Text('\$${formatter.format(e['amount'])}')),
                                DataCell(Text(
                                    '${DatetimeService().getNumberDate(e['date'].toDate())}')),
                                DataCell(cPayments
                                        .map((e) => e.desc)
                                        .contains(e['name'])
                                    ? Text(
                                        'Pagado (${cPayments.where((element) => element.desc == e['name']).first.id})',
                                        style:
                                            TextStyle(color: Colors.green[800]),
                                      )
                                    : TextButton(
                                        onPressed: () => showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  PaymentDialog(
                                                      payment: PaymentModel(
                                                          created:
                                                              DateTime.now(),
                                                          desc: e['name'],
                                                          date: DateTime.now(),
                                                          payment: e['amount'],
                                                          reservationCode: widget
                                                              .sells
                                                              .reservationCode,
                                                          reciver: store.user
                                                              .getFullName(),
                                                          reciverUID:
                                                              store.user.uid)),
                                            ),
                                        child: Text('Pagar'))),
                              ]))
                          .toList(),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      'Pagos completados:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                    ),
                    SizedBox(
                      height: 20,
                    ),

                    GeneralWidgets(context).tableWidget(
                        context: context,
                        columns: ['Folio:', 'Cantidad:', 'Fecha:', 'Acciónes']
                            .map((e) => DataColumn(
                                label: Text(e,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16))))
                            .toList(),
                        rows: cPayments
                            .map((e) => DataRow(cells: [
                                  DataCell(Text(e.id!)),
                                  DataCell(
                                      Text('\$${formatter.format(e.payment)}')),
                                  DataCell(Text(
                                      '${DatetimeService().getNumberDate(e.date!)}')),
                                  DataCell(IconButton(
                                      onPressed: () async {
                                        Uint8List pdfBytes =
                                            await PdfInvoiceApi()
                                                .generate(e, widget.sells);
                                        PdfInvoiceApi().openPDF(
                                          pdfBytes,
                                          e,
                                        );
                                      },
                                      icon: Icon(Icons.download))),
                                ]))
                            .toList(),
                        updatePage: () {},
                        page: 1,
                        totalItems: payments.length),
                    // RichText(
                    //   text: TextSpan(
                    //     text: 'Pago inicial: ',
                    //     style:
                    //         TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    //     children: <TextSpan>[
                    //       TextSpan(
                    //           text: '\$$initalPayment',
                    //           style: TextStyle(fontWeight: FontWeight.normal)),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ),
            )));
  }
}
