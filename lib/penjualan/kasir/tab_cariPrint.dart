import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TabCariPrint extends StatefulWidget {
  @override
  _TabCariPrintState createState() => new _TabCariPrintState();
}

class _TabCariPrintState extends State<TabCariPrint> {
  List devices = [];
  bool connected = false;

  @override
  initState() {
    super.initState();
    _list();
  }

  _list() async {
    List returned;
    try {
    } on PlatformException {
      //response = 'Failed to get platform version.';
    }
    setState(() {
      devices = returned;
    });
  }

  _connect(int vendor, int product) async {
    bool returned;
    try {
    } on PlatformException {
      //response = 'Failed to get platform version.';
    }
    if (returned) {
      setState(() {
        connected = true;
      });
    }
  }

  _print() async {
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          new FloatingActionButton(
              child: new Icon(Icons.refresh),
              onPressed: () {
                _list();
              }),
          connected == true
              ? Container(
                  margin: EdgeInsets.only(top: 10.0),
                  child: new FloatingActionButton(
                      child: new Icon(Icons.print),
                      onPressed: () {
                        _print();
                      }))
              : new Container(
                  width: 0.0,
                  height: 0.0,
                ),
        ],
      ),
      body: devices.length > 0
          ? RefreshIndicator(
              onRefresh: () async {
                _list();
                Future.value({});
              },
              child: new ListView(
                scrollDirection: Axis.vertical,
                children: _buildList(devices),
              ))
          : Container(),
    );
  }

  List<Widget> _buildList(List devices) {
    return devices
        .map((device) => new ListTile(
              onTap: () {
                _connect(int.parse(device['vendorid']),
                    int.parse(device['productid']));
              },
              leading: new Icon(Icons.usb),
              title: new Text(device['manufacturer'] + " " + device['product']),
              subtitle:
                  new Text(device['vendorid'] + " " + device['productid']),
            ))
        .toList();
  }
}
