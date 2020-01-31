import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:invee2/error/error.dart';
import 'package:invee2/gudang/layanan_penjualan/penjualan_offline/penjualan_offline.dart';
import 'package:invee2/penjualan/online/keranjang/model.dart';
import 'package:invee2/routes/env.dart';
import 'dart:async';
import 'dart:convert';
import 'package:invee2/localStorage/localStorage.dart';

String accessToken, tokenType;
Map<String, String> requestHeaders = Map();
List<ListKeranjangModel> listItem;
bool isLoading, isError;

class DetailKeranjang extends StatefulWidget {
  final String id, customer, email, telpon, kodeCustomer;
  DetailKeranjang({
    Key key,
    @required this.id,
    @required this.customer,
    @required this.telpon,
    @required this.kodeCustomer,
    @required this.email,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _DetailKeranjangState();
  }
}

class _DetailKeranjangState extends State<DetailKeranjang> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Future<List<ListKeranjangModel>> listItemNotaAndroid() async {
    setState(() {
      isLoading = true;
      isError = false;
    });

    DataStore storage = new DataStore();

    String tokenTypeStorage = await storage.getDataString('token_type');
    String accessTokenStorage = await storage.getDataString('access_token');

    tokenType = tokenTypeStorage;
    accessToken = accessTokenStorage;

    requestHeaders['Accept'] = 'application/json';
    requestHeaders['Authorization'] = '$tokenType $accessToken';
    try {
      final item = await http.post(
        url('api/detaillistkeranjangAndroid'),
        headers: requestHeaders,
        body: {
          'member': widget.id,
        },
      );

      if (item.statusCode == 200) {
        // return nota;
        dynamic itemJson = json.decode(item.body);
        print(itemJson);
        listItem = [];
        for (var i in itemJson) {
          ListKeranjangModel notax = ListKeranjangModel(
            nama: i['i_name'],
            code: i['i_code'],
            qty: i['cart_qty'].toString(),
            satuan: i['satuan'],
          );
          listItem.add(notax);
        }

        print('listItem $listItem');
        print('length listItem ${listItem.length}');
        setState(() {
          isLoading = false;
          isError = false;
        });
        return listItem;
      } else {
        showInSnackBar('Error Code : ${item.statusCode}');
        print('Error Code : ${item.statusCode}');

        Map responseJson = jsonDecode(item.body);

        if(responseJson.containsKey('message')){
          showInSnackBar(responseJson['message']);
        }
        setState(() {
          isLoading = false;
          isError = true;
        });
      }
    } on TimeoutException catch (_) {
      setState(() {
        isLoading = false;
        isError = true;
      });
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
        isError = true;
      });
    }
    setState(() {
      isLoading = false;
      isError = true;
    });
    return null;
  }

  @override
  void initState() {
    listItem = [];
    isLoading = false;
    isError = false;
    listItemNotaAndroid();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text("Detail Keranjang ${widget.customer}"),
      ),
      body: RefreshIndicator(
        onRefresh: listItemNotaAndroid,
        child: Scrollbar(
          child: ListView(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(15.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              flex: 4,
                              child: Text(
                                'Kode Customer',
                                style: TextStyle(
                                  // fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: Text(
                                widget.kodeCustomer,
                                style: TextStyle(
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Divider(),
                        Row(
                          children: <Widget>[
                            Expanded(
                              flex: 4,
                              child: Text(
                                'Nama Customer',
                                style: TextStyle(
                                  // fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: Text(
                                widget.customer,
                                style: TextStyle(
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Divider(),
                        Row(
                          children: <Widget>[
                            Expanded(
                              flex: 4,
                              child: Text(
                                'Email Customer',
                                style: TextStyle(
                                  // fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: Text(
                                widget.email != null
                                    ? widget.email
                                    : 'Tidak ada',
                                style: TextStyle(
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Divider(),
                        Row(
                          children: <Widget>[
                            Expanded(
                              flex: 4,
                              child: Text(
                                'No.HP Customer',
                                style: TextStyle(
                                  // fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: Text(
                                widget.telpon != null
                                    ? widget.telpon
                                    : 'Tidak ada',
                                style: TextStyle(
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  isLoading == true
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : isError
                          ? ErrorCobalLagi(
                              onPress: listItemNotaAndroid,
                            )
                          : listItem.length == 0
                              ? Card(
                                  child: ListTile(
                                    title: Text(
                                      'Tidak ada data',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                )
                              : Column(
                                  children: listItem
                                      .map(
                                        (ListKeranjangModel f) => Card(
                                          child: ListTile(
                                            title: Text(f.nama),
                                            subtitle: Text(
                                                '${f.qty.toString()} ( ${f.satuan} )'),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
