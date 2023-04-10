import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:folio_software/top_controller.dart';
import 'package:folio_software/ui/screens/login_screen/login_screen.dart';

class RootPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new RootPageState();
}

enum AuthStatus { notSignedIn, signedIn }

class RootPageState extends State<RootPage> {
  AuthStatus authStatus = AuthStatus.notSignedIn;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userId = FirebaseAuth.instance.currentUser;
    if (userId != null) {
      setState(() {
        authStatus =
            userId == null ? AuthStatus.notSignedIn : AuthStatus.signedIn;
      });
    }
  }

  void _signedIn() {
    setState(() {
      authStatus = AuthStatus.signedIn;
    });
  }

  void _signedOut() {
    setState(() {
      authStatus = AuthStatus.notSignedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return TopController(
            onSignedOut: _signedOut,
          );
        }
        return new LoginPage(
          onSignedIn: _signedIn,
          onSignedOut: _signedOut,
        );
      },
    );
  }
}
