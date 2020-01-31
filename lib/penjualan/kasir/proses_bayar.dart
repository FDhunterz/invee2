import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:invee2/penjualan/kasir/kasir.dart';
import 'package:http/http.dart' as http;

import '../../localStorage/localStorage.dart';
import '../../routes/env.dart';

TextEditingController bayarController;
TextEditingController jumlahController;
TextEditingController kembalianController;
String tokenType, accessToken;
Map<String, String> requestHeaders = Map();
GlobalKey<ScaffoldState> _scaffoldKeyX = new GlobalKey<ScaffoldState>();
bool isLoading;

class ProsesBayar extends StatefulWidget {
  final String id, nota, customer, status, idcustomer;
  final double bayar;
  final double kembalian;

  ProsesBayar({
    Key key,
    @required this.id,
    @required this.nota,
    @required this.customer,
    @required this.status,
    @required this.idcustomer,
    @required this.bayar,
    this.kembalian,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ProsesBayarState(
      id: id,
      nota: nota,
      customer: customer,
      status: status,
      bayar: bayar,
      idcustomer: idcustomer,
    );
  }
}

class _ProsesBayarState extends State<ProsesBayar> {
  final String id, nota, customer, status, idcustomer;
  final double bayar;
  double kembalian;

  _ProsesBayarState({
    Key key,
    @required this.id,
    @required this.nota,
    @required this.customer,
    @required this.status,
    @required this.idcustomer,
    @required this.bayar,
    this.kembalian,
  });

  void showInSnackBarM(String value) {
    _scaffoldKeyX.currentState.showSnackBar(
      SnackBar(
        content: new Text(value),
      ),
    );
  }

  void _validasi(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'Tidak',
                style: TextStyle(color: Colors.grey),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Ya'),
              onPressed: () async {
                try {
                  final ubahStatusProses = await http.post(
                    url('api/pembayaranoffline'),
                    headers: requestHeaders,
                    body: {
                      'nota': nota,
                      'bayar': bayar.toString(),
                      'kembalian': kembalian.toString(),
                      'customerr': idcustomer,
                    },
                  );

                  if (ubahStatusProses.statusCode == 200) {
                    var ubahStatusProsesJson =
                        json.decode(ubahStatusProses.body);
                    if (ubahStatusProsesJson['status'] == 'sukses') {
                      // Navigator.popUntil(
                      //   context,
                      //   ModalRoute.withName('/penjualan_offline'),
                      // );
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Kasir(),
                        ),
                      );
                    } else if (ubahStatusProsesJson['status'] == 'gagal') {
                      showInSnackBarM('Gagal! Hubungi pengembang software!');
                    }
                  } else {
                    showInSnackBarM(
                        'Request failed with status: ${ubahStatusProses.statusCode}');
                    Map responseJson = jsonDecode(ubahStatusProses.body);

                    if (responseJson.containsKey('message')) {
                      showInSnackBarM(responseJson['message']);
                    }
                  }
                } on TimeoutException catch (_) {
                  showInSnackBarM('Timed out, Try again');
                } catch (e) {
                  print(e);
                }
              },
            )
          ],
        );
      },
    );
  }

  Future<Null> getHeaderHTTP() async {
    try {
      var storage = new DataStore();

      var tokenTypeStorage = await storage.getDataString('token_type');
      var accessTokenStorage = await storage.getDataString('access_token');

      setState(() {
        tokenType = tokenTypeStorage;
        accessToken = accessTokenStorage;

        requestHeaders['Accept'] = 'application/json';
        requestHeaders['Authorization'] = '$tokenType $accessToken';
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    getHeaderHTTP();
    var rupiah =
        new NumberFormat.simpleCurrency(decimalDigits: 2, name: 'Rp. ');
    var parserupiah = rupiah.format(widget.bayar);
    bayarController = TextEditingController(text: parserupiah.toString());
    jumlahController = TextEditingController();
    kembalianController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text('Proses Bayar'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        onPressed: () {
          if (kembalian >= 0) {
            _validasi('Pembayaran', 'Pastikan Jumlah Uang Sudah Sesuai');
          }
        },
      ),
      body: SingleChildScrollView(
          child: Container(
        child: Column(
          children: <Widget>[
            Card(
              child: Column(
                children: <Widget>[
                  Text(
                    'Data Customer',
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                  ListTile(
                    title: Text(customer),
                  ),
                ],
              ),
            ),
            Card(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Text(
                      'Form Input Pembayaran',
                      style: TextStyle(
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(5.0),
                    child: TextField(
                      controller: bayarController,
                      enabled: false,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Total',
                      ),
                      inputFormatters: <TextInputFormatter>[
                        WhitelistingTextInputFormatter.digitsOnly
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(5.0),
                    child: TextField(
                      controller: jumlahController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Jumlah Bayar',
                      ),
                      inputFormatters: <TextInputFormatter>[
                        WhitelistingTextInputFormatter.digitsOnly
                      ],
                      onChanged: (ini) {
                        kembalian = double.parse(ini) - bayar;
                        var rupiah = new NumberFormat.simpleCurrency(
                            decimalDigits: 2, name: 'Rp. ');
                        var parserupiah = rupiah.format(kembalian);
                        kembalianController.text = parserupiah.toString();
                        setState(() {});
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(5.0),
                    child: TextField(
                      controller: kembalianController,
                      enabled: false,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Kembalian',
                      ),
                      inputFormatters: <TextInputFormatter>[
                        WhitelistingTextInputFormatter.digitsOnly
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      )),
    );
  }
}
