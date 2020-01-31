// import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:invee2/splash_screen.dart';
import 'package:invee2/routes/routes.dart';
import 'package:invee2/notification/notification_service.dart';

/// This "Headless Task" is run when app is terminated.
// void backgroundFetchHeadlessTask() async {
//   print('[BackgroundFetch] Headless event received.');
//   BackgroundFetch.finish();
// }

void main() {
  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  // BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Invee',
      theme: ThemeData(
        primaryColor: Color(0xff28a745),
        accentColor: Color(0xff28a745),
        buttonColor: Color(0xff28a745),
        appBarTheme: AppBarTheme(color: Color(0xff28a745)),
        scaffoldBackgroundColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          contentPadding: EdgeInsets.all(10.0),
          border: OutlineInputBorder(),
          labelStyle: TextStyle(
            color: Color(0xff25282b),
            fontSize: 24.0,
          ),
        ),
      ),
      home: SplashScreen(),
      routes: routeX,
    ),
  );
}
