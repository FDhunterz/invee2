import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
// import 'package:invee2/penjualan/kasir/kasir.dart';
// import 'package:invee2/routes/navigator.dart';
import '../../localStorage/localStorage.dart';
import '../../routes/env.dart';
// import '../../shimmer_loading.dart';
import 'secondary/modal.dart';
import './proses_bayar.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

Map<String, String> requestHeaders = Map();
GlobalKey<ScaffoldState> _scaffoldKeyTEP = new GlobalKey<ScaffoldState>();
String tokenTypeStorage;
String accessTokenStorage;
bool isLoading;
String nama, etalase;
String code;

class TambahProdukEtalase extends StatefulWidget {
  final String nama;
  final String etalase;
  final String code;
  TambahProdukEtalase({this.nama, this.etalase, this.code});
  @override
  State<StatefulWidget> createState() {
    return _TambahProdukEtalase(nama: nama, code: code, etalase: etalase);
  }
}

class _TambahProdukEtalase extends State<TambahProdukEtalase> {
  final String nama, etalase;
  String code;

  _TambahProdukEtalase({Key key, @required this.nama, this.code, this.etalase});

  TextEditingController _filter = new TextEditingController();
  String _searchText = "";
  List names = new List(); // names we get from API
  List filteredNames = new List(); // names filtered by search text
  Icon _searchIcon = new Icon(Icons.search);
  Widget _appBarTitle = new Text('Pencarian');

  void showInSnackBarTE(String value) {
    _scaffoldKeyTEP.currentState.showSnackBar(
      SnackBar(
        content: new Text(value),
      ),
    );
  }

