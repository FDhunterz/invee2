import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:invee2/error/error.dart';
// import 'package:invee2/gudang/opname_stock/cariOpnameStock.dart';
import 'package:invee2/localStorage/localStorage.dart';
import 'package:invee2/penjualan/kasir/environment/model.dart';
import 'package:invee2/routes/env.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter/services.dart';

Produk produkState;
List<Produk> listProduk, listProdukX;
bool isCari, isLoading, isError;

String tokenType, accessToken;
Map<String, String> requestHeaders = Map();
GlobalKey<ScaffoldState> _scaffoldKeyProduk;

FocusNode cariFocus;
TextEditingController cariController;
String _scanBarcode;

showInSnackBarProduk(String content) {
  _scaffoldKeyProduk.currentState.showSnackBar(
    SnackBar(
      content: Text(content),
    ),
  );
}

class CariProduk extends StatefulWidget {
  final Produk produk;

  CariProduk({this.produk});

  @override
  _CariProdukState createState() => _CariProdukState();
}

class _CariProdukState extends State<CariProduk> {
  int delayCari;
  Timer timer;

  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
    } on PlatformException catch (_) {
      showInSnackBarProduk('Failed to get platform version.');
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    List<Produk> filterListProduk = listProdukX;

    filterListProduk = filterListProduk.where((Produk test) {
      return test.kodeProduk
          .toLowerCase()
          .contains(barcodeScanRes.toLowerCase());
    }).toList();
    if (filterListProduk.length == 1) {
      setState(() {
        produkState = Produk(
          idProduk: filterListProduk[0].idProduk,
          namaProduk: filterListProduk[0].namaProduk,
          kodeProduk: filterListProduk[0].kodeProduk,
          kodeSatuan1: filterListProduk[0].kodeSatuan1,
          kodeSatuan2: filterListProduk[0].kodeSatuan2,
          kodeSatuan3: filterListProduk[0].kodeSatuan3,
          minimalBeliOffline: filterListProduk[0].minimalBeliOffline,
        );
      });
      showInSnackBarProduk('Produk ada');
      Navigator.pop(context, produkState);
    } else {
      showInSnackBarProduk('Produk tidak ada');
    }
  }

  getProduk() async {
    DataStore dataStore = DataStore();

    String tokenTypeStorage = await dataStore.getDataString('token_type');
    String accessTokenStorage = await dataStore.getDataString('access_token');

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
        url('api/cariProduk'),
        headers: requestHeaders,
        body: {
          'cari': cariController.text,
        },
      );

      if (response.statusCode == 200) {
        dynamic responseJson = jsonDecode(response.body);
        print(responseJson);

        listProduk = List<Produk>();

        for (var i in responseJson) {
          listProduk.add(
            Produk(
              idProduk: i['i_id'].toString(),
              namaProduk: i['i_name'],
              kodeProduk: i['i_code'],
              kodeSatuan1: i['itp_ciunit'],
              kodeSatuan2: i['itp_ciunit2'],
              kodeSatuan3: i['itp_ciunit3'],
              namaSatuan1: i['iu_name'],
              namaSatuan2: i['iu_name2'],
              namaSatuan3: i['iu_name3'],
              minimalBeliOffline: i['i_minbuyoffline'],
            ),
          );
        }

        listProdukX = listProduk;

        setState(() {
          isLoading = false;
          isError = false;
        });
      } else if (response.statusCode == 401) {
        showInSnackBarProduk(
            'Token kedaluwarsa, silahkan logout dan login kembali');
        setState(() {
          isLoading = false;
          isError = true;
        });
      } else {
        showInSnackBarProduk('Error Code = ${response.statusCode}');
        Map responseJson = jsonDecode(response.body);

        if (responseJson.containsKey('message')) {
          showInSnackBarProduk(responseJson['message']);
        }
        print(jsonDecode(response.body));
        setState(() {
          isLoading = false;
          isError = true;
        });
      }
    } catch (e, stacktrace) {
      print('Error = $e || Stacktrace = $stacktrace');
      showInSnackBarProduk('Error = ${e.toString()}');
      setState(() {
        isLoading = false;
        isError = true;
      });
    }
  }

  delayRequestFunction() async {
    timer = Timer.periodic(Duration(seconds: 1), (Timer timerX) {
      print(delayCari);
      if (delayCari == 0) {
        getProduk();
        timer.cancel();
      } else {
        delayCari -= 1;
      }
    });
  }

  @override
  void initState() {
    _scaffoldKeyProduk = GlobalKey<ScaffoldState>();
    delayCari = 0;
    isLoading = true;
    isCari = false;
    _scanBarcode = null;
    getProduk();
    produkState = widget.produk == null
        ? Produk(idProduk: '', namaProduk: '')
        : widget.produk;

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
        key: _scaffoldKeyProduk,
        appBar: AppBar(
          backgroundColor: isCari ? Colors.white : Colors.green,
          iconTheme: isCari
              ? IconThemeData(
                  color: Colors.black,
                )
              : null,
          title: isCari == true
              ? TextField(
                  decoration: InputDecoration(hintText: 'Cari Nama/Kode'),
                  controller: cariController,
                  autofocus: true,
                  focusNode: cariFocus,
                  onChanged: (ini) async {
                    cariController.value = TextEditingValue(
                        text: ini, selection: cariController.selection);

                    if (delayCari != 0 && delayCari <= 2) {
                      timer.cancel();
                    }
                    delayCari = 2;
                    delayRequestFunction();
                  },
                )
              : Text(
                  'Produk : ${produkState != null ? produkState.namaProduk : ''}'),
          actions: <Widget>[
            isCari == false
                ? IconButton(
                    onPressed: () async {
                      setState(() {
                        isCari = true;
                        cariController.clear();
                      });
                      Future.delayed(
                        Duration(
                          milliseconds: 200,
                        ),
                        () {
                          FocusScope.of(context).requestFocus(cariFocus);
                        },
                      );
                    },
                    icon: Icon(Icons.search),
                  )
                : IconButton(
                    onPressed: () {
                      cariController.clear();
                      setState(() {
                        isCari = false;
                        listProduk = listProdukX;
                      });
                      getProduk();
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
                    onPress: () => getProduk(),
                  )
                : RefreshIndicator(
                    onRefresh: () => getProduk(),
                    child: Scrollbar(
                      child: ListView.builder(
                        itemCount: listProduk.length,
                        itemBuilder: (BuildContext context, int i) => Container(
                          margin: EdgeInsets.only(
                            top: 3.0,
                            bottom: 3.0,
                            left: 5.0,
                            right: 5.0,
                          ),
                          decoration: BoxDecoration(
                            color: listProduk[i].kodeProduk ==
                                    produkState.kodeProduk
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
                            leading: Icon(FontAwesomeIcons.cubes),
                            title: Text(listProduk[i].namaProduk),
                            subtitle: Text(listProduk[i].kodeProduk),
                            trailing: Text(listProduk[i].namaSatuan1),
                            onTap: () {
                              if (isCari) {
                                getProduk();
                              }

                              setState(() {
                                produkState = Produk(
                                  idProduk: listProduk[i].idProduk,
                                  namaProduk: listProduk[i].namaProduk,
                                  kodeProduk: listProduk[i].kodeProduk,
                                  kodeSatuan1: listProduk[i].kodeSatuan1,
                                  kodeSatuan2: listProduk[i].kodeSatuan2,
                                  kodeSatuan3: listProduk[i].kodeSatuan3,
                                  minimalBeliOffline:
                                      listProduk[i].minimalBeliOffline,
                                );
                                isCari = false;
                                cariController.clear();
                              });
                              Navigator.pop(context, produkState);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
        // floatingActionButton: isLoading
        //     ? null
        //     : isCari
        //         ? null
        //         : FloatingActionButton.extended(
        //             tooltip: 'Scan Kode Produk',
        //             label: Text('Scan Barcode'),
        //             onPressed: () async {
        //               scanBarcodeNormal();
        //             },
        //             icon: Icon(FontAwesomeIcons.barcode),
        //           ),
      ),
    );
  }
}
