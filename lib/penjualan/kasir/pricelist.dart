import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:invee2/localStorage/localStorage.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';
import 'package:intl/intl.dart';
import 'secondary/modal.dart';
import '../../routes/env.dart';
import '../../shimmer_loading.dart';

String tokenType, accessToken;
Map<String, String> requestHeaders = Map();
GlobalKey<ScaffoldState> _scaffoldpricelist = new GlobalKey<ScaffoldState>();
NumberFormat numberFormat;

class Pricelist extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Pricelist();
  }
}

class _Pricelist extends State<Pricelist> {
  void showInSnackBarM(String value) {
    _scaffoldpricelist.currentState.showSnackBar(
      SnackBar(
        content: new Text(value),
      ),
    );
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

  Future<List<PriceList>> priceList() async {
    var storage = new DataStore();

    var tokenTypeStorage = await storage.getDataString('token_type');
    var accessTokenStorage = await storage.getDataString('access_token');

    tokenType = tokenTypeStorage;
    accessToken = accessTokenStorage;

    requestHeaders['Accept'] = 'application/json';
    requestHeaders['Authorization'] = '$tokenType $accessToken';
    print(requestHeaders);

    try {
      final pricelist = await http.get(
        url('api/pricelistAndroid'),
        headers: requestHeaders,
      );
      if (pricelist.statusCode == 200) {
        var detailJson = jsonDecode(pricelist.body);

        // print('detailJson $detailJson');
        dataPriceList = [];
        for (var i in detailJson) {
          print(i.toString());
          PriceList detailx = PriceList(
            barang: i['i_name'],
            harga1: i['ipr_sunitprice'],
            harga2: i['ipr_sunitprice2'],
            harga3: i['ipr_sunitprice3'],
            satuan1: i['satuan1'],
            satuan2: i['satuan2'],
            satuan3: i['satuan3'],
          );
          dataPriceList.add(detailx);
        }
        print('listnota length ${dataPriceList.length}');

        return dataPriceList;
      } else {
        showInSnackBarM('Request failed with status: ${pricelist.statusCode}');
        Map responseJson = jsonDecode(pricelist.body);

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

  @override
  void initState() {
    numberFormat = NumberFormat.simpleCurrency(decimalDigits: 2, name: 'Rp. ');

    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldpricelist,
      body: Scrollbar(
        child: RefreshIndicator(
          onRefresh: () => refreshFunctions(),
          child: FutureBuilder(
            future: priceList(),
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
                        return Container(
                          decoration: BoxDecoration(
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: Colors.grey[300].withOpacity(0.3),
                                blurRadius: 1.0,
                                offset: Offset(1.0, 1.0),
                              ),
                            ],
                          ),
                          padding:
                              EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                          child: Card(
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              title: Text(snapshot.data[index].barang),
                              subtitle: Container(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  snapshot.data[index].satuan1 == null
                                      ? Text('No Set')
                                      : Text(snapshot.data[index].satuan1),
                                  snapshot.data[index].satuan2 == null
                                      ? Text('No Set')
                                      : Text(snapshot.data[index].satuan2),
                                  snapshot.data[index].satuan3 == null
                                      ? Text('No Set')
                                      : Text(snapshot.data[index].satuan3)
                                ],
                              )),
                              trailing: Container(
                                  height: 120,
                                  child: Column(
                                    children: <Widget>[
                                      snapshot.data[index].satuan1 == null
                                          ? Text('No Set')
                                          : Text(
                                              snapshot.data[index].harga1 ==
                                                      null
                                                  ? '0'
                                                  : numberFormat.format(
                                                      double.parse(snapshot
                                                          .data[index].harga1)),
                                            ),
                                      snapshot.data[index].satuan2 == null
                                          ? Text('No Set')
                                          : Text(
                                              snapshot.data[index].harga2 ==
                                                      null
                                                  ? '0'
                                                  : numberFormat.format(
                                                      double.parse(snapshot
                                                          .data[index].harga2)),
                                            ),
                                      snapshot.data[index].satuan3 == null
                                          ? Text('No Set')
                                          : Text(
                                              snapshot.data[index].harga3 ==
                                                      null
                                                  ? '0'
                                                  : numberFormat.format(
                                                      double.parse(snapshot
                                                          .data[index].harga3)),
                                            ),
                                    ],
                                  )),
                            ),
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
    );
  }
}
