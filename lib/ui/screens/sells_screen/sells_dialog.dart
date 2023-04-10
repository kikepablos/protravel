import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:folio_software/models/sells_model.dart';
import 'package:folio_software/services/datetime_services.dart';
import 'package:folio_software/services/sells_services.dart';
import 'package:folio_software/services/state_service.dart';
import 'package:folio_software/ui/widgets/dialogs.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:folio_software/services/extensions.dart';
import '../../widgets/colors.dart';

class SellsDialog extends StatefulWidget {
  final SellsModel sellsModel;
  SellsDialog({Key? key, required this.sellsModel}) : super(key: key);

  @override
  State<SellsDialog> createState() => _SellsDialogState();
}

class _SellsDialogState extends State<SellsDialog> {
  AppStore store = VxState.store;
  bool isNew = false;
  final formKey = GlobalKey<FormState>();

  Map<String, dynamic> sellsMap = {
    'reservationCode': null,
    'clientName': null,
    'address': null,
    'clientEmail': null,
    'phone': null,
    'payments': [],
    'season': null,
    'package': null,
    'description': null,
    'sellType': null,
    'status': 'Abierta',
    'destiny': null,
    'travelDate': null,
    'travelers': null,
    'totalPrice': null
  };
  List destinys = [];

  Map<String, TextEditingController> textControllers = {};
  Map<String, FocusNode> textNodes = {};

  @override
  void initState() {
    super.initState();
    if (widget.sellsModel.reservationCode == null) {
      isNew = true;
    }
    sellsMap = widget.sellsModel.toJson();
    textControllers = Map.fromIterable(sellsMap.keys,
        key: (e) => e,
        value: (e) => TextEditingController(
            text: sellsMap[e] == null ? null : sellsMap[e].toString()));

    textNodes = Map.fromIterable(sellsMap.keys,
        key: (e) => e, value: (e) => FocusNode());
    getDestinys();
  }

  getDestinys() async {
    DocumentSnapshot<Map<String, dynamic>> dSnap =
        await FirebaseFirestore.instance.collection('app').doc('config').get();
    setState(() {
      destinys = dSnap.data()!['destinys'];
    });
  }

