import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:invee2/penjualan/online/wishlist/modelWishlist.dart';
import 'package:invee2/routes/env.dart';
import 'dart:async';
import 'dart:convert';
import 'package:invee2/localStorage/localStorage.dart';

var idX, wishlistX, customerX;
String accessToken, tokenType;
Map<String, String> requestHeaders = Map();
List<ProdukWishList> listItem;
bool isLoading;

GlobalKey<ScaffoldState> _scaffoldKey;

showInSnackbarDetailWishlist(String content) {
  _scaffoldKey.currentState.showSnackBar(
    SnackBar(
      content: Text(content),
    ),
  );
}

class DetailWishlist extends StatefulWidget {
  final String id, email, noHp, kodeCustomer, customer;
  DetailWishlist({
    Key key,
    @required this.id,
    @required this.customer,
    @required this.email,
    @required this.kodeCustomer,
    @required this.noHp,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _DetailWishlistState();
  }
}

class _DetailWishlistState extends State<DetailWishlist> {
  Future<List<ProdukWishList>> listItemNotaAndroid() async {
    var storage = new DataStore();

    var tokenTypeStorage = await storage.getDataString('token_type');
    var accessTokenStorage = await storage.getDataString('access_token');

    tokenType = tokenTypeStorage;
    accessToken = accessTokenStorage;

    requestHeaders['Accept'] = 'application/json';
    requestHeaders['Authorization'] = '$tokenType $accessToken';
    // print(requestHeaders);

    setState(() {
      isLoading = true;
    });
    try {
      final item = await http.post(
        url('api/detaillistWishlistAndroid'),
        headers: requestHeaders,
        body: {
          'member': widget.id,
        },
      );

      if (item.statusCode == 200) {
        // return nota;
        var itemJson = json.decode(item.body);
        // print(itemJson);
        listItem = [];
        for (var i in itemJson) {
          ProdukWishList notax = ProdukWishList(
            nama: i['i_name'],
            code: i['i_code'],
          );
          listItem.add(notax);
        }

        // print('listItem $listItem');
        // print('length listItem ${listItem.length}');
        setState(() {
          isLoading = false;
        });
        return listItem;
      } else if (item.statusCode == 401) {
        showInSnackbarDetailWishlist(
            'Token kedaluwarsa, silahkan login kembali');
      } else {
        showInSnackbarDetailWishlist('Error Code : ${item.statusCode}');
        print('Error Code : ${item.statusCode}');
        Map responseJson = jsonDecode(item.body);

        if (responseJson.containsKey('message')) {
          showInSnackbarDetailWishlist(responseJson['message']);
        }
        setState(() {
          isLoading = false;
        });
      }
    } on TimeoutException catch (_) {
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
    setState(() {
      isLoading = false;
    });
    return null;
  }

  @override
  void initState() {
    _scaffoldKey = new GlobalKey<ScaffoldState>();
    listItem = [];
    isLoading = false;

    listItemNotaAndroid();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text("Detail Wishlist ${widget.customer}"),
      ),
      body: Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  blurRadius: 3.0,
                  offset: Offset(4.0, 0.0),
                  color: Colors.grey,
                )
              ],
            ),
            padding: EdgeInsets.all(15.0),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 4,
                      child: Text(
                        'Kode Customer',
                        style: TextStyle(
                          fontSize: 16.0,
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
                        'Customer',
                        style: TextStyle(
                          fontSize: 16.0,
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
                        'Email',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Text(
                        widget.email == null ? '-' : widget.email,
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
                        'No Handphone',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Text(
                        widget.noHp == null ? '-' : widget.noHp,
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
              ? Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : listItem.length == 0
                  ? Expanded(
                      child: RefreshIndicator(
                        onRefresh: listItemNotaAndroid,
                        child: ListView(
                          children: <Widget>[
                            Card(
                              child: ListTile(
                                title: Text(
                                  'Tidak ada data',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Expanded(
                      child: Scrollbar(
                        child: RefreshIndicator(
                          onRefresh: listItemNotaAndroid,
                          child: ListView.builder(
                            // scrollDirection: Axis.horizontal,
                            itemCount: listItem.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Card(
                                child: ListTile(
                                  title: Text(listItem[index].nama),
                                  subtitle: Text(listItem[index].code),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
        ],
      ),
    );
  }
}
