// import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

// reinitialise in main.dart
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
// end reinitialise
var platform = MethodChannel('crossingthestreams.io/resourceResolver');
int totalNotifikasi = 0;

class NotificationService {
  BuildContext context;

  NotificationService({@required this.context});

  initStateNotificationCustomerSudahBayarService() {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification:
            onDidReceiveLocalNotificationCustomerSudahBayar);
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotificationCustomerSudahBayar);
  }

  Future<void> onDidReceiveLocalNotificationCustomerSudahBayar(
      int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page

    await showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Ok'),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              if (payload == 'online') {
                await Navigator.pushNamed(context, '/penjualan_online');
              } else if (payload == 'offline') {
                await Navigator.pushNamed(context, '/penjualan_offline');
              }
            },
          )
        ],
      ),
    );
  }

  Future<void> onSelectNotificationCustomerSudahBayar(dynamic payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    if (payload == 'online') {
      await Navigator.pushNamed(context, '/penjualan_online');
    } else if (payload == 'offline') {
      await Navigator.pushNamed(context, '/penjualan_offline');
    }
  }

  Future<dynamic> showNotification(
      {String nama, String message, String payload}) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      '$totalNotifikasi',
      nama,
      message,
      importance: Importance.Low,
      priority: Priority.High,
      ticker: 'ticker',
      color: Colors.green,
    );
    totalNotifikasi += 1;
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        totalNotifikasi, nama, message, platformChannelSpecifics,
        payload: payload);
  }

  Future<void> showBigTextNotification({
    @required String title,
    @required String description,
    String summaryText,
    String payload,
  }) async {
    totalNotifikasi += 1;

    var bigTextStyleInformation = BigTextStyleInformation(
      description,
      htmlFormatBigText: true,
      contentTitle: title,
      htmlFormatContentTitle: true,
      summaryText: summaryText,
      htmlFormatSummaryText: true,
    );
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'big text channel id',
        'big text channel name',
        'big text channel description',
        style: AndroidNotificationStyle.BigText,
        styleInformation: bigTextStyleInformation);
    var platformChannelSpecifics =
        NotificationDetails(androidPlatformChannelSpecifics, null);
    await flutterLocalNotificationsPlugin.show(
        totalNotifikasi, title, description, platformChannelSpecifics,
        payload: payload);
  }
}

class SecondScreen extends StatefulWidget {
  final String payload;
  SecondScreen(this.payload);
  @override
  State<StatefulWidget> createState() => SecondScreenState();
}

class SecondScreenState extends State<SecondScreen> {
  String _payload;
  @override
  void initState() {
    super.initState();
    _payload = widget.payload;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Second Screen with payload: " + _payload),
      ),
      body: Center(
        child: RaisedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Go back!'),
        ),
      ),
    );
  }
}
