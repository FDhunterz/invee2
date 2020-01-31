import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:invee2/error/error.dart';
import 'package:invee2/localStorage/localStorage.dart';
import 'package:invee2/penjualan/kasir/environment/model.dart';
// import 'package:invee2/penjualan/kasir/tambah_penjualan.dart';
import 'package:invee2/routes/env.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

Customer customerState;
List<Customer> listCustomer, listCustomerX;
bool isCari, isLoading, isError;

String tokenType, accessToken;
Map<String, String> requestHeaders = Map();
GlobalKey<ScaffoldState> _scaffoldKeyCustomer;

FocusNode cariFocus;
TextEditingController cariController;

showInSnackBarCustomer(String content) {
  _scaffoldKeyCustomer.currentState.showSnackBar(
    SnackBar(
      content: Text(content),
    ),
  );
}

class CariCustomer extends StatefulWidget {
  final Customer customer;

  CariCustomer({this.customer});

  @override
  _CariCustomerState createState() => _CariCustomerState();
}

class _CariCustomerState extends State<CariCustomer> {
  Timer timer;
  int delayRequest;

  getCustomer() async {
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
        url('api/cariCustomer'),
        headers: requestHeaders,
        body: {
          'cari': cariController.text,
        },
      );

      if (response.statusCode == 200) {
        dynamic responseJson = jsonDecode(response.body);
        print(responseJson);

        listCustomer = List<Customer>();

        for (var i in responseJson) {
          listCustomer.add(
            Customer(
              idCustomer: i['cm_id'].toString(),
              kodeCustomer: i['cm_code'],
              namaCustomer: i['cm_name'],
              alamat: i['cm_address'],
              idKabupatenKota:
                  i['cm_city'] == 'null' ? null : i['cm_city'].toString(),
              idKecamatan: i['cm_district'] == 'null'
                  ? null
                  : i['cm_district'].toString(),
              idProvinsi: i['cm_province'] == 'null'
                  ? null
                  : i['cm_province'].toString(),
              namaProvinsi: i['p_nama'] == 'null' ? null : i['p_nama'],
              namaKecamatan: i['d_nama'] == 'null' ? null : i['d_nama'],
              namaKabupatenKota: i['c_nama'] == 'null' ? null : i['c_nama'],
              kodePos: i['cm_postalcode'] == 'null' ? null : i['cm_postalcode'],
              email: i['cm_email'] == null || i['cm_email'] == 'null'
                  ? '-'
                  : i['cm_email'],
              noTelp: i['cm_nphone'] == null || i['cm_nphone'] == 'null'
                  ? '-'
                  : i['cm_nphone'],
            ),
          );
        }

        listCustomerX = listCustomer;

        setState(() {
          isLoading = false;
          isError = false;
        });
      } else if (response.statusCode == 401) {
        showInSnackBarCustomer(
            'Token kedaluwarsa, silahkan logout dan login kembali');
        setState(() {
          isLoading = false;
          isError = true;
        });
      } else {
        showInSnackBarCustomer('Error Code = ${response.statusCode}');
        Map responseJson = jsonDecode(response.body);

        if (responseJson.containsKey('message')) {
          showInSnackBarCustomer(responseJson['message']);
        }
        print(jsonDecode(response.body));
        setState(() {
          isLoading = false;
          isError = true;
        });
      }
    } catch (e, stacktrace) {
      print('Error = $e || Stacktrace = $stacktrace');
      showInSnackBarCustomer('Error = ${e.toString()}');
      setState(() {
        isLoading = false;
        isError = true;
      });
    }
  }

  delayRequestFunction() {
    timer = Timer.periodic(Duration(seconds: 1), (timerX) {
      if (delayRequest < 1) {
        timer.cancel();
        getCustomer();
      } else {
        delayRequest -= 1;
      }
    });
  }

  @override
  void initState() {
    delayRequest = 0;
    _scaffoldKeyCustomer = GlobalKey<ScaffoldState>();
    isCari = false;
    isLoading = true;
    getCustomer();
    customerState = widget.customer == null
        ? Customer(idCustomer: '', namaCustomer: '')
        : widget.customer;

    cariFocus = FocusNode();
    cariController = TextEditingController();
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
        key: _scaffoldKeyCustomer,
        appBar: AppBar(
          backgroundColor: isCari ? Colors.white : Colors.green,
          iconTheme: isCari
              ? IconThemeData(
                  color: Colors.black,
                )
              : null,
          title: isCari == true
              ? TextField(
                  decoration:
                      InputDecoration(hintText: 'Cari Nama/Email/Kode/HP'),
                  controller: cariController,
                  autofocus: true,
                  focusNode: cariFocus,
                  onChanged: (ini) async {
                    cariController.value = TextEditingValue(
                        text: ini, selection: cariController.selection);

                    if (delayRequest != 0 && delayRequest <= 2) {
                      timer.cancel();
                    }
                    delayRequest = 2;
                    delayRequestFunction();
                  },
                )
              : Text(
                  'Customer : ${customerState != null ? customerState.namaCustomer : ''}'),
          actions: <Widget>[
            isCari == false
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        isCari = true;
                        cariController.clear();
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
                      cariController.clear();
                      setState(() {
                        isCari = false;
                        listCustomer = listCustomerX;
                      });
                      getCustomer();
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
                    onPress: () => getCustomer(),
                  )
                : Scrollbar(
                    child: RefreshIndicator(
                      onRefresh: () => getCustomer(),
                      child: ListView.builder(
                        itemCount: listCustomer.length,
                        itemBuilder: (BuildContext context, int i) => Container(
                          margin: EdgeInsets.only(
                            top: 3.0,
                            bottom: 3.0,
                            left: 5.0,
                            right: 5.0,
                          ),
                          decoration: BoxDecoration(
                            color: listCustomer[i].kodeCustomer ==
                                    customerState.kodeCustomer
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
                            leading: Icon(FontAwesomeIcons.user),
                            title: Text(listCustomer[i].namaCustomer),
                            subtitle: Text(listCustomer[i].email),
                            trailing: Text(listCustomer[i].noTelp),
                            onTap: () {
                              if (isCari) {
                                getCustomer();
                              }
                              setState(() {
                                customerState = Customer(
                                  idCustomer: listCustomer[i].idCustomer,
                                  namaCustomer: listCustomer[i].namaCustomer,
                                  idKabupatenKota:
                                      listCustomer[i].idKabupatenKota,
                                  idKecamatan: listCustomer[i].idKecamatan,
                                  idProvinsi: listCustomer[i].idProvinsi,
                                  alamat: listCustomer[i].alamat,
                                  kodePos: listCustomer[i].kodePos,
                                  kodeCustomer: listCustomer[i].kodeCustomer,
                                  namaKabupatenKota:
                                      listCustomer[i].namaKabupatenKota,
                                  namaKecamatan: listCustomer[i].namaKecamatan,
                                  namaProvinsi: listCustomer[i].namaProvinsi,
                                  noTelp: listCustomer[i].noTelp,
                                  email: listCustomer[i].email,
                                );
                                isCari = false;
                                cariController.clear();
                              });
                              Navigator.pop(context, customerState);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {
        //     if (customerState != null) {
        //       Navigator.pop(context, customerState);
        //     } else {
        //       showInSnackBarCustomer('Pilih Customer terlebih dahulu');
        //     }
        //   },
        //   child: Icon(Icons.check),
        // ),
      ),
    );
  }
}
