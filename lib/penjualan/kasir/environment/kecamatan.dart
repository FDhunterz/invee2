import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:invee2/error/error.dart';
import 'package:invee2/localStorage/localStorage.dart';
import 'package:invee2/penjualan/kasir/environment/model.dart';
import 'package:invee2/routes/env.dart';
import 'package:http/http.dart' as http;

Kecamatan kecamatanState;
List<Kecamatan> listKecamatan, listKecamatanX;
bool isCari, isLoading, isError;

String tokenType, accessToken;
Map<String, String> requestHeaders = Map();
GlobalKey<ScaffoldState> _scaffoldKeyKecamatan;

FocusNode cariFocus;
TextEditingController cariController;

showInSnackBarKecamatan(String content) {
  _scaffoldKeyKecamatan.currentState.showSnackBar(
    SnackBar(
      content: Text(content),
    ),
  );
}

class CariKecamatan extends StatefulWidget {
  final KabupatenKota kabupatenKota;
  final Kecamatan kecamatan;

  CariKecamatan({
    this.kecamatan,
    this.kabupatenKota,
  });

  @override
  _CariKecamatanState createState() => _CariKecamatanState();
}

class _CariKecamatanState extends State<CariKecamatan> {
  getKecamatan() async {
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
        url('api/desa'),
        headers: requestHeaders,
        body: {
          'kota': widget.kabupatenKota.idKabupatenKota,
        },
      );

      if (response.statusCode == 200) {
        dynamic responseJson = jsonDecode(response.body);
        print(responseJson);

        listKecamatan = List<Kecamatan>();

        for (var i in responseJson['desa']) {
          listKecamatan.add(
            Kecamatan(
              idKecamatan: i['d_id'].toString(),
              namaKecamatan: i['d_nama'],
            ),
          );
        }

        listKecamatanX = listKecamatan;

        setState(() {
          isLoading = false;
          isError = false;
        });
      } else if (response.statusCode == 401) {
        showInSnackBarKecamatan(
            'Token kedaluwarsa, silahkan logout dan login kembali');
        setState(() {
          isLoading = false;
          isError = true;
        });
      } else {
        showInSnackBarKecamatan('Error Code = ${response.statusCode}');
        Map responseJson = jsonDecode(response.body);

        if(responseJson.containsKey('message')){
          showInSnackBarKecamatan(responseJson['message']);
        }
        print(jsonDecode(response.body));
        setState(() {
          isLoading = false;
          isError = true;
        });
      }
    } catch (e, stacktrace) {
      print('Error = $e || Stacktrace = $stacktrace');
      showInSnackBarKecamatan('Error = ${e.toString()}');
      setState(() {
        isLoading = false;
        isError = true;
      });
    }
  }

  @override
  void initState() {
    _scaffoldKeyKecamatan = GlobalKey<ScaffoldState>();
    isLoading = true;
    isError = false;
    isCari = false;
    listKecamatan = List();
    getKecamatan();
    kecamatanState = widget.kecamatan == null
        ? Kecamatan(idKecamatan: '', namaKecamatan: '')
        : widget.kecamatan;

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
        key: _scaffoldKeyKecamatan,
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
                        listKecamatan = listKecamatanX;
                      });
                    } else {
                      listKecamatan = listKecamatanX;

                      setState(() {
                        listKecamatan = listKecamatan
                            .where((f) =>
                                f.namaKecamatan.toLowerCase().contains(ini))
                            .toList();
                      });
                    }
                  },
                )
              : Text(
                  'Kecamatan : ${kecamatanState != null ? kecamatanState.namaKecamatan : ''}'),
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
                        listKecamatan = listKecamatanX;
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
                    onPress: () => getKecamatan(),
                  )
                : Scrollbar(
                    child: RefreshIndicator(
                      onRefresh: () => getKecamatan(),
                      child: ListView.builder(
                        itemCount: listKecamatan.length,
                        itemBuilder: (BuildContext context, int i) => Container(
                          margin: EdgeInsets.only(
                            top: 3.0,
                            bottom: 3.0,
                            left: 5.0,
                            right: 5.0,
                          ),
                          decoration: BoxDecoration(
                            color: listKecamatan[i].idKecamatan ==
                                    kecamatanState.idKecamatan
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
                            leading: Icon(FontAwesomeIcons.home),
                            title: Text(listKecamatan[i].namaKecamatan),
                            onTap: () {
                              setState(() {
                                kecamatanState = Kecamatan(
                                  idKecamatan: listKecamatan[i].idKecamatan,
                                  namaKecamatan: listKecamatan[i].namaKecamatan,
                                );
                                isCari = false;
                                listKecamatan = listKecamatanX;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pop(context, kecamatanState);
          },
          child: Icon(Icons.check),
        ),
      ),
    );
  }
}
