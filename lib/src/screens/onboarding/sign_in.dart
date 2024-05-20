
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netten/src/providers/auth_provider.dart';



//todo add colors to theme, work with button themes
class SignIn extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      child: Container(
        decoration: BoxDecoration(gradient: RadialGradient(colors: [Color(0xFF34CD5D), Color(0xFF138832)])),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('NeteN', style: Theme.of(context).textTheme.displayLarge),
              SizedBox(height: 55),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 46.0),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ), backgroundColor: Colors.white,
                        shadowColor: Colors.black,
                        elevation: 4,
                        textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black)),
                    onPressed: () async {
                      ref
                          .watch(authenticationProvider)
                          .signInWithGoogle(context)
                          .onError((error, stackTrace) => throw Exception(error.toString()));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Image(
                            image: AssetImage('assets/google_logo.png'),
                            height: 18.0,
                          ),
                          const SizedBox(width: 15),
                          Text('Continue with google',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black.withOpacity(0.54),
                                  letterSpacing: 0.25,
                                  height: 1.2,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w500))
                        ],
                      ),
                    )),
              ),
              const SizedBox(height: 18),
              SizedBox(height: 18),
              if(Platform.isIOS)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 46.0),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ), backgroundColor: Colors.white,
                          shadowColor: Colors.black,
                          elevation: 4,
                          textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black)),
                      onPressed: () async {
                        ref
                            .watch(authenticationProvider)
                            .signInWithApple(context)
                            .onError((error, stackTrace) => throw Exception(error.toString()));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.apple,
                              color: Colors.black
                            ),
                            const SizedBox(width: 15),
                            Text('Continue with Apple',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                    letterSpacing: 0.25,
                                    height: 1.2,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w500))
                          ],
                        ),
                      )),
                ),

            ]),
      ),
    );
  }
}
