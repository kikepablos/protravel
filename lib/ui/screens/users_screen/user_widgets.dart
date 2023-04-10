import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:folio_software/models/sells_model.dart';
import 'package:folio_software/models/user_model.dart';
import 'package:charts_flutter_new/flutter.dart' as charts;
import 'package:folio_software/ui/screens/users_screen/newuser_dialog.dart';
import 'package:folio_software/ui/widgets/charts/bar_charts.dart';
import 'package:folio_software/ui/widgets/dialogs.dart';
import '../../../services/datetime_services.dart';
import 'package:intl/intl.dart';

import '../../widgets/colors.dart';
import '../../widgets/general_widgets.dart';

class UserWidgets {
  final BuildContext context;
  final List<SellsModel> sells;
  final List<UserModel> users;
  final Map sellsMap;
  final refresh;

  UserWidgets(
      this.context, this.users, this.refresh, this.sells, this.sellsMap);
  var formatter = NumberFormat('###,###,###,000');
  Widget datePickerButton(bool isFrom, DateTimeRange? dateRange, upadateRange) {
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
        upadateRange(result);
        // initSearch(result, null);
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

  Widget topWidget(DateTimeRange? dateRange, upadateRange) {
    List c = sellsMap.values
        .map(
          (e) => e['comision'],
        )
        .toList();
    return Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('${users.length}',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                        Text(
                          'Total de usuarios',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                            '\$${formatter.format(c.reduce((a, b) => a! + b!))}',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                        Text(
                          'Comisones totales',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                            '\$${formatter.format(c.reduce((a, b) => a! + b!) / users.length)}',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                        Text(
                          'Promedio por usuario',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              datePickerButton(true, dateRange, upadateRange),
              SizedBox(
                width: 20,
              ),
              datePickerButton(false, dateRange, upadateRange),
              SizedBox(
                width: 20,
              ),
              GestureDetector(
                onTap: () => showDialog(
                  context: context,
                  builder: (context) => NewUserDialog(
                    updateUsers: upadateRange,
                    user: UserModel(),
                  ),
                ),
                child: Container(
                  height: 50,
                  child: Center(
                    child: Text(
                      'Nueva Usuario',
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
          ),
        ),
        height: 75,
        width: double.infinity,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.grey[300]!, spreadRadius: .8, blurRadius: 5)
            ]));
  }

  Widget graphWidget() {
    List<OrdinalSales> data = sellsMap.keys
        .map(
          (e) => OrdinalSales(
              users
                  .where((element) => element.uid == e)
                  .toList()[0]
                  .getFullName(),
              sellsMap[e]['comision']),
        )
        .toList();

    List<charts.Series<OrdinalSales, String>> d = [
      new charts.Series<OrdinalSales, String>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        labelAccessorFn: (OrdinalSales sales, _) =>
            '\$${formatter.format(sales.sales)}',
        data: data,
      )
    ];
    return Container(
      height: 500,
      width: double.infinity,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.grey[300]!, spreadRadius: .8, blurRadius: 5)
          ]),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Comisiones por usuarios'),
          Expanded(
              child: SimpleBarChart(
            d,
            animate: true,
          ))
        ]),
      ),
    );
  }

  Widget usersTable(upadateRange) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.grey[400]!, spreadRadius: .8, blurRadius: 5)
          ]),
      child: Column(
        children: [
          GeneralWidgets(context).tableWidget(
              context: context,
              columns: [
                // 'No:',
                'Nombre:',
                'Email:',
                'Ultima conexión:',
                'Rol',
                '% Comisión',
                'Comisión',
                'Ventas',
                'Acciones',
              ]
                  .map((e) => DataColumn(
                      label: Text(e,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16))))
                  .toList(),
              rows: users
                  .map((e) => DataRow(cells: [
                        // DataCell(Text('${e.id}')),
                        DataCell(Text('${e.getFullName()}')),
                        DataCell(Text('${e.email}')),
                        DataCell(Text(
                            '${DatetimeService().getNumberDate(e.lastLogin!)} ${DatetimeService().formatHour(e.lastLogin!)}')),
                        DataCell(Text('${e.rol}')),
                        DataCell(Text('${e.commision! * 100}%')),
                        DataCell(Text(
                            "\$${formatter.format(sellsMap[e.uid]['comision'])}")),
                        DataCell(Text(
                            "\$${formatter.format(sellsMap[e.uid]['sells'])}")),
                        DataCell(Row(
                          children: [
                            IconButton(
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) => NewUserDialog(
                                          updateUsers: upadateRange, user: e));
                                },
                                icon: Icon(Icons.edit)),
                            IconButton(
                                onPressed: () async {
                                  Dialogs().showErrorDialog(
                                      'Borrando usuario', context);
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(e.uid)
                                      .delete();
                                  Navigator.pop(context);
                                  Dialogs().showAlertDialog(
                                      'El ${e.name} se ha borrado con éxito',
                                      '',
                                      'close',
                                      context);
                                  upadateRange(null);
                                },
                                icon: Icon(Icons.delete))
                          ],
                        ))
                      ]))
                  .toList(),
              updatePage: () {},
              page: 1,
              totalItems: users.length),
        ],
      ),
    );
  }
}
