import 'package:flutter/material.dart';
import 'package:invee2/localStorage/localStorage.dart';
import 'package:invee2/penjualan/kasir/detail_cekstock.dart';
import 'package:invee2/penjualan/kasir/tambah_etalase.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import '../../shimmer_loading.dart';
import 'edit_etalase.dart';
import 'secondary/modal.dart';
import '../../routes/env.dart';
import 'package:http/http.dart' as http;

String tokenType, accessToken;
Map<String, String> requestHeaders = Map();
GlobalKey<ScaffoldState> _scaffoldKeyC = new GlobalKey<ScaffoldState>();
bool isLoading;

class TabCekStok extends StatefulWidget {
  final bool loading;
  TabCekStok({this.loading});
  @override
  State<StatefulWidget> createState() {
    return _TabCekStokState();
  }
}

class _TabCekStokState extends State<TabCekStok> {
  TextEditingController searchInput = TextEditingController();

  popup() {
    return AlertDialog(
      title: Text('aksi'),
      actions: <Widget>[
        RaisedButton(
          // color: Colors.red,
          textColor: Colors.black,
          onPressed: () {},
          child: Text('Detail'),
        ),
        RaisedButton(
          // color: Colors.red,
          textColor: Colors.black,
          onPressed: () {},
          child: Text('Edit'),
        ),
      ],
    );
  }

  void showInSnackBarM(String value) {
    _scaffoldKeyC.currentState.showSnackBar(
      SnackBar(
        content: new Text(value),
      ),
    );
  }

  Future<List<Liststock>> liststock() async {
    var storage = new DataStore();

    var tokenTypeStorage = await storage.getDataString('token_type');
    var accessTokenStorage = await storage.getDataString('access_token');

    tokenType = tokenTypeStorage;
    accessToken = accessTokenStorage;

    requestHeaders['Accept'] = 'application/json';
    requestHeaders['Authorization'] = '$tokenType $accessToken';
    print(requestHeaders);

    try {
      final stock = await http.get(
        url('api/listEtalaseAndroid'),
        headers: requestHeaders,
      );

      if (stock.statusCode == 200) {
        var stockJson = jsonDecode(stock.body);

        // if (stockJson['error'] == 'Unauthenticated') {
        //   showInSnackBarM(
        //       'Token kedaluwarsa, silahkan logout dan login kembali');
        // }

        print('stockJson $stockJson');
        listStockArray = [];
        for (var i in stockJson) {
          Liststock stockx = Liststock(
            nama: i['e_name'],
            code: i['e_id'].toString(),
            // qty: i['e_qty'].toString(),
          );
          listStockArray.add(stockx);
        }

        print('listnota $listStockArray');
        print('listnota length ${listStockArray.length}');

        return listStockArray;
      } else if (stock.statusCode == 401) {
        showInSnackBarM('Token kedaluwarsa, silahkan logout dan login kembali');
      } else {
        showInSnackBarM('Request failed with status: ${stock.statusCode}');
        Map responseJson = jsonDecode(stock.body);

        if (responseJson.containsKey('message')) {
          showInSnackBarM(responseJson['message']);
        }
        print(jsonDecode(stock.body));

        return null;
      }
    } on TimeoutException catch (_) {
      showInSnackBarM('Timed out, Try again');
    } on SocketException catch (_) {
      showInSnackBarM('Host not found');
    } catch (e) {}

    return null;
  }

  @override
  void initState() {
    isLoading = widget.loading;

    super.initState();
  }

  void dispose() {
    super.dispose();
  }

  int totalRefresh = 0;
  refreshFunctions() async {
    setState(() {
      totalRefresh += 1;
    });
    await Future.delayed(
      Duration(
        milliseconds: 100,
      ),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKeyC,
      body: RefreshIndicator(
        onRefresh: () => refreshFunctions(),
        child: Scrollbar(
          child: FutureBuilder(
            future: liststock(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return ListTile(
                    title: Text('Tekan Tombol Mulai'),
                  );
                case ConnectionState.waiting:
                case ConnectionState.active:
                  return ShimmerLoadingList();
                case ConnectionState.done:
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.data == null ||
                      snapshot.data == 0 ||
                      snapshot.data.length == null ||
                      snapshot.data.length == 0) {
                    return ListView(
                      children: <Widget>[
                        ListTile(
                          title: Text(
                            'Tidak Ada Data',
                            textAlign: TextAlign.center,
                          ),
                        )
                      ],
                    );
                  } else if (snapshot.data != null || snapshot.data != 0) {
                    return ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                          child: ListTile(
                            title: Text(snapshot.data[index].nama),
                            // subtitle: Text(snapshot.data[index].satuan),
                            // trailing: Text(
                            //   snapshot.data[index].qty,
                            //   style: TextStyle(color: Colors.black54),
                            // ),
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('aksi'),
                                      actions: <Widget>[
                                        RaisedButton(
                                          // color: Colors.red,
                                          textColor: Colors.white,
                                          onPressed: () {
                                            Navigator.pop(context);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => DetailCek(
                                                  code:
                                                      snapshot.data[index].code,
                                                  nama:
                                                      snapshot.data[index].nama,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Text('Detail'),
                                        ),
                                        RaisedButton(
                                          // color: Colors.red,
                                          textColor: Colors.white,
                                          onPressed: () {
                                            Navigator.pop(context);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    EditEtalase(
                                                  etalase:
                                                      snapshot.data[index].code,
                                                  nama:
                                                      snapshot.data[index].nama,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Text('Edit'),
                                        ),
                                      ],
                                    );
                                  });
                            },
                          ),
                        );
                      },
                    );
                  }
              }
              return null;
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TambahEtalase(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class EtalaseSearch extends SearchDelegate<String> {
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
    List<Liststock> filtered = listStockArray;
    filtered = listStockArray.where((i) {
      return i.nama.toLowerCase().contains(query);
    }).toList();

    return Scrollbar(
      child: ListView.builder(
        itemCount: filtered.length,
        itemBuilder: (BuildContext context, int j) {
          return Card(
            child: ListTile(
              title: Text(filtered[j].nama),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailCek(
                      code: filtered[j].code,
                      nama: filtered[j].nama,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
