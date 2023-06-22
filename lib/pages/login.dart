import 'package:birthday_reminder/strings.dart';
import 'package:birthday_reminder/widgets/hyperlink.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final height = MediaQuery.of(context).size.height;
    final strings = appStrings(context);

    Widget body = Stack(children: [
      Positioned(
        top: statusBarHeight + 10,
        left: 0,
        right: 0,
        child: Column(children: [
          // Text(
          //   strings.appName,
          //   style: TextStyle(fontSize: 20),
          // ),
          const SizedBox(height: 30),
          Image.asset(
            'assets/icon.png',
            width: 120,
          )
        ]),
      ),
      Container(
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.signIn,
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: double.infinity,
              child: SignInButton(
                Buttons.Google,
                text: "Sign up with Google",
                onPressed: () {
                  if (kIsWeb) {
                    FirebaseAuth.instance.signInWithRedirect(GoogleAuthProvider());
                  } else {
                    FirebaseAuth.instance.signInWithProvider(GoogleAuthProvider());
                  }
                },
              ),
            ),
          ],
        ),
      ),
      Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            child: Row(
              children: [
                Hyperlink(
                  url: "https://www.google.com",
                  child: Text(strings.terms_of_use),
                ),
                const SizedBox(width: 22),
                Hyperlink(
                  url: "https://www.google.com",
                  child: Text(strings.privacy_policy),
                ),
                const SizedBox(width: 22),
                Hyperlink(
                  url: "https://play.google.com/store/apps/details?id=net.tomascichero.birthdayremainder",
                  child: Text(strings.play_store),
                ),
              ],
            ),
          ),
        ),
      )
    ]);

    if (height < 450) {
      body = SingleChildScrollView(
        child: SizedBox(
          height: 450,
          child: body,
        ),
      );
    }

    return Scaffold(body: body);
  }
}

class SigninWithButton extends StatelessWidget {
  const SigninWithButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      // style: ButtonStyle(
      //   backgroundColor: MaterialStateProperty.all(Colors.white),
      //   textStyle: MaterialStateProperty.all(
      //     TextStyle(color: Colors.black),
      //   ),
      // ),
      onPressed: () {},
      icon: Image.network('http://pngimg.com/uploads/google/google_PNG19635.png', width: 30, fit: BoxFit.cover),
      label: const Text("Sigin With Google"),
    );
  }
}
