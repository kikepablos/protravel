import 'dart:html' as html;
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:folio_software/models/payment_model.dart';
import 'package:folio_software/models/sells_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

import 'datetime_services.dart';

class PdfInvoiceApi {
  var formatter = NumberFormat('###,###,###,000');
  Widget boldAndText(String title, String text) {
    return Row(children: [
      Text('$title: ', style: TextStyle(fontWeight: FontWeight.bold)),
      Text('$text'),
    ]);
  }

  Widget invoiceBody(PaymentModel payment, SellsModel sell, imageLogo) {
    return Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              height: 45,
              child: Image(imageLogo),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              boldAndText('Folio No', '${payment.id}'),
              boldAndText(
                  'Fecha', '${DatetimeService().getNumberDate(payment.date!)}'),
            ])
          ]),
      SizedBox(height: 20),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('ProTravel Eloy Cavazos'),
          Text('Av. Eloy Cavazos 7750, Colonia SCT'),
          Text('CP. 67199 Guadalupe, Nuevo León'),
          boldAndText('Telefono', '81 1104 2944'),
          boldAndText('Correo', 'agenciadeviajes@protravel.mx')
        ]),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          boldAndText('Cliente', '${sell.clientName}'),
          boldAndText('Clave de reservación', '${sell.reservationCode}'),
          boldAndText('Correo', '${sell.clientEmail}'),
          boldAndText('Telefono', '${sell.phone}'),
        ]),
      ]),
      SizedBox(height: 20),
      Table.fromTextArray(
          // headerDecoration: BoxDecoration(
          //   color: PdfColors.grey300,
          // ),
          headerHeight: 30,
          cellHeight: 50,
          border: TableBorder.all(color: PdfColors.grey300),
          cellAlignment: Alignment.center,
          headerStyle: TextStyle(fontWeight: FontWeight.bold),
          headers: [
            'Cantidad',
            'Concepto',
            'Forma de Pago',
            'Importe'
          ],
          data: [
            [
              1,
              sell.package,
              payment.paymentMethod,
              '\$${formatter.format(payment.payment)}'
            ]
          ]),
      SizedBox(height: 10),
      boldAndText('Pago recibido', '${payment.reciver}'),
      SizedBox(height: 15),
      Text(
          'Toda cancelación genera cargos. Antes de 30 dias de su salida de viaje o producto adquirido no se aceptan cancelaciones, con la firma de este recibo se da por enterado que esta de acuerdo a todos los terminos y condiciones de su paquete.',
          style: TextStyle(fontSize: 8)),
      Expanded(child: Container()),
      Row(children: [
        Expanded(child: Container(height: 15, color: PdfColors.blue)),
        Expanded(child: Container(height: 15, color: PdfColors.blue300)),
        Expanded(child: Container(height: 15, color: PdfColors.blue100)),
        Expanded(child: Container(height: 15, color: PdfColors.yellow)),
        Expanded(child: Container(height: 15, color: PdfColors.yellow900)),
        Expanded(child: Container(height: 15, color: PdfColors.red300)),
        Expanded(child: Container(height: 15, color: PdfColors.red)),
      ]),
    ]);
  }

  Future<Uint8List> generate(PaymentModel payment, SellsModel sell) async {
    final pdf = Document();
//  rootBundle.load('assets/img/your_image.jpg').
    MemoryImage imageLogo = MemoryImage(
        (await rootBundle.load('assets/logo_blue.png')).buffer.asUint8List());
    pdf.addPage(
      Page(
          pageFormat: PdfPageFormat.a4,
          build: (Context context) {
            return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: invoiceBody(payment, sell, imageLogo),
                  ),
                  SizedBox(height: 20),
                  Row(children: [
                    Expanded(
                        child: Container(height: 1, color: PdfColors.grey100))
                  ]),
                  SizedBox(height: 20),
                  Expanded(child: invoiceBody(payment, sell, imageLogo))
                ]);
          }),
    );
    Uint8List pdfInBytes = await pdf.save();
    return pdfInBytes;
  }

  openPDF(Uint8List pdfFIle, PaymentModel payment) {
    final blob = html.Blob([pdfFIle], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = 'recibo_${payment.id}.pdf';
    html.document.body!.children.add(anchor);
    anchor.click();
  }
}
