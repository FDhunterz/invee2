import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:invee2/error/error.dart';
import 'package:invee2/localStorage/localStorage.dart';
import 'package:invee2/penjualan/kasir/environment/model.dart';
import 'package:http/http.dart' as http;
import 'package:invee2/routes/env.dart';

Provinsi provinsiState;
List<Provinsi> listProvinsi, listProvinsiX;
bool isCari, isLoading, isError;

String tokenType, accessToken;
Map<String, String> requestHeaders = Map();
GlobalKey<ScaffoldState> _scaffoldKeyProvinsi;

FocusNode cariFocus;
TextEditingController cariController;

showInSnackBarProvinsi(String content) {
  _scaffoldKeyProvinsi.currentState.showSnackBar(
    SnackBar(
      content: Text(content),
    ),
  );
}

class CariProvinsi extends StatefulWidget {
  final Provinsi provinsi;

  CariProvinsi({this.provinsi});

  @override
  _CariProvinsiState createState() => _CariProvinsiState();
}

class _CariProvinsiState extends State<CariProvinsi> {
  getProvinsi() async {
    DataStore dataStore = DataStore();

    var tokenTypeStorage = await dataStore.getDataString('token_type');
    var accessTokenStorage = await dataStore.getDataString('access_token');

    tokenType = tokenTypeStorage;
    accessToken = accessTokenStorage;

    requestHeaders['Accept'] = 'application/json';
    requestHeaders['Authorization'] = '$tokenType $accessToken';

    setState(() {
      isLoading = true;
      isError = false;
    });

    try {
      final response = await http.get(
        url('api/provinsi'),
        headers: requestHeaders,
      );

      if (response.statusCode == 200) {
        dynamic responseJson = jsonDecode(response.body);
        print(responseJson);

        listProvinsi = List<Provinsi>();

        for (var i in responseJson['provinsi']) {
          listProvinsi.add(
            Provinsi(
              idProvinsi: i['p_id'].toString(),
              namaProvinsi: i['p_nama'],
            ),
          );
        }

        listProvinsiX = listProvinsi;

        setState(() {
          isLoading = false;
          isError = false;
        });
      } else if (response.statusCode == 401) {
        showInSnackBarProvinsi(
            'Token kedaluwarsa, silahkan logout dan login kembali');
        setState(() {
          isLoading = false;
          isError = true;
        });
      } else {
        showInSnackBarProvinsi('Error Code = ${response.statusCode}');
        Map responseJson = jsonDecode(response.body);

        if(responseJson.containsKey('message')){
          showInSnackBarProvinsi(responseJson['message']);
        }
        print(jsonDecode(response.body));
        setState(() {
          isLoading = false;
          isError = true;
        });
      }
    } catch (e, stacktrace) {
      print('Error = $e || Stacktrace = $stacktrace');
      showInSnackBarProvinsi('Error = ${e.toString()}');
      setState(() {
        isLoading = false;
        isError = true;
      });
    }
  }

  @override
  void initState() {
    _scaffoldKeyProvinsi = GlobalKey<ScaffoldState>();
    isCari = true;
    isLoading = false;
    isError = false;
    listProvinsi = List();
    getProvinsi();
    provinsiState = widget.provinsi == null
        ? Provinsi(idProvinsi: '', namaProvinsi: '')
        : widget.provinsi;

    cariFocus = FocusNode();
    cariController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: _scaffoldKeyProvinsi,
        appBar: AppBar(
          backgroundColor: isCari ? Colors.white : Colors.green,
          iconTheme: isCari
              ? IconThemeData(
                  color: Colors.black,
                )
              : null,
          title: isCari == true
              ? TextField(
                  decoration: InputDecoration(hintText: 'Cari'),
                  controller: cariController,
                  focusNode: cariFocus,
                  onChanged: (ini) {
                    cariController.value = TextEditingValue(
                        text: ini, selection: cariController.selection);
                        
                    if (cariController.text.isEmpty ||
                        cariController.text == '') {
                      setState(() {
                        listProvinsi = listProvinsiX;
                      });
                    } else {
                      listProvinsi = listProvinsiX;
                      setState(() {
                        listProvinsi = listProvinsi
                            .where((f) =>
                                f.namaProvinsi.toLowerCase().contains(ini))
                            .toList();
                      });
                    }
                  },
                )
              : Text(
                  'Provinsi : ${provinsiState != null ? provinsiState.namaProvinsi : ''}'),
          actions: <Widget>[
            isCari == false
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        isCari = true;
                        cariController.text = '';
                      });
                      Future.delayed(
                        Duration(
                          milliseconds: 200,
                        ),
                        () => FocusScope.of(context).requestFocus(cariFocus),
                      );
                    },
                    icon: Icon(Icons.search),
                  )
                : IconButton(
                    onPressed: () {
                      cariController.text = '';
                      setState(() {
                        isCari = false;
                        listProvinsi = listProvinsiX;
                      });
                    },
                    icon: Icon(Icons.close),
                  )
          ],
        ),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : isError
                ? ErrorCobalLagi(
                    onPress: () => getProvinsi(),
                  )
                : Scrollbar(
                    child: RefreshIndicator(
                      onRefresh: () => getProvinsi(),
                      child: ListView.builder(
                        itemCount: listProvinsi.length,
                        itemBuilder: (BuildContext context, int i) => Container(
                          margin: EdgeInsets.only(
                            top: 3.0,
                            bottom: 3.0,
                            left: 5.0,
                            right: 5.0,
                          ),
                          decoration: BoxDecoration(
                            color: listProvinsi[i].idProvinsi ==
                                    provinsiState.idProvinsi
                                ? Colors.green[100].withOpacity(0.5)
                                : Colors.white,
                            border: Border.all(color: Colors.grey, width: 0.5),
                            borderRadius: BorderRadius.circular(5.0),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                blurRadius: 3.0,
                                spreadRadius: 1.0,
                                color: Colors.grey.withOpacity(0.2),
                                offset: Offset(1.0, 1.0),
                              )
                            ],
                          ),
                          child: ListTile(
                            leading: Icon(FontAwesomeIcons.globe),
                            title: Text(listProvinsi[i].namaProvinsi),
                            onTap: () {
                              setState(() {
                                provinsiState = Provinsi(
                                  idProvinsi: listProvinsi[i].idProvinsi,
                                  namaProvinsi: listProvinsi[i].namaProvinsi,
                                );
                                isCari = false;
                                listProvinsi = listProvinsiX;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pop(context, provinsiState);
          },
          child: Icon(Icons.check),
        ),
      ),
    );
  }
}