  Widget textFieldWidget(String name, String key, String nextKey) {
    return TextFormField(
      focusNode: textNodes[key],
      controller: textControllers[key],
      maxLines: key == 'description' ? 6 : 1,
      onChanged: ((value) {
        setState(() {
          sellsMap[key] = value;
        });
      }),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Necesitas llenar este espacio';
        }
        return null;
      },
      onFieldSubmitted: (value) => nextKey == 'final'
          ? updateSell()
          : _fieldFocusChange(context, textNodes[key]!, textNodes[nextKey]!),
      inputFormatters:
          key == 'totalPrice' ? [FilteringTextInputFormatter.digitsOnly] : [],
      decoration: InputDecoration(
        fillColor: Colors.grey[200],
        filled: true,
        label: Text(name),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: appColor, width: 2)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[100]!, width: 2),
        ),
      ),
    );
  }

  updateSell() async {
    Dialogs().showLoadingDialog('Subiendo venta', context);
    try {
      if (formKey.currentState!.validate()) {
        if (!sellsMap.containsValue(null)) {
          if (sellsMap['package'] != 'Paquete especial' &&
              sellsMap['reservationCode'] == null) {
            Dialogs().showErrorDialog(
                'Necesitas agregar una clave de reservación', context);
            return;
          }
          if (sellsMap['travelers'] == null) {
            Dialogs().showErrorDialog(
                'Necesitas seleccionar le numero de viajeros', context);
            return;
          }
          sellsMap['totalPrice'] =
              double.parse(sellsMap['totalPrice'].toString());
          if (sellsMap['package'] == 'Magni Charter') {
            num initPayment = sellsMap['travelers'] * 200;
            num half = (sellsMap['totalPrice'] - initPayment) / 2;
            sellsMap['payments'] = [
              {
                'name': 'Pago inicial',
                'date': DateTime.now(),
                'amount': initPayment
              },
              {
                'name': '50%',
                'date': sellsMap['travelDate'].subtract(Duration(days: 30)),
                'amount': half
              },
              {
                'name': 'Liquidación',
                'date': sellsMap['travelDate'].subtract(Duration(days: 15)),
                'amount': half
              }
            ];
          } else if (sellsMap['package'] == 'Euromundo') {
            num initPayment = sellsMap['travelers'] * 500;
            num second = sellsMap['travelers'] *
                (sellsMap['season'] == 'Temporada Baja' ? 2000 : 3000);
            sellsMap['payments'] = [
              {
                'name': 'Pago inicial',
                'date': DateTime.now(),
                'amount': initPayment
              },
              {
                'name': 'Segundo Pago',
                'date': sellsMap['travelDate'].subtract(Duration(
                    days: sellsMap['season'] == 'Temporada Alta' ? 60 : 35)),
                'amount': second
              },
              {
                'name': 'Liquidación',
                'date': sellsMap['travelDate'].subtract(Duration(
                    days: sellsMap['season'] == 'Temporada Alta' ? 30 : 8)),
                'amount': sellsMap['totalPrice'] - initPayment - second
              }
            ];
          } else {
            sellsMap['payments'][0]['amount'] = sellsMap['totalPrice'];
          }
          if (isNew) {
            sellsMap['date'] = DateTime.now();
            sellsMap['sellerName'] = store.user.getFullName();
            sellsMap['sellerUID'] = store.user.uid;
            if (sellsMap['package'] == 'Paquete especial') {
              sellsMap['reservationCode'] =
                  SellsServices(context).generateRandomString(6, false);
            }
            await FirebaseFirestore.instance
                .collection('ventas')
                .doc(sellsMap['reservationCode'])
                .set(sellsMap);
          } else {
            await FirebaseFirestore.instance
                .collection('ventas')
                .doc(sellsMap['reservationCode'])
                .update(sellsMap);
          }
          Navigator.pop(context);
          Navigator.pop(context, true);
          Dialogs().showAlertDialog(
              'La venta ${sellsMap['reservationCode']} se ha subido con èxito',
              '',
              'close',
              context);
        } else {
          Navigator.pop(context);
          Dialogs()
              .showErrorDialog('Necesitas seleccionar un destino', context);
          return;
        }
      } else {
        Navigator.pop(context);
        Dialogs()
            .showErrorDialog('Necesitas llenar todos los espacios', context);
        return;
      }
    } catch (e) {
      Navigator.pop(context);
      print(e);
      Dialogs().showErrorDialog('${e}', context);
    }
  }

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
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    'Registra nueva venta',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  textFieldWidget(
                      'Nombre del cliente', 'clientName', 'clientEmail'),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: textFieldWidget(
                            'Email del cliente', 'clientEmail', 'phone'),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: textFieldWidget(
                            'Telefono del cliente', 'phone', 'address'),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  textFieldWidget('Dirección', 'address', 'description'),
                  SizedBox(
                    height: 20,
                  ),
                  textFieldWidget(
                      'Descripcción del paquete', 'description', 'sellType'),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 50,
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: DropdownButton(
                                value: sellsMap['package'],
                                hint: Text('Paquete'),
                                items: [
                                  'Magni Charter',
                                  'Euromundo',
                                  'Paquete especial'
                                ]
                                    .map(
                                      (e) => DropdownMenuItem(
                                        child: Text(e),
                                        value: e,
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) {
                                  setState(() {
                                    sellsMap['package'] = val;
                                  });
                                }),
                          ),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.grey[100]),
                        ),
                      ),
                      if (sellsMap['package'] == 'Paquete especial')
                        Expanded(
                            child: GestureDetector(
                          onTap: (() async {
                            DateTime? date = await showDatePicker(
                                initialEntryMode:
                                    DatePickerEntryMode.calendarOnly,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate:
                                    DateTime.now().add(Duration(days: 1825)),
                                context: context);

                            setState(() {
                              sellsMap['payments'] = [
                                {
                                  'name': 'Pago inicial',
                                  'date': date,
                                  // 'amount': initPayment
                                }
                              ];
                            });
                          }),
                          child: Padding(
                            padding: EdgeInsets.only(left: 20),
                            child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.grey[100]),
                                height: 50,
                                width: double.infinity,
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Text(
                                    sellsMap['payments'] == null
                                        ? 'Fecha de pago'
                                        : DatetimeService().getNumberDate(
                                            sellsMap['payments'][0]['date']),
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey[700]),
                                  ),
                                )),
                          ),
                        )),
                      if (sellsMap['package'] == 'Euromundo')
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(left: 20),
                            child: Container(
                              height: 50,
                              width: double.infinity,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: DropdownButton(
                                    value: sellsMap['season'],
                                    hint: Text('Temporada'),
                                    items: [
                                      'Temporada baja',
                                      'Temporada media',
                                      'Temporada alta'
                                    ]
                                        .map(
                                          (e) => DropdownMenuItem(
                                            child: Text(e),
                                            value: e,
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (val) {
                                      setState(() {
                                        sellsMap['season'] = val;
                                      });
                                    }),
                              ),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.grey[100]),
                            ),
                          ),
                        ),
                    ],
                  ),
                  if ([
                    'Magni Charter',
                    'Euromundo',
                  ].contains(sellsMap['package']))
                    Column(
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        textFieldWidget('Clave de reservación',
                            'reservationCode', 'sellType'),
                      ],
                    ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 50,
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: DropdownButton(
                                value: sellsMap['destiny'],
                                hint: Text('Destino'),
                                items: destinys
                                    .map(
                                      (e) => DropdownMenuItem(
                                        child: Text(e),
                                        value: e,
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) {
                                  setState(() {
                                    sellsMap['destiny'] = val;
                                  });
                                }),
                          ),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.grey[100]),
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                          child: GestureDetector(
                        onTap: (() async {
                          DateTime? date = await showDatePicker(
                              initialEntryMode:
                                  DatePickerEntryMode.calendarOnly,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate:
                                  DateTime.now().add(Duration(days: 1825)),
                              context: context);

                          setState(() {
                            sellsMap['travelDate'] = date;
                          });
                        }),
                        child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.grey[100]),
                            height: 50,
                            width: double.infinity,
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                sellsMap['travelDate'] == null
                                    ? 'Fecha del Viaje'
                                    : DatetimeService()
                                        .getNumberDate(sellsMap['travelDate']),
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey[700]),
                              ),
                            )),
                      ))
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: textFieldWidget(
                            'Precio del viaje', 'totalPrice', 'travelers'),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: Container(
                          height: 50,
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: DropdownButton(
                                value: sellsMap['travelers'],
                                hint: Text('No. Viajeros'),
                                items: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
                                    .map(
                                      (e) => DropdownMenuItem(
                                        child: Text('$e'),
                                        value: e,
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) {
                                  setState(() {
                                    sellsMap['travelers'] = val;
                                  });
                                }),
                          ),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.grey[100]),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () => updateSell(),
                    child: Container(
                      height: 50,
                      child: Center(
                        child: Text(
                          'Subir venta',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 18),
                        ),
                      ),
                      width: double.infinity,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: appColor),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }
}
