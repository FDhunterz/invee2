import 'package:flutter/material.dart';
import 'package:invee2/localStorage/localStorage.dart';
import 'package:invee2/routes/env.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart';

var tokenType, accessToken, ids;
Map<String, String> requestHeaders = Map();
bool isLoading;
GlobalKey<ScaffoldState> _scaffoldKey;

class DetailAntrian extends StatefulWidget {
  final String id, nomor, name, tanggalDibuat, status, noTelp, email;
  final bool cumanHistory;

  DetailAntrian({
    @required this.noTelp,
    @required this.email,
    this.cumanHistory,
    @required this.status,
    @required this.id,
    @required this.nomor,
    @required this.name,
    @required this.tanggalDibuat,
  });

  @override
  State<StatefulWidget> createState() {
    return _DetailAntrianState();
  }
}

class _DetailAntrianState extends State<DetailAntrian> {
  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  Widget statusAntrian(String status) {
    if (status == 'O') {
      return Container(
        padding: EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          color: Colors.cyan,
        ),
        child: Text(
          'Menunggu Antrian',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      );
    } else if (status == 'P') {
      return Container(
        padding: EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          color: Colors.orange,
        ),
        child: Text(
          'Proses',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      );
    } else if (status == 'C') {
      return Container(
        padding: EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          color: Colors.red,
        ),
        child: Text(
          'Batal',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      );
    } else if (status == 'D') {
      return Container(
        padding: EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          color: Colors.green,
        ),
        child: Text(
          'Selesai',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      );
    } else if (status == 'S') {
      return Container(
        padding: EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          color: Colors.yellow,
        ),
        child: Text(
          'Di Tunda',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      );
    }
    return Container();
  }

