import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:folio_software/models/payment_model.dart';
import 'package:intl/intl.dart';
import 'package:folio_software/models/sells_model.dart';
import 'package:folio_software/ui/screens/sells_screen/payments_dialog.dart';
import 'package:folio_software/ui/screens/sells_screen/sells_dialog.dart';
import 'package:folio_software/ui/widgets/colors.dart';
import '../../../services/extensions.dart';
import '../../../services/datetime_services.dart';
import '../../widgets/general_widgets.dart';
import 'actions_icon.dart';

class SellsWidget {
  final BuildContext context;
  final refresh;
  final List<SellsModel> sells;

  SellsWidget(this.context, this.sells, this.refresh);
  var formatter = NumberFormat('###,###,###,000');
  Widget searchWidget(
      {initSearch,
      DateTimeRange? dateRange,
      required String status,
      String? search,
      getSells}) {
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
          initSearch(result, null, null);
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
            Expanded(child: Container()),
            Container(
              height: 50,
              width: 200,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: DropdownButton(
                    value: status,
                    hint: Text('Filtra por status'),
                    items: [
                      DropdownMenuItem(
                        child: Text('Todas'),
                        value: 'Todas',
                      ),
                      DropdownMenuItem(
                        child: Text('Abierta'),
                        value: 'Abierta',
                      ),
                      DropdownMenuItem(
                        child: Text('Cerrada'),
                        value: 'Cerrada',
                      ),
                      DropdownMenuItem(
                        child: Text('Cancelada'),
                        value: 'Cancelada',
                      ),
                    ],
                    onChanged: (val) => initSearch(null, val, null)),
              ),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.grey[100]),
            ),
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
                    onChanged: (value) => initSearch(null, null, value),
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
                    builder: (context) => SellsDialog(sellsModel: SellsModel()),
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

  Widget sellsTable(
      {required page,
      required updatePage,
      required initSearch,
      required List<SellsModel> tempSearchSells,
      DateTimeRange? dateRange,
      required String status,
      String? search,
      required getSells}) {
    List<SellsModel> tempRetos =
        tempSearchSells.isEmpty ? sells : tempSearchSells;
    if ((page * 10) + 1 > tempRetos.length) {
      tempRetos = tempRetos.sublist((page - 1) * 10);
    } else {
      tempRetos = tempRetos.sublist((page - 1) * 10, (page * 10) + 1);
    }

    DataCell ramainCellDate(SellsModel e) {
      List days = e.payments!
          .map(
            (e) => e['date'].toDate().difference(DateTime.now()).inDays,
          )
          .where((element) => element > 0)
          .toList();

      return DataCell(
        Text(days.isEmpty ? '-' : '${days[0]} Dias'),
      );
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
            searchWidget(
              initSearch: initSearch,
              dateRange: dateRange,
              status: status,
            ),
            GeneralWidgets(context).tableWidget(
                context: context,
                columns: [
                  // 'No:',
                  'Reservación:',
                  'Fecha:',
                  'Cliente:',
                  'Tipo:',
                  'Destino:',
                  // 'F. Viaje:',
                  // 'Viajeros:',
                  'Precio:',
                  'Restante:',
                  'S. Pago',
                  '',
                ]
                    .map((e) => DataColumn(
                        label: Text(e,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16))))
                    .toList(),
                rows: tempRetos
                    .map((e) => DataRow(cells: [
                          // DataCell(Text('${e.id}')),
                          DataCell(SizedBox(
                              width: 100,
                              height: 20,
                              child: SelectableText('${e.reservationCode}',
                                  textAlign: TextAlign.center))),
                          DataCell(Text(
                              '${e.date == null ? '-' : DatetimeService().getNumberDate(e.date!)}',
                              textAlign: TextAlign.center)),
                          DataCell(Text(
                              '${e.clientName == null ? '-' : e.clientName!.capitalize()}',
                              textAlign: TextAlign.center)),
                          DataCell(Text(
                              '${e.package == null ? '-' : e.package!.capitalize()}',
                              textAlign: TextAlign.center)),
                          DataCell(Text(
                              '${e.destiny == null ? '-' : e.destiny!.capitalize()}',
                              textAlign: TextAlign.center)),
                          // DataCell(Text(
                          // '${e.travelDate == null ? '-' : DatetimeService().getNumberDate(e.travelDate!)}')),
                          // DataCell(Text('${e.travelers}')),
                          DataCell(Text('\$${formatter.format(e.totalPrice)}',
                              textAlign: TextAlign.center)),
                          DataCell(Text(
                              '\$${formatter.format(e.totalPrice! - e.pago!)}',
                              textAlign: TextAlign.center)),
                          // DataCell(Text('\$${formatter.format(e.pago!)}')),
                          ramainCellDate(e),
                          DataCell(Row(
                            children: [
                              IconButton(
                                  onPressed: (() => showDialog(
                                        context: context,
                                        builder: (context) =>
                                            NextPaymentDialogs(sells: e),
                                      )),
                                  icon: Icon(Icons.receipt)),
                              ActionIcon(
                                editAction: (() async {
                                  var res = await showDialog(
                                    context: context,
                                    builder: (context) =>
                                        SellsDialog(sellsModel: e),
                                  );
                                  print(res);
                                  if (res == true) {
                                    getSells();
                                  }
                                }),
                                deleteAction: () async {
                                  await FirebaseFirestore.instance
                                      .collection('ventas')
                                      .doc(e.id)
                                      .delete();
                                  sells.removeWhere(
                                      (element) => element.id == e.id);

                                  refresh();
                                },
                              ),
                            ],
                          )),
                        ]))
                    .toList(),
                updatePage: updatePage,
                page: page,
                totalItems: sells.length),
          ],
        ),
      ),
    );
  }
}
