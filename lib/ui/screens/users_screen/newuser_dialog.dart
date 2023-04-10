import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:folio_software/models/user_model.dart';
import 'package:folio_software/ui/widgets/dialogs.dart';
import 'package:folio_software/ui/widgets/general_widgets.dart';

import '../../../firebase_options.dart';
import '../../widgets/colors.dart';

class NewUserDialog extends StatefulWidget {
  final UserModel user;
  final updateUsers;
  NewUserDialog({Key? key, required this.updateUsers, required this.user})
      : super(key: key);

  @override
  State<NewUserDialog> createState() => _NewUserDialogState();
}

class _NewUserDialogState extends State<NewUserDialog> {
  final formKey = GlobalKey<FormState>();
  bool newUser = false;
  Map<String, dynamic> userMap = {
    'name': null,
    'lastName': null,
    'commision': null,
    'password': null,
    'rol': null,
    'email': null,
    'created': DateTime.now()
  };

  Map<String, TextEditingController> textControllers = {};
  Map<String, FocusNode> textNodes = {};

  @override
  void initState() {
    if (widget.user.name != null) {
      userMap = widget.user.toJson();
      textControllers = Map.fromIterable(userMap.keys,
          key: (e) => e,
          value: (e) => TextEditingController(
              text: e == 'commision'
                  ? '${userMap[e] * 100}'
                  : userMap[e].toString()));
      newUser = true;
    } else {
      textControllers = Map.fromIterable(userMap.keys,
          key: (e) => e, value: (e) => TextEditingController());
    }
    textNodes = Map.fromIterable(userMap.keys,
        key: (e) => e, value: (e) => FocusNode());
    super.initState();
  }

  Future<FirebaseApp> getApp() async {
    late FirebaseApp app;
    if (Firebase.apps.map((e) => e.name).toList().contains('newUser')) {
      app = Firebase.app('newUser');
    } else {
      app = await Firebase.initializeApp(
        name: 'newUser',
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    return app;
  }

  void validateAndSummit() async {
    Dialogs().showLoadingDialog('Creando usuario', context);
    if (userMap.containsValue(null)) {
      Navigator.pop(context);
      Dialogs().showErrorDialog('Necesitas llenar todos los datos', context);
      return;
    }
    FirebaseApp app = await getApp();
    try {
      userMap['commision'] = double.parse(userMap['commision']) / 100;
      if (!newUser) {
        UserCredential c = await FirebaseAuth.instanceFor(app: app)
            .createUserWithEmailAndPassword(
                email: userMap['email'], password: userMap['password']);
        userMap['id'] = c.user!.uid;
      }
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userMap['id'])
          .set(userMap);
      await FirebaseAuth.instanceFor(app: app).signOut();
      Navigator.pop(context);
      Navigator.pop(context);
      Dialogs().showAlertDialog(
          'Se ha creado el usuario con éxito', '', 'close', context);
      widget.updateUsers(null);
    } catch (e) {
      Navigator.pop(context);
      Dialogs().showErrorDialog('$e', context);
    }
  }

  Widget textFieldWidget(String name, String key, String nextKey) {
    return TextFormField(
      focusNode: textNodes[key],
      controller: textControllers[key],
      onChanged: ((value) {
        setState(() {
          userMap[key] = value;
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
          key == 'commision' ? [FilteringTextInputFormatter.digitsOnly] : [],
      enabled: !(newUser && key == 'password'),
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        backgroundColor: Colors.white,
        child: SizedBox(
            // height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width * 0.3,
            child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                    key: formKey,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text(
                        'Registra nuevo usuario',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 22),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: textFieldWidget(
                                  'Nombre', 'name', 'lastName')),
                          SizedBox(
                            width: 15,
                          ),
                          Expanded(
                              child: textFieldWidget(
                                  'Apellido', 'lastName', 'email')),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      textFieldWidget('Email', 'email', 'password'),
                      SizedBox(
                        height: 15,
                      ),
                      textFieldWidget('Contraseña', 'password', 'commision'),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: textFieldWidget(
                                  'Comisión', 'commision', 'rol')),
                          SizedBox(
                            width: 15,
                          ),
                          Expanded(
                            child: Container(
                              height: 50,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: DropdownButton(
                                    value: userMap['rol'],
                                    hint: Text('Rol'),
                                    items: ['Vendedor', 'Super Admin']
                                        .map(
                                          (e) => DropdownMenuItem(
                                            child: Text(e),
                                            value: e,
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (val) {
                                      setState(() {
                                        userMap['rol'] = val;
                                      });
                                    }),
                              ),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.grey[100]),
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => validateAndSummit(),
                        child: Container(
                          height: 50,
                          child: Center(
                            child: Text(
                              'Crear usuario',
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
