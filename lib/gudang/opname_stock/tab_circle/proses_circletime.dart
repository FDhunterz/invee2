import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:invee2/gudang/opname_stock/tab_manual/model.dart';
import 'package:invee2/localStorage/localStorage.dart';
import 'package:invee2/routes/env.dart';

String tokenType, accessToken;
Map<String, String> requestHeaders = Map();
GlobalKey<FormState> _form;

KeteranganOpname selectedKeteranganOpname;
List<KeteranganOpname> listKeteranganOpname;

class ProsesCircleTime extends StatefulWidget {
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

  ProsesCircleTime({
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
  });
  @override
  _ProsesCircleTimeState createState() => _ProsesCircleTimeState();
}

class _ProsesCircleTimeState extends State<ProsesCircleTime> {
  bool _isLoading = false;
  TextEditingController stokGudangField = TextEditingController();

  void _konfirmSimpan() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Apa anda yakin?'),
          content: Text('Data akan disimpan'),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'Tidak',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text('Ya'),
              onPressed: () async {
                setState(() {
                  _isLoading = true;
                });
                DataStore storage = new DataStore();

                String tokenTypeStorage =
                    await storage.getDataString('token_type');
                String accessTokenStorage =
                    await storage.getDataString('access_token');

                tokenType = tokenTypeStorage;
                accessToken = accessTokenStorage;

                requestHeaders['Accept'] = 'application/json';
                requestHeaders['Authorization'] = '$tokenType $accessToken';
                // print(requestHeaders);

                try {
                  final proses = await http.post(
                    url('api/simpanCircleTimeAndroid'),
                    headers: requestHeaders,
                    body: {
                      'id': widget.idOpname,
                      'stok_gudang': stokGudangField.text,
                      'stok_sistem': widget.stokSistem,
                      'catatan': selectedKeteranganOpname != null
                          ? selectedKeteranganOpname.value
                          : '-'
                    },
                  );
                  if (proses.statusCode == 200) {
                    dynamic prosesJson = jsonDecode(proses.body);
                    if (prosesJson['status'] == 'sukses') {
                      showInSnackBar('Sukses');
                      Navigator.popUntil(
                        context,
                        ModalRoute.withName('/opname_stock'),
                      );
                    } else {
                      showInSnackBar('Error : ${prosesJson['message']}');
                    }
                  } else {
                    showInSnackBar('Error Code : ${proses.statusCode}');
                    Map responseJson = jsonDecode(proses.body);

                    if (responseJson.containsKey('message')) {
                      showInSnackBar(responseJson['message']);
                    }
                    print(jsonDecode(proses.body));
                  }
                } catch (e) {
                  print(e);
                }
              },
            ),
          ],
        );
      },
    );
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

  GlobalKey<ScaffoldState> _scaffoldKeyX = new GlobalKey<ScaffoldState>();

  void showInSnackBar(String value) {
    _scaffoldKeyX.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  Future<Null> getHeaderHTTP() async {}

  @override
  void initState() {
    _form = GlobalKey<FormState>();

    selectedKeteranganOpname = null;
    listKeteranganOpname = List<KeteranganOpname>();
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: _scaffoldKeyX,
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          title: Text('Input Opname Circle Time'),
        ),
        body: ListView(
          children: <Widget>[
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
                    Divider(),
                    Row(
                      children: <Widget>[
                        Expanded(
                          flex: 3,
                          child: Container(
                            child: Text(
                              'Stok Gudang',
                              style: TextStyle(
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Container(
                            // height: 30.0,
                            child: Form(
                              key: _form,
                              child: TextFormField(
                                controller: stokGudangField,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  WhitelistingTextInputFormatter.digitsOnly
                                ],
                                // textInputAction: TextInputAction.go,
                                decoration: InputDecoration(
                                  hintText: 'Stok Gudang',
                                  contentPadding: EdgeInsets.all(5.0),
                                ),
                                validator: (thisValue) {
                                  if (thisValue.isEmpty) {
                                    return 'Input tidak boleh kosong!';
                                  }
                                  return null;
                                },
                                onChanged: (ini) {
                                  listKeteranganOpname = List();
                                  selectedKeteranganOpname = null;
                                  int stokSistemX =
                                      int.parse(widget.stokSistem);

                                  int iniD = ini.isEmpty ? 0 : int.parse(ini);
                                  if (stokSistemX != iniD) {
                                    print('if true');
                                    listKeteranganOpname.add(
                                      KeteranganOpname(
                                        value: 'hilang',
                                        nama: 'Barang Hilang',
                                      ),
                                    );
                                    listKeteranganOpname.add(
                                      KeteranganOpname(
                                        value: 'rusak',
                                        nama: 'Barang Rusak',
                                      ),
                                    );
                                    listKeteranganOpname.add(
                                      KeteranganOpname(
                                        value: 'temuan',
                                        nama: 'Barang Temuan',
                                      ),
                                    );

                                    selectedKeteranganOpname = KeteranganOpname(
                                      value: 'hilang',
                                      nama: 'Barang Hilang',
                                    );
                                    setState(() {
                                      listKeteranganOpname =
                                          listKeteranganOpname;
                                    });
                                  } else {
                                    print('if false');
                                    listKeteranganOpname.add(
                                      KeteranganOpname(
                                        value: 'sama',
                                        nama: 'Tidak ada Kekuarangan',
                                      ),
                                    );
                                    selectedKeteranganOpname = KeteranganOpname(
                                      value: 'sama',
                                      nama: 'Tidak ada Kekuarangan',
                                    );
                                    setState(() {
                                      listKeteranganOpname =
                                          listKeteranganOpname;
                                    });
                                  }

                                  setState(() {
                                    stokGudangField.value = TextEditingValue(
                                      selection: stokGudangField.selection,
                                      text: ini,
                                    );
                                  });
                                },
                                onSaved: (thisValue) {
                                  setState(() {
                                    stokGudangField.text = thisValue;
                                  });
                                },
                              ),
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
                              'Keterangan',
                              style: TextStyle(
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        ),
                        listKeteranganOpname.length != 0
                            ? Expanded(
                                flex: 5,
                                child: DropdownButton(
                                  isExpanded: true,
                                  value: selectedKeteranganOpname,
                                  hint: Text('Keterangan'),
                                  onChanged: (ini) {
                                    setState(() {
                                      selectedKeteranganOpname = ini;
                                    });
                                  },
                                  items: listKeteranganOpname
                                      .map(
                                        (KeteranganOpname f) =>
                                            DropdownMenuItem(
                                          child: Text(f.nama),
                                          value: f,
                                        ),
                                      )
                                      .toList(),
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: _isLoading ? Icon(Icons.sync) : Icon(Icons.check),
          onPressed: () {
            if (_isLoading == false) {
              if (_form.currentState.validate()) {
                _konfirmSimpan();
              }
            } else {
              return null;
            }
          },
        ),
      ),
    );
  }
}
