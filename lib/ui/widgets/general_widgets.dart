import 'package:flutter/material.dart';
import 'package:folio_software/services/state_service.dart';
import 'package:velocity_x/velocity_x.dart';

class GeneralWidgets {
  final BuildContext context;

  GeneralWidgets(this.context);
  AppStore store = VxState.store;

  Widget appBarWidget(title, subtitle) {
    return Padding(
      padding: const EdgeInsets.only(top: 30.0, left: 30, right: 30, bottom: 0),
      child: Container(
        height: 55,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                  Text(subtitle,
                      style: TextStyle(
                        fontSize: 16,
                      ))
                ],
              ),
            ),
            Container(
              height: 40,
              width: 40,
              child: Row(),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Colors.grey,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${store.user.getFullName()}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text('${store.user.rol}',
                    style: TextStyle(
                      fontSize: 16,
                    ))
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget tableWidget(
      {required context,
      required List<DataColumn> columns,
      required List<DataRow> rows,
      required page,
      required int totalItems,
      required updatePage}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DataTable(columns: columns, showBottomBorder: true, rows: rows),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                  onPressed: () {
                    print(page);
                    if (page == 1) {
                      return;
                    }
                    updatePage(page - 1);
                  },
                  child: Text('Anterior')),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  '${(page - 1) * 10}- ${page * 10}',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    print(page);
                    if ((page * 10) + 1 > totalItems) {
                      return;
                    }
                    updatePage(page + 1);
                  },
                  child: Text('Siguiente')),
            ],
          ),
        )
      ],
    );
  }
}
