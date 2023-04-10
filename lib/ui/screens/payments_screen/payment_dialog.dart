import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:folio_software/models/payment_model.dart';
import 'package:folio_software/services/sells_services.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../services/datetime_services.dart';
import '../../../services/state_service.dart';
import '../../widgets/colors.dart';
import '../../widgets/dialogs.dart';

class PaymentDialog extends StatefulWidget {
  final refresh;
  final PaymentModel payment;
  PaymentDialog({Key? key, this.refresh, required this.payment})
      : super(key: key);

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  AppStore store = VxState.store;
  bool isNew = false;
  final formKey = GlobalKey<FormState>();
  num initPayment = 0;

  Map<String, dynamic> paymentMap = {
    'created': DateTime.now(),
    'date': null,
    'payment': null,
    'paymentMethod': null,
    'reciver': null,
    'reciverUID': null,
    'reservationCode': null,
  };

  List paymentMethods = [];
  List<String> reservationCodes = [];

  @override
  void initState() {
    super.initState();

    if (widget.payment.id == null) {
      isNew = true;
    } else {
      isNew = true;
      initPayment = widget.payment.payment!;
    }
    paymentMap = widget.payment.toJson();
    textControllers = Map.fromIterable(paymentMap.keys,
        key: (e) => e,
        value: (e) => TextEditingController(
            text: paymentMap[e] == null ? null : paymentMap[e].toString()));

    textNodes = Map.fromIterable(paymentMap.keys,
        key: (e) => e, value: (e) => FocusNode());
    getPaymentMethod();
  }

  getPaymentMethod() async {
    QuerySnapshot<Map<String, dynamic>> vSnap =
        await FirebaseFirestore.instance.collection('ventas').get();
    reservationCodes = vSnap.docs
        .map<String>((e) => e.data()['reservationCode'] as String)
        .toList();
    DocumentSnapshot<Map<String, dynamic>> dSnap =
        await FirebaseFirestore.instance.collection('app').doc('config').get();
    setState(() {
      paymentMethods = dSnap.data()!['paymentMethods'];
    });
  }

  List destinys = [];
  // List
  Map<String, TextEditingController> textControllers = {};
  Map<String, FocusNode> textNodes = {};

  Widget textFieldWidget(String name, String key, String nextKey) {
    return TextFormField(
      focusNode: textNodes[key],
      controller: textControllers[key],
      onChanged: ((value) {
        setState(() {
          paymentMap[key] = value;
        });
      }),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Necesitas llenar este espacio';
        }
        return null;
      },
      onFieldSubmitted: (value) => nextKey == 'final'
          ? null
          : _fieldFocusChange(context, textNodes[key]!, textNodes[nextKey]!),
      inputFormatters:
          key == 'payment' ? [FilteringTextInputFormatter.digitsOnly] : [],
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

  void updatePayment() async {
    Dialogs().showLoadingDialog('Subiendo pago', context);
    try {
      if (formKey.currentState!.validate()) {
        print(paymentMap['paymentMethod'] != null);
        if (paymentMap['paymentMethod'] != null && paymentMap['date'] != null) {
          paymentMap['payment'] = num.parse(paymentMap['payment'].toString());
          paymentMap['created'] = DateTime.now();
          paymentMap['reciverUID'] = store.user.uid;

          paymentMap['reciver'] = store.user.getFullName();
          CollectionReference<Map<String, dynamic>> sRef =
              FirebaseFirestore.instance.collection('ventas');
          QuerySnapshot<Map<String, dynamic>> vSnap = await sRef
              .where('reservationCode',
                  isEqualTo: paymentMap['reservationCode'])
              .get();
          num amount = vSnap.docs[0]['pago'] ?? 0;
          amount += paymentMap['payment'] - initPayment;
          sRef.doc(vSnap.docs[0].id).update({'pago': amount});
          if (isNew) {
            paymentMap['id'] =
                SellsServices(context).generateRandomString(6, true);
            await FirebaseFirestore.instance
                .collection('pagos')
                .doc(paymentMap['id'])
                .set(paymentMap);
          } else {
            await FirebaseFirestore.instance
                .collection('pagos')
                .doc(paymentMap['id'])
                .update(paymentMap);
          }
          Navigator.pop(context);
          Navigator.pop(context, true);
          Dialogs().showAlertDialog(
              'El pago de ${paymentMap['reservationCode']} se ha subido con èxito',
              '',
              'close',
              context);
        } else {
          Navigator.pop(context);
          Dialogs()
              .showErrorDialog('Necesitas llenar todos los campos', context);
        }
      }
    } catch (e) {
      print(e);
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
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text(
                        'Registra nuevo pago',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 22),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.grey[100]),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Autocomplete<String>(
                                initialValue: TextEditingValue(
                                    text: paymentMap['reservationCode'] ?? ''),
                                optionsBuilder:
                                    (TextEditingValue textEditingValue) {
                                  if (textEditingValue.text == '') {
                                    return const Iterable<String>.empty();
                                  }
                                  return reservationCodes
                                      .where((String option) {
                                    return option
                                        .contains(textEditingValue.text);
                                  });
                                },
                                onSelected: (String selection) {
                                  setState(() {
                                    paymentMap['reservationCode'] = selection;
                                  });
                                  debugPrint('You just selected $selection');
                                },
                              ),
                            ),
                          )),
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
                                paymentMap['date'] = date;
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Text(
                                    paymentMap['date'] == null
                                        ? 'Fecha del pago'
                                        : DatetimeService()
                                            .getNumberDate(paymentMap['date']),
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
                            child: Container(
                              height: 50,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: DropdownButton(
                                    value: paymentMap['paymentMethod'],
                                    hint: Text('Metodo de pago'),
                                    items: paymentMethods
                                        .map(
                                          (e) => DropdownMenuItem(
                                            child: Text(e),
                                            value: e,
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (val) {
                                      setState(() {
                                        paymentMap['paymentMethod'] = val;
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
                            child: textFieldWidget(
                                'Monto del Pago', 'payment', 'payment'),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                        onTap: () => updatePayment(),
                        child: Container(
                          height: 50,
                          child: Center(
                            child: Text(
                              'Subir pago',
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
                    ])))));
  }

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }
}
