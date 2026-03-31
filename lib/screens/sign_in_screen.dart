import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

class MySignInScreen extends StatelessWidget {
  const MySignInScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SignInScreen(
      providers: [
        EmailAuthProvider(),
      ],
      actions: [
        AuthStateChangeAction<SignedIn>((context, state) {
          // Sign-in is shown in a modal bottom sheet; close it after success.
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        }),
      ],
    );
  }
}
