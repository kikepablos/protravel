import 'package:flutter/material.dart';
import 'package:folio_software/models/payment_model.dart';
import 'package:folio_software/models/sells_model.dart';
import 'package:folio_software/ui/widgets/charts/bar_charts.dart';
import 'package:intl/intl.dart';

class DashboardWidgets {
  final BuildContext context;
  final List<SellsModel> sells;
  final List<PaymentModel> payment;

  DashboardWidgets(this.context, this.sells, this.payment);
  var formatter = NumberFormat('###,###,###,000');

  Widget topWidget() {
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
                        Text('${sells.length}',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                        Text(
                          'Ventas',
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
                            '\$${formatter.format(sells.map((e) => e.totalPrice).reduce((a, b) => a! + b!))}',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                        Text(
                          'Ventas Totales',
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
                            '\$${formatter.format(sells.map((e) => e.totalPrice).reduce((a, b) => a! + b!)! / sells.length)}',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                        Text(
                          'Ticket Promedio',
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
                            '\$${formatter.format(payment.map((e) => e.payment).reduce((a, b) => a! + b!))}',
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
              // // datePickerButton(true, dateRange, upadateRange),
              // SizedBox(
              //   width: 20,
              // ),
              // // datePickerButton(false, dateRange, upadateRange),
              // SizedBox(
              //   width: 20,
              // ),
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

  Widget topCharts() {
    // {
    //   1: DateTime.now().m
    // }
    return Row(
      children: [
        Container(
            height: MediaQuery.of(context).size.height * 0.5,
            width: MediaQuery.of(context).size.width * 0.4,
            // child: SimpleBarChart.withSampleData([
            //   OrdinalSales(year, sales)
            // ])
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey[300]!, spreadRadius: .8, blurRadius: 5)
                ]))
      ],
    );
  }
}
