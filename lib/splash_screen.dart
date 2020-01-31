import 'package:flutter/material.dart';
import 'dart:async';
import 'package:invee2/localStorage/localStorage.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SplashScreenState();
  }
}

class _SplashScreenState extends State<SplashScreen> {
  String _status;

  Future<Null> getSharedPrefs() async {
    DataStore dataStore = new DataStore();
    _status = await dataStore.getDataString("sudah_login");
    print(_status);

    if (_status == "Tidak ditemukan") {
      Timer(Duration(seconds: 2),
          () => Navigator.pushReplacementNamed(context, "/login"));
    } else if (_status == "sudah") {
      Timer(Duration(seconds: 2),
          () => Navigator.pushReplacementNamed(context, "/home"));
    }
  }

  @override
  void initState() {
    getSharedPrefs();
    super.initState();
  }

  final GlobalKey<ScaffoldState> _scaffoldKeyX = new GlobalKey<ScaffoldState>();
  void showInSnackBar(String value) {
    _scaffoldKeyX.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKeyX,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(color: Colors.white),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                  color: Color(0xff28a745),
                  child: Center(
                    child: Text(
                      "Invee",
                      style: TextStyle(
                          color: Color(0xfffff000),
                          fontFamily: 'Myriad',
                          fontWeight: FontWeight.bold,
                          fontSize: 30.0),
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
