import 'package:flutter/material.dart';

class TabDetail extends StatelessWidget {
  final String id, nota, tglTerima, tglRencana, staff, notaPlan, status;
  TabDetail({
    this.id,
    @required this.nota,
    @required this.tglTerima,
    @required this.tglRencana,
    @required this.staff,
    @required this.notaPlan,
    @required this.status,
  });

  Widget _tglPenerimaan(tglTerima) {
    if (tglTerima == null) {
      return Text(
        'Belum diterima',
        style: TextStyle(
          color: Colors.white,
          backgroundColor: Colors.orange,
          fontSize: 14.0,
        ),
      );
    } else if (tglTerima != null) {
      return Text(
        tglTerima,
        style: TextStyle(
          color: Colors.blue[800],
          fontSize: 14.0,
        ),
      );
    } else {
      return Text(
        'Error',
        style: TextStyle(
          color: Colors.blue[800],
          fontSize: 14.0,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Card(
            child: Container(
              padding: EdgeInsets.all(10.0),
              child: Column(
                children: <Widget>[
                  Container(
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: Text('Nota PO'),
                        ),
                        Expanded(
                          flex: 5,
                          child: Text(nota),
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  Container(
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: Text('Staff'),
                        ),
                        Expanded(
                          flex: 5,
                          child: Text(staff),
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  Container(
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: Text('Tgl Order Pembelian'),
                        ),
                        Expanded(
                          flex: 5,
                          child: Text(tglRencana),
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  Container(
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: Text('Tgl Terima'),
                        ),
                        Expanded(
                          flex: 5,
                          child: _tglPenerimaan(tglTerima),
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  Container(
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: Text('Status'),
                        ),
                        Expanded(
                          flex: 5,
                          child: _statusPenerimaan(status),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _statusPenerimaan(String status) {
  if (status == 'process') {
    return Container(
      padding: EdgeInsets.only(
        bottom: 5.0,
      ),
      child: Text(
        'Proses Pengiriman',
        style: TextStyle(
          color: Colors.white,
          backgroundColor: Colors.cyan,
        ),
      ),
    );
  } else if (status == 'success') {
    return Container(
      padding: EdgeInsets.only(
        bottom: 5.0,
      ),
      child: Text(
        'Sudah diterima',
        style: TextStyle(
          color: Colors.white,
          backgroundColor: Colors.green,
        ),
      ),
    );
  }
  return Container();
}
