import 'package:flutter/material.dart';
import 'package:invee2/localStorage/localStorage.dart';
import 'package:invee2/penjualan/kasir/tambah_produk.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import '../../shimmer_loading.dart';
import 'secondary/modal.dart';
import '../../routes/env.dart';
import 'package:http/http.dart' as http;

String tokenType, accessToken;
Map<String, String> requestHeaders = Map();
GlobalKey<ScaffoldState> _scaffoldKeyDC = new GlobalKey<ScaffoldState>();
bool isLoading;

class DetailCek extends StatefulWidget {
  final bool loading;
  final String code, nama;
  DetailCek({
    this.loading,
    this.code,
    this.nama,
  });
  @override
  State<StatefulWidget> createState() {
    return _DetailCek(
      code: code,
      nama: nama,
    );
  }
}

class _DetailCek extends State<DetailCek> {
  final String code, nama, codeproduk;
  _DetailCek({Key key, this.code, @required this.nama, this.codeproduk});

  void showInSnackBarM(String value) {
    _scaffoldKeyDC.currentState.showSnackBar(
      SnackBar(
        content: new Text(value),
      ),
    );
  }

  Future<List<DetailStock>> detailStocks() async {
    try {
      final stock = await http.post(
        url('api/detailProdukEtalaseAndroid'),
        body: {'etalase': code},
        headers: requestHeaders,
      );

      if (stock.statusCode == 200) {
        var detailJson = jsonDecode(stock.body);

        print('detailJson $detailJson');
        detailStockArray = [];
        for (var i in detailJson) {
          DetailStock detailx = DetailStock(
            nama: i['i_name'],
            satuan: i['iu_name'],
            codeproduk: i['i_id'].toString(),
            qty: i['st_qty'].toString(),
          );
          detailStockArray.add(detailx);
        }

        print('listnota $detailStockArray');
        print('listnota length ${detailStockArray.length}');

        return detailStockArray;
      } else {
        showInSnackBarM('Request failed with status: ${stock.statusCode}');
        Map responseJson = jsonDecode(stock.body);

        if (responseJson.containsKey('message')) {
          showInSnackBarM(responseJson['message']);
        }

        return null;
      }
    } on TimeoutException catch (_) {
      showInSnackBarM('Timed out, Try again');
    } on SocketException catch (_) {
      showInSnackBarM('Host not found');
    } catch (e) {}

    return null;
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
      appBar: AppBar(
        title: Text(nama.toString()),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: DetailProdukSearch());
            },
          ),
        ],
      ),
      body: Scrollbar(
        child: RefreshIndicator(
          onRefresh: () => refreshFunctions(),
          child: FutureBuilder(
            future: detailStocks(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return ListTile(
                    title: Text('Tekan Tombol Mulai'),
                  );
                case ConnectionState.active:
                case ConnectionState.waiting:
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
                        return ListTile(
                          title: Text(snapshot.data[index].nama),
                          subtitle: Text(snapshot.data[index].satuan),
                          trailing: Text(snapshot.data[index].qty == null
                              ? 0
                              : snapshot.data[index].qty),
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
              builder: (context) => TambahProdukEtalase(
                nama: nama,
                code: codeproduk,
                etalase: code,
              ),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class DetailProdukSearch extends SearchDelegate<String> {
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
    List<DetailStock> filtered = detailStockArray;
    filtered = detailStockArray.where((i) {
      return i.nama.toLowerCase().contains(query);
    }).toList();

    return Scrollbar(
      child: ListView.builder(
        itemCount: filtered.length,
        itemBuilder: (BuildContext context, int j) {
          return ListTile(
            title: Text(filtered[j].nama),
            subtitle: Text(filtered[j].satuan),
            trailing: Text(filtered[j].qty),
          );
        },
      ),
    );
  }
}
