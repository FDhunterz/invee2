import 'package:flutter/material.dart';

class ListTileAntrianLayanan extends StatelessWidget {
  final String nomor;
  final Widget status;
  ListTileAntrianLayanan({
    @required this.nomor,
    @required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // padding: EdgeInsets.all(10.0),
      margin: EdgeInsets.only(
        top: 5.0,
        left: 5.0,
        right: 5.0,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.black54,
          width: 0.5,
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 200.0,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: Colors.black54,
                  width: 0.5,
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.5),
                  ),
                  child: Text(
                    'Nomor Antrian',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontSize: 20.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Text(
                  nomor,
                  style: TextStyle(
                    fontSize: 105.0,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        right: 10.0,
                        top: 10.0,
                        child: status,
                      ),
                      Container(
                        width: double.infinity,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 4,
                                  child: Text('Nama'),
                                ),
                                Expanded(
                                  flex: 5,
                                  child: Text('customer'),
                                ),
                              ],
                            ),
                            Divider(),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 4,
                                  child: Text('Nama'),
                                ),
                                Expanded(
                                  flex: 5,
                                  child: Text('customer'),
                                ),
                              ],
                            ),
                            Divider(),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 4,
                                  child: Text('Nama'),
                                ),
                                Expanded(
                                  flex: 5,
                                  child: Text('customer'),
                                ),
                              ],
                            ),
                            Divider(),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 4,
                                  child: Text('Nama'),
                                ),
                                Expanded(
                                  flex: 5,
                                  child: Text('customer'),
                                ),
                              ],
                            ),
                            Divider(),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