  void _dialogAcceptAntrian({
    String title,
    String content,
    Function sendRequest,
  }) {
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
              onPressed: sendRequest,
            )
          ],
        );
      },
    );
  }

  Future<Null> getHeaderHTTP() async {
    var storage = new DataStore();

    var tokenTypeStorage = await storage.getDataString('token_type');
    var accessTokenStorage = await storage.getDataString('access_token');

    tokenType = tokenTypeStorage;
    accessToken = accessTokenStorage;

    requestHeaders['Accept'] = 'application/json';
    requestHeaders['Authorization'] = '$tokenType $accessToken';
    print(requestHeaders);
  }

  void batalAntrian() async {
    try {
      final acceptAntrian = await http.post(
        url('api/cancelAntrianAndroid'),
        headers: requestHeaders,
        body: {
          'id_antrian': widget.id,
        },
      );

      if (acceptAntrian.statusCode == 200) {
        var acceptAntrianJson = json.decode(acceptAntrian.body);
        if (acceptAntrianJson['status'] == 'Success') {
          Navigator.popUntil(
            context,
            ModalRoute.withName('/antrian'),
          );
          print('succes');
        } else if (acceptAntrianJson['status'] == 'Error') {
          showInSnackBar(acceptAntrianJson['message']);
        }
      } else if (acceptAntrian.statusCode == 401) {
        showInSnackBar('Token kedaluwarsa, silahkan login kembali');
      } else {
        showInSnackBar(
            'Request failed with status: ${acceptAntrian.statusCode}');
            
        Map responseJson = jsonDecode(acceptAntrian.body);

        if (responseJson.containsKey('message')) {
          showInSnackBar(responseJson['message']);
        }
        print(jsonDecode(acceptAntrian.body));
      }
    } on TimeoutException catch (_) {
      showInSnackBar('Timed out, Try again');
    } catch (e) {
      print(e);
    }
  }

  void tundaAntrian() async {
    try {
      final acceptAntrian = await http.post(
        url('api/suspendAntrianAndroid'),
        headers: requestHeaders,
        body: {
          'id_antrian': widget.id,
        },
      );

      if (acceptAntrian.statusCode == 200) {
        var acceptAntrianJson = json.decode(acceptAntrian.body);
        if (acceptAntrianJson['status'] == 'Success') {
          Navigator.popUntil(
            context,
            ModalRoute.withName('/antrian'),
          );
          print('succes');
        } else if (acceptAntrianJson['status'] == 'Error') {
          showInSnackBar(acceptAntrianJson['message']);
        }
      } else if (acceptAntrian.statusCode == 401) {
        showInSnackBar('Token kedaluwarsa, silahkan login kembali');
      } else {
        showInSnackBar(
            'Request failed with status: ${acceptAntrian.statusCode}');
        print(jsonDecode(acceptAntrian.body));
      }
    } on TimeoutException catch (_) {
      showInSnackBar('Timed out, Try again');
    } catch (e) {
      print(e);
    }
  }

  void prosesAntrian() async {
    try {
      final acceptAntrian = await http.post(
        url('api/acceptListAntrianAndroid'),
        headers: requestHeaders,
        body: {
          'id_antrian': widget.id,
        },
      );

      if (acceptAntrian.statusCode == 200) {
        var acceptAntrianJson = json.decode(acceptAntrian.body);
        if (acceptAntrianJson['status'] == 'Success') {
          Navigator.popUntil(
            context,
            ModalRoute.withName('/antrian'),
          );
          print('succes');
        } else if (acceptAntrianJson['status'] == 'Error') {
          showInSnackBar(acceptAntrianJson['message']);
        }
      } else if (acceptAntrian.statusCode == 401) {
        showInSnackBar('Token kedaluwarsa, silahkan login kembali');
      } else {
        showInSnackBar(
            'Request failed with status: ${acceptAntrian.statusCode}');
        print(jsonDecode(acceptAntrian.body));
      }
    } on TimeoutException catch (_) {
      showInSnackBar('Timed out, Try again');
    } catch (e) {
      print(e);
    }
  }

  void selesaiAntrian() async {
    try {
      final acceptAntrian = await http.post(
        url('api/endAntrianAndroid'),
        headers: requestHeaders,
        body: {
          'id_antrian': widget.id,
        },
      );

      if (acceptAntrian.statusCode == 200) {
        var acceptAntrianJson = json.decode(acceptAntrian.body);
        if (acceptAntrianJson['status'] == 'Success') {
          Navigator.popUntil(context, ModalRoute.withName('/antrian'));
          print('succes');
        } else if (acceptAntrianJson['status'] == 'Error') {
          showInSnackBar(acceptAntrianJson['message']);
        }
      } else if (acceptAntrian.statusCode == 401) {
        showInSnackBar('Token kedaluwarsa, silahkan login kembali');
      } else {
        showInSnackBar(
            'Request failed with status: ${acceptAntrian.statusCode}');
        print(jsonDecode(acceptAntrian.body));
      }
    } on TimeoutException catch (_) {
      showInSnackBar('Timed out, Try again');
    } catch (e) {
      print(e);
    }
  }

  @override
  initState() {
    _scaffoldKey = new GlobalKey<ScaffoldState>();

    getHeaderHTTP();

    isLoading = false;
    super.initState();
  }

  Widget actionButton(String status) {
    if (widget.cumanHistory == false || widget.cumanHistory == null) {
      if (status == 'O') {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(
                right: 15.0,
              ),
              child: RaisedButton(
                color: Colors.red,
                textColor: Colors.white,
                child: Text('Batal'),
                onPressed: () {
                  _dialogAcceptAntrian(
                    title: 'Peringatan!',
                    content: 'Ingin membatalkan antrian ini?',
                    sendRequest: () {
                      batalAntrian();
                    },
                  );
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                right: 15.0,
              ),
              child: RaisedButton(
                color: Colors.yellow,
                textColor: Colors.black,
                child: Text('Tunda'),
                onPressed: () {
                  _dialogAcceptAntrian(
                    title: 'Peringatan!',
                    content: 'Ingin menunda antrian ini?',
                    sendRequest: () {
                      tundaAntrian();
                    },
                  );
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
            RaisedButton(
              color: Colors.cyan,
              child: Text(
                'Proses',
                style: TextStyle(color: Colors.white),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              onPressed: () {
                _dialogAcceptAntrian(
                  title: 'Peringatan!',
                  content: 'Ingin memproses antrian ini?',
                  sendRequest: () {
                    prosesAntrian();
                  },
                );
              },
            )
          ],
        );
      } else if (status == 'P') {
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(
                right: 15.0,
              ),
              child: RaisedButton(
                color: Colors.red,
                textColor: Colors.white,
                child: Text('Batal'),
                onPressed: () {
                  _dialogAcceptAntrian(
                    title: 'Peringatan!',
                    content: 'Ingin membatalkan antrian ini?',
                    sendRequest: () {
                      batalAntrian();
                    },
                  );
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
            RaisedButton(
              color: Colors.cyan,
              child: Text(
                'Selesai',
                style: TextStyle(color: Colors.white),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50.0),
              ),
              onPressed: () {
                _dialogAcceptAntrian(
                  title: 'Peringatan!',
                  content: 'Ingin mengakhiri nomor antrian ini?',
                  sendRequest: () {
                    selesaiAntrian();
                  },
                );
              },
            ),
          ],
        );
      } else if (status == 'C') {
        return Container();
      } else if (status == 'D') {
        return Container();
      } else if (status == 'S') {
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(
                right: 15.0,
              ),
              child: RaisedButton(
                color: Colors.red,
                textColor: Colors.white,
                child: Text('Batal'),
                onPressed: () {
                  _dialogAcceptAntrian(
                    title: 'Peringatan!',
                    content: 'Ingin membatalkan antrian ini?',
                    sendRequest: () {
                      batalAntrian();
                    },
                  );
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
            RaisedButton(
              color: Colors.cyan,
              child: Text(
                'Proses',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                _dialogAcceptAntrian(
                  title: 'Peringatan!',
                  content: 'Ingin memproses antrian ini?',
                  sendRequest: () {
                    prosesAntrian();
                  },
                );
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          ],
        );
      }
    }
    // return FloatingActionButton(
    //   child: Icon(Icons.check),
    //   onPressed: () {
    //     _dialogAcceptAntrian('Peringatan', 'Apa anda yakin?');
    //   },
    // );
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Detail Antrian'),
        ),
        floatingActionButton: actionButton(widget.status),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Card(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(5.0),
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Column(
                          children: <Widget>[
                            Text(
                              'Nomor Urut',
                              style: TextStyle(
                                fontSize: 25.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.nomor,
                              style: TextStyle(
                                fontSize: 105.0,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Expanded(
                            flex: 4,
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(5.0),
                              child: Text(
                                'Nama Customer',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(5.0),
                              child: Text(
                                widget.name,
                                style: TextStyle(
                                  color: Colors.black54,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Expanded(
                            flex: 4,
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(5.0),
                              child: Text(
                                'Email Customer',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(5.0),
                              child: Text(
                                widget.email,
                                style: TextStyle(
                                  color: Colors.black54,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Expanded(
                            flex: 4,
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(5.0),
                              child: Text(
                                'No. Telpon Customer',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(5.0),
                              child: Text(
                                widget.noTelp,
                                style: TextStyle(
                                  color: Colors.black54,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Expanded(
                            flex: 4,
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(5.0),
                              child: Text(
                                'Tanggal Dibuat',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(5.0),
                              child: Text(
                                DateFormat('dd MMMM yyyy hh:mm:ss').format(
                                    DateTime.parse(widget.tanggalDibuat)),
                                style: TextStyle(
                                  color: Colors.black54,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Expanded(
                            flex: 4,
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(5.0),
                              child: Text(
                                'Status',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: statusAntrian(widget.status),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