  Future<List<DataProduk>> dataproduk() async {
    setState(() {
      isLoading = true;
    });

    var storage = new DataStore();

    var tokenTypeStorage = await storage.getDataString('token_type');
    var accessTokenStorage = await storage.getDataString('access_token');

    tokenType = tokenTypeStorage;
    accessToken = accessTokenStorage;

    requestHeaders['Accept'] = 'application/json';
    requestHeaders['Authorization'] = '$tokenType $accessToken';
    print(requestHeaders);

    try {
      final stock = await http.post(
        url('api/tambahProdukEtalaseAndroid'),
        body: {'etalase': etalase},
        headers: requestHeaders,
      );

      if (stock.statusCode == 200) {
        var detailJson = jsonDecode(stock.body);
        print(detailJson);
        // print('detailJson $detailJson');
        dataProdukArray = [];
        for (var i in detailJson['produk']) {
          DataProduk datap = DataProduk(
            namaproduk: i['i_name'].toString(),
            code: i['i_id'].toString(),
            check: i['ed_isavaible'] != null ? true : false,
          );
          dataProdukArray.add(datap);
        }

        print('dataProdukArray $dataProdukArray');
        print('dataProdukArray length ${dataProdukArray.length}');
        setState(() {
          isLoading = false;
        });
        return dataProdukArray;
      } else {
        showInSnackBarTE('Request failed with status: ${stock.statusCode}');
        Map responseJson = jsonDecode(stock.body);

        if (responseJson.containsKey('message')) {
          showInSnackBarTE(responseJson['message']);
        }
        setState(() {
          isLoading = false;
        });
        return null;
      }
    } on TimeoutException catch (_) {
      showInSnackBarTE('Timed out, Try again');
      setState(() {
        isLoading = false;
      });
    } on SocketException catch (_) {
      showInSnackBarTE('Host not found');
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
    setState(() {
      isLoading = false;
    });
    return null;
  }

  void simpan() async {
    try {
      print(code.toString());
      final simpanproduk = await http.post(
        url('api/add_produk'),
        headers: requestHeaders,
        body: {
          'produk': code.toString(),
          'e_id': etalase.toString(),
          'android': 'true',
        },
      );

      if (simpanproduk.statusCode == 200) {
        var simpanprodukJson = json.decode(simpanproduk.body);
        if (simpanprodukJson['error'] != null) {
          showInSnackBarTE('Gagal! ' + simpanprodukJson['error']);
        } else if (simpanprodukJson['status'] == 'success') {
          // Navigator.popUntil(
          //   context,
          //   ModalRoute.withName('/penjualan_offline'),
          // );
          showInSnackBarTE('Berhasil! Mengubah Etalase Produk!');
        } else if (simpanprodukJson['status'] == 'gagal') {
          showInSnackBarTE('Gagal! Hubungi pengembang software!');
        }
      } else {
        showInSnackBarTE(
            'Request failed with status: ${simpanproduk.statusCode}');
        Map responseJson = jsonDecode(simpanproduk.body);

        if (responseJson.containsKey('message')) {
          showInSnackBarTE(responseJson['message']);
        }
        print(json.decode(simpanproduk.body));
      }
    } on TimeoutException catch (_) {
      showInSnackBarTE('Timed out, Try again');
    } catch (e) {
      showInSnackBarTE(e);
    }
    setState(() {});
  }

  Future<Null> getHeaderHTTP() async {
    try {
      var storage = new DataStore();

      var tokenTypeStorage = await storage.getDataString('token_type');
      var accessTokenStorage = await storage.getDataString('access_token');

      tokenType = tokenTypeStorage;
      accessToken = accessTokenStorage;

      requestHeaders['Accept'] = 'application/json';
      requestHeaders['Authorization'] = '$tokenType $accessToken';
      print(requestHeaders);
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    dataProdukArray = [];
    isLoading = false;
    getHeaderHTTP();
    dataproduk();
    super.initState();
  }

  void dispose() {
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKeyTEP,
        appBar: AppBar(
          title: Text('Edit Produk Etalase ' + nama),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                showSearch(
                    context: context, delegate: ProdukSearch(id: etalase));
              },
            ),
          ],
        ),
        body: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 1,
          child: Scrollbar(
              child: Column(
            children: <Widget>[
              isLoading == true
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : dataProdukArray.length == 0
                      ? Card(
                          child: ListTile(
                            title: Text(
                              'Tidak ada data',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : Expanded(
                          child: Scrollbar(
                            child: ListView.builder(
                              // scrollDirection: Axis.horizontal,
                              itemCount: dataProdukArray.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Card(
                                  child: CheckboxListTile(
                                    title:
                                        Text(dataProdukArray[index].namaproduk),
                                    value: dataProdukArray[index].check
                                        ? true
                                        : false,
                                    onChanged: (value) {
                                      code = dataProdukArray[index].code;
                                      simpan();
                                      print(value);
                                      setState(() {
                                        dataProdukArray[index].check = value;
                                      });
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
            ],
          )),
        ));
  }
}

class ProdukSearch extends SearchDelegate<String> {
  var code2;
  final String id;
  ProdukSearch({Key key, this.id});
  void simpan() async {
    try {
      var storage = new DataStore();

      var tokenTypeStorage = await storage.getDataString('token_type');
      var accessTokenStorage = await storage.getDataString('access_token');

      tokenType = tokenTypeStorage;
      accessToken = accessTokenStorage;

      requestHeaders['Accept'] = 'application/json';
      requestHeaders['Authorization'] = '$tokenType $accessToken';
      print(requestHeaders);

      final simpanproduk = await http.post(
        url('api/add_produk'),
        headers: requestHeaders,
        body: {
          'produk': code2.toString(),
          'e_id': id.toString(),
          'android': 'true',
        },
      );

      if (simpanproduk.statusCode == 200) {
        var simpanprodukJson = json.decode(simpanproduk.body);
        if (simpanprodukJson['error'] != null) {
          showInSnackBarTE('Gagal! ' + simpanprodukJson['error']);
        } else if (simpanprodukJson['status'] == 'success') {
          // Navigator.popUntil(
          //   context,
          //   ModalRoute.withName('/penjualan_offline'),
          // );
          showInSnackBarTE('Berhasil! Mengubah Etalase Produk!');
        } else if (simpanprodukJson['status'] == 'gagal') {
          showInSnackBarTE('Gagal! Hubungi pengembang software!');
        }
      } else {
        showInSnackBarTE(
            'Request failed with status: ${simpanproduk.statusCode}');
        Map responseJson = jsonDecode(simpanproduk.body);

        if (responseJson.containsKey('message')) {
          showInSnackBarTE(responseJson['message']);
        }
        print(json.decode(simpanproduk.body));
      }
    } on TimeoutException catch (_) {
      showInSnackBarTE('Timed out, Try again');
    } catch (e) {
      showInSnackBarTE(e);
    }
  }

  void showInSnackBarTE(String value) {
    _scaffoldKeyTEP.currentState.showSnackBar(
      SnackBar(
        content: new Text(value),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Text('BuildResult');
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<DataProduk> filtered = dataProdukArray;
    filtered = dataProdukArray.where((i) {
      return i.namaproduk.toLowerCase().contains(query);
    }).toList();

    return Scrollbar(
      child: ListView.builder(
        itemCount: filtered.length,
        itemBuilder: (BuildContext context, int j) {
          return Card(
            child: CheckboxListTile(
              title: Text(filtered[j].namaproduk),
              value: filtered[j].check ? true : false,
              onChanged: (value) {
                print(id);
                filtered[j].check = value;
                code2 = filtered[j].code;
                simpan();
                Navigator.pop(context);
              },
            ),
          );
        },
      ),
    );
  }
}
