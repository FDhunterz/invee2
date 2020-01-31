import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:invee2/error/error.dart';
import 'package:invee2/localStorage/localStorage.dart';
import 'package:invee2/penjualan/kasir/environment/model.dart';
import 'package:invee2/routes/env.dart';
import 'package:http/http.dart' as http;

KabupatenKota kabupatenKotaState;
Provinsi provinsi;
List<KabupatenKota> listKabupatenKota, listKabupatenKotaX;
bool isCari, isLoading, isError;

String tokenType, accessToken;
Map<String, String> requestHeaders = Map();
GlobalKey<ScaffoldState> _scaffoldKeyKabupatenKota;

FocusNode cariFocus;
TextEditingController cariController;

showInSnackBarKabupatenKota(String content) {
  _scaffoldKeyKabupatenKota.currentState.showSnackBar(
    SnackBar(
      content: Text(content),
    ),
  );
}

class CariKabupatenKota extends StatefulWidget {
  final Provinsi provinsi;
  final KabupatenKota kabupatenKota;

  CariKabupatenKota({
    this.provinsi,
    this.kabupatenKota,
  });

  @override
  _CariKabupatenKotaState createState() => _CariKabupatenKotaState();
}

class _CariKabupatenKotaState extends State<CariKabupatenKota> {
  getKabupatenKota() async {
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
      final response = await http.post(
        url('api/kota'),
        headers: requestHeaders,
        body: {
          'provinsi': widget.provinsi.idProvinsi,
        },
      );

      if (response.statusCode == 200) {
        dynamic responseJson = jsonDecode(response.body);
        print(responseJson);

        listKabupatenKota = List<KabupatenKota>();

        for (var i in responseJson['kota']) {
          listKabupatenKota.add(
            KabupatenKota(
              idKabupatenKota: i['c_id'].toString(),
              namaKabupatenKota: i['c_nama'],
            ),
          );
        }

        listKabupatenKotaX = listKabupatenKota;

        setState(() {
          isLoading = false;
          isError = false;
        });
      } else if (response.statusCode == 401) {
        showInSnackBarKabupatenKota(
            'Token kedaluwarsa, silahkan logout dan login kembali');
        setState(() {
          isLoading = false;
          isError = true;
        });
      } else {
        showInSnackBarKabupatenKota('Error Code = ${response.statusCode}');
        Map responseJson = jsonDecode(response.body);

        if(responseJson.containsKey('message')){
          showInSnackBarKabupatenKota(responseJson['message']);
        }
        print(jsonDecode(response.body));
        setState(() {
          isLoading = false;
          isError = true;
        });
      }
    } catch (e, stacktrace) {
      print('Error = $e || Stacktrace = $stacktrace');
      showInSnackBarKabupatenKota('Error = ${e.toString()}');
      setState(() {
        isLoading = false;
        isError = true;
      });
    }
  }

  @override
  void initState() {
    _scaffoldKeyKabupatenKota = GlobalKey<ScaffoldState>();
    isLoading = true;
    isError = false;
    isCari = false;
    listKabupatenKota = List();
    getKabupatenKota();
    kabupatenKotaState = widget.kabupatenKota == null
        ? KabupatenKota(idKabupatenKota: '', namaKabupatenKota: '')
        : widget.kabupatenKota;

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
        key: _scaffoldKeyKabupatenKota,
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
                        listKabupatenKota = listKabupatenKotaX;
                      });
                    } else {
                      listKabupatenKota = listKabupatenKotaX;
                      setState(() {
                        listKabupatenKota = listKabupatenKota
                            .where((f) =>
                                f.namaKabupatenKota.toLowerCase().contains(ini))
                            .toList();
                      });
                    }
                  },
                )
              : Text(
                  'Kabupaten Kota : ${kabupatenKotaState != null ? kabupatenKotaState.namaKabupatenKota : ''}'),
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
                        listKabupatenKota = listKabupatenKotaX;
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
                    onPress: () => getKabupatenKota(),
                  )
                : Scrollbar(
                    child: RefreshIndicator(
                      onRefresh: () => getKabupatenKota(),
                      child: ListView.builder(
                        itemCount: listKabupatenKota.length,
                        itemBuilder: (BuildContext context, int i) => Container(
                          margin: EdgeInsets.only(
                            top: 3.0,
                            bottom: 3.0,
                            left: 5.0,
                            right: 5.0,
                          ),
                          decoration: BoxDecoration(
                            color: listKabupatenKota[i].idKabupatenKota ==
                                    kabupatenKotaState.idKabupatenKota
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
                            leading: Icon(FontAwesomeIcons.city),
                            title: Text(listKabupatenKota[i].namaKabupatenKota),
                            onTap: () {
                              setState(() {
                                kabupatenKotaState = KabupatenKota(
                                  idKabupatenKota:
                                      listKabupatenKota[i].idKabupatenKota,
                                  namaKabupatenKota:
                                      listKabupatenKota[i].namaKabupatenKota,
                                );
                                isCari = false;
                                listKabupatenKota = listKabupatenKotaX;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pop(context, kabupatenKotaState);
          },
          child: Icon(Icons.check),
        ),
      ),
    );
  }
}
