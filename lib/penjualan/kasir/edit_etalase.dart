import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:invee2/localStorage/localStorage.dart';
import 'package:invee2/routes/env.dart';



GlobalKey<ScaffoldState> _editetalse2 = new GlobalKey<ScaffoldState>();
TextEditingController textnama;
String tokenType, accessToken;
Map<String, String> requestHeaders = Map();

class EditEtalase extends StatefulWidget {
  final etalase;
  final String nama;
  EditEtalase({this.etalase, this.nama});
  @override
  State<StatefulWidget> createState() {
    return _EditEtalase(nama: nama, etalase: etalase);
  }
}

class _EditEtalase extends State<EditEtalase> {
  String nama;
  final etalase;
  _EditEtalase({Key key, this.nama, this.etalase});

  void alertEdit(String value) {
    _editetalse2.currentState.showSnackBar(
      SnackBar(
        content: new Text(value),
      ),
    );
  }

  void simpan() async {
    try {
      final simpanEtalase = await http.post(
        url('api/edit_etalase/$etalase'),
        headers: requestHeaders,
        body: {'namaetalase': textnama.text.toString()},
      );
      if (simpanEtalase.statusCode == 200) {
        var simpanEtalaseJson = json.decode(simpanEtalase.body);
        print(simpanEtalaseJson);
        if (simpanEtalaseJson['error'] != null) {
          alertEdit('Gagal! ' + simpanEtalaseJson['error']);
        } else if (simpanEtalaseJson['status'] == 'success') {
          Navigator.popUntil(context, ModalRoute.withName('/kasir'));
        } else if (simpanEtalaseJson['status'] == 'gagal') {
          alertEdit('Gagal! Hubungi pengembang software!');
        }
      } else {
        alertEdit('Request failed with status: ${simpanEtalase.statusCode}');
        Map responseJson = jsonDecode(simpanEtalase.body);

        if(responseJson.containsKey('message')){
          alertEdit(responseJson['message']);
        }
        print(json.decode(simpanEtalase.body));
      }
    } on TimeoutException catch (_) {
      alertEdit('Timed out, Try again');
    } catch (e) {
      alertEdit(e.toString());
    }
    setState(() {});
  }

  @override
  void initState() {
    getHeaderHTTP();
    textnama = TextEditingController(text: nama.toString());
    super.initState();
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
  Widget build(BuildContext context) {
    return Scaffold(
      key: _editetalse2,
      appBar: AppBar(
        title: Text('Edit Etalase'),
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
                            controller: textnama,
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
      )),
    );
  }
}
