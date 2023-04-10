import 'package:flutter/material.dart';

import 'colors.dart';

class Dialogs {
  showErrorDialog(String title, context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: new Text("Lo sentimos, ha sucedido un error"),
          content: new Text(title),
          actions: <Widget>[
            new TextButton(
              child: new Text(
                "Ok",
                style: TextStyle(fontWeight: FontWeight.bold, color: appColor),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void showLoadingDialog(title, context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: new Text(
              title,
              textAlign: TextAlign.center,
            ),
            content: new Container(
              height: 70,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ));
      },
    );
  }

  Widget loadingWidget() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  showAlertDialog(String title, String content, actions, context) {
    void closeAction(ctx) {
      if (actions == 'close') {
        Navigator.pop(ctx);
      } else {
        actions();
      }
    }

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            title: Text(title),
            content: Text(content),
            actions: [
              MaterialButton(
                  child: Text(
                    'Aceptar',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    closeAction(context);
                  })
            ],
          );
        });
  }
}
