import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import '../../localStorage/localStorage.dart';
import '../../routes/env.dart';
// import '../../shimmer_loading.dart';
// import 'secondary/modal.dart';
import './proses_bayar.dart';
import 'package:http/http.dart' as http;

GlobalKey<ScaffoldState> _scaffoldKeyTE = new GlobalKey<ScaffoldState>();

class TambahEtalase extends StatefulWidget {
  final bool loading;
  TambahEtalase({this.loading});
  @override
  State<StatefulWidget> createState() {
    return _TambahEtalase(
      loading: false,
    );
  }
}

TextEditingController textEtalase = TextEditingController(text: '');

class _TambahEtalase extends State<TambahEtalase> {
  bool loading;
  _TambahEtalase({Key key, this.loading});

  void showInSnackBarTE(String value) {
    _scaffoldKeyTE.currentState.showSnackBar(
      SnackBar(
        content: new Text(value),
      ),
    );
  }

  void simpan() async {
    setState(() {
      loading = true;
    });

    try {
      final simpanEtalase = await http.post(
        url('api/add_etalase'),
        headers: requestHeaders,
        body: {
          'etalase': textEtalase.text.toString(),
        },
      );

      if (simpanEtalase.statusCode == 200) {
        var simpanEtalaseJson = json.decode(simpanEtalase.body);
        if (simpanEtalaseJson['error'] != null) {
          showInSnackBarTE('Gagal! ' + simpanEtalaseJson['error']);
        } else if (simpanEtalaseJson['status'] == 'success') {
          Navigator.popUntil(context, ModalRoute.withName('/kasir'));
        } else if (simpanEtalaseJson['status'] == 'gagal') {
          showInSnackBarTE('Gagal! Hubungi pengembang software!');
        }
      } else {
        showInSnackBarTE(
            'Request failed with status: ${simpanEtalase.statusCode}');
        Map responseJson = jsonDecode(simpanEtalase.body);

        if (responseJson.containsKey('message')) {
          showInSnackBarTE(responseJson['message']);
        }
        print(json.decode(simpanEtalase.body));
      }
    } on TimeoutException catch (_) {
      showInSnackBarTE('Timed out, Try again');
    } catch (e) {
      showInSnackBarTE(e);
    }
    loading = false;
    setState(() {});
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
        print(requestHeaders);
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    isLoading = widget.loading;
    getHeaderHTTP();
    super.initState();
  }

  void dispose() {
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKeyTE,
        appBar: AppBar(
          title: Text('Tambah Etalase'),
        ),
        body: Center(
            child: Column(
          children: <Widget>[
            Container(
                padding: EdgeInsets.all(10),
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(boxShadow: [
                    new BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, .07),
                      blurRadius: 5.0,
                      offset: new Offset(0.0, 6.0),
                    )
                  ]),
                  padding: EdgeInsets.all(6),
                  child: Container(
                      color: Colors.white,
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: <Widget>[
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Nama Etalase : ',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 10),
                            child: TextField(
                              controller: textEtalase,
                              decoration:
                                  InputDecoration(hintText: 'Nama Etalase'),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Container(
                              width: 150,
                              margin: EdgeInsets.only(top: 10),
                              child: RaisedButton(
                                textColor: Colors.white,
                                child: const Text(
                                  'Simpan',
                                  style: TextStyle(fontSize: 16),
                                ),
                                onPressed: () {
                                  simpan();
                                },
                              ),
                            ),
                          ),
                        ],
                      )),
                )),
          ],
        )));
  }
}
