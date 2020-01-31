import 'package:flutter/material.dart';
import 'package:invee2/gudang/opname_stock/tab_circle/proses_circletime.dart';
import 'package:invee2/localStorage/localStorage.dart';

bool userAksesMenuOpnameCircle, userGroupAksesMenuOpnameCircle;

class DetailCircleTime extends StatefulWidget {
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

  DetailCircleTime({
    this.idOpname,
    this.idProduk,
    this.namaProduk,
    this.stokSistem,
    this.satuan,
    this.gudang,
    this.status,
    this.nextCircle,
    this.circleTime,
    this.lastCircle,
  });

  @override
  _DetailCircleTimeState createState() => _DetailCircleTimeState();
}

class _DetailCircleTimeState extends State<DetailCircleTime> {
  Widget _summonFloatButton(context, statusX) {
    if (userAksesMenuOpnameCircle || userGroupAksesMenuOpnameCircle) {
      if (statusX == 'accept') {
        return Container();
      } else if (statusX == 'process') {
        return FloatingActionButton(
          child: Icon(Icons.input),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (BuildContext context) {
              return ProsesCircleTime(
                idOpname: widget.idOpname,
                idProduk: widget.idProduk,
                namaProduk: widget.namaProduk,
                stokSistem: widget.stokSistem,
                satuan: widget.satuan,
                gudang: widget.gudang,
                status: widget.status,
                nextCircle: widget.nextCircle,
                circleTime: widget.circleTime,
                lastCircle: widget.lastCircle,
              );
            }));
          },
        );
      }
    }
    return Container();
  }

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
        'Di Setujui',
        style: TextStyle(
          color: Colors.white,
          backgroundColor: Colors.green,
        ),
      );
    } else {
      return Container();
    }
  }

  getUserAksesDanGroupAkses() async {
    DataStore store = new DataStore();

    userAksesMenuOpnameCircle =
        await store.getDataBool('Opname Stock Edit (Akses)');
    userGroupAksesMenuOpnameCircle =
        await store.getDataBool('Opname Stock Edit (Group)');

    setState(() {
      userAksesMenuOpnameCircle = userAksesMenuOpnameCircle;
      userGroupAksesMenuOpnameCircle = userGroupAksesMenuOpnameCircle;
    });
  }

  @override
  void initState() {
    getUserAksesDanGroupAkses();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text('Detail Circle Time'),
      ),
      body: ListView(children: <Widget>[
        Card(
          child: Container(
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: Container(
                        child: Text(
                          'Nama Produk',
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Container(
                        child: Text(
                          widget.namaProduk,
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: Container(
                        child: Text(
                          'Satuan',
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Container(
                        child: Text(
                          widget.satuan,
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: Container(
                        child: Text(
                          'Gudang',
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Container(
                        child: Text(
                          widget.gudang,
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: Container(
                        child: Text(
                          'Stok Sistem',
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Container(
                        child: Text(
                          widget.stokSistem,
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: Container(
                        child: Text(
                          'Last Circle',
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Container(
                        child: Text(
                          widget.lastCircle,
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: Container(
                        child: Text(
                          'Next Circle',
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Container(
                        child: Text(
                          widget.nextCircle,
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: Container(
                        child: Text(
                          'Status',
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Container(
                        child: _status(widget.status),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ]),
      floatingActionButton: _summonFloatButton(context, widget.status),
    );
  }
}
