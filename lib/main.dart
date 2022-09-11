import 'package:flutter/material.dart';
import 'package:flutter_gmaps/directions_model.dart';
import 'package:flutter_gmaps/directions_repository.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'maps.dart';
import 'package:splashscreen/splashscreen.dart';
import 'login_screen.dart';

class ReconnectingOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: CircularProgressIndicator(),
        ),
        SizedBox(height: 12),
        Text(
          'Finding mechanic...',
        ),
      ],
    ),
  );
}



void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Mechanic finder',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: SplashScreen(
          seconds: 20,
          navigateAfterSeconds:LoginPage(),
          image:
          Image.asset(
              'assets/images/logo.png',
              height: 3200,
              width: 3200,
              scale: 1,
              colorBlendMode: BlendMode.darken,

          ),

          title: new Text(
            'Mechanic finder',
            style: new TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
                color: Colors.black),
          ),
          backgroundColor: Colors.white,
          loaderColor: Colors.blue,
        )
    );
  }
}