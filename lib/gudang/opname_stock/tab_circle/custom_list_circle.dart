import 'package:flutter/material.dart';
// import 'package:invee2/gudang/opname_stock/tab_circle/detail_circletime.dart';

class CustomListCircle extends StatelessWidget {
  final String idOpname;
  final String idProduk;
  final String namaProduk;
  final String stokSistem;
  final String satuan;
  final String gudang;
  final String status;
  final String nextCircle;
  final String circleTime;
  final String lastCircle;
  final Function onTap;
  CustomListCircle({
    @required this.idOpname,
    @required this.idProduk,
    @required this.namaProduk,
    @required this.stokSistem,
    @required this.satuan,
    @required this.gudang,
    @required this.status,
    @required this.nextCircle,
    @required this.circleTime,
    @required this.lastCircle,
    this.onTap,
  });

  Widget _status(statusX) {
    if (statusX == 'process') {
      return Text(
        'Belum di input',
        style: TextStyle(
          color: Colors.white,
          backgroundColor: Colors.orange,
        ),
      );
    } else if (statusX == 'accept') {
      return Text(
        'Di setujui',
        style: TextStyle(
          color: Colors.white,
          backgroundColor: Colors.green,
        ),
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Center(
                child: Text(satuan),
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                padding: EdgeInsets.only(
                  top: 5.0,
                  bottom: 5.0,
                ),
                child: Column(
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      child: Text(
                        namaProduk,
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      child: Text(
                        'Next Circle Time : $nextCircle',
                        style: TextStyle(
                          fontSize: 13.0,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      child: Text(
                        gudang,
                        style: TextStyle(
                          fontSize: 13.0,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(bottom: 5.0),
                    child: Text('$circleTime Hari'),
                  ),
                  _status(status),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
