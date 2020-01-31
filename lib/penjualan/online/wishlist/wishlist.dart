import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:invee2/penjualan/online/wishlist/cariWishlist.dart';
import 'package:invee2/penjualan/online/wishlist/modelWishlist.dart';
import 'package:invee2/penjualan/online/wishlist/wishListTerbanyak.dart';
import 'package:invee2/shimmer_loading.dart';
import 'package:invee2/localStorage/localStorage.dart';
import 'package:http/http.dart' as http;
import 'package:invee2/routes/env.dart';
import 'dart:async';
import 'dart:convert';
import './detail.dart';

GlobalKey<ScaffoldState> _scaffoldKeyX;
List<WishListModel> listNota = [];
String tokenType, accessToken;
Map<String, String> requestHeaders = Map();

void showInSnackBar(String value) {
  _scaffoldKeyX.currentState
      .showSnackBar(new SnackBar(content: new Text(value)));
}

Future<List<WishListModel>> listWishlist() async {
  DataStore storage = new DataStore();

  String tokenTypeStorage = await storage.getDataString('token_type');
  String accessTokenStorage = await storage.getDataString('access_token');

  tokenType = tokenTypeStorage;
  accessToken = accessTokenStorage;

  requestHeaders['Accept'] = 'application/json';
  requestHeaders['Authorization'] = '$tokenType $accessToken';
  // print(requestHeaders);

  try {
    final nota = await http.get(
      url('api/listWishlistAndroid'),
      headers: requestHeaders,
    );

    if (nota.statusCode == 200) {
      // return nota;
      dynamic notaJson = json.decode(nota.body);

      // print('notaJson $notaJson');

      listNota = [];
      for (var i in notaJson) {
        WishListModel notax = WishListModel(
          id: i['cm_id'].toString(),
          customer: i['cm_name'],
          email: i['cm_email'],
          kodeCustomer: i['cm_code'],
          noHP: i['cm_nphone'],
        );
        listNota.add(notax);
      }

      // print('listnota $listNota');
      // print('listnota length ${listNota.length}');
      return listNota;
    } else {
      showInSnackBar('Request failed with status: ${nota.statusCode}');
      print('Error Code : ${nota.statusCode}');
      Map responseJson = jsonDecode(nota.body);

      if (responseJson.containsKey('message')) {
        showInSnackBar(responseJson['message']);
      }
      print(jsonDecode(nota.body));
      return null;
    }
  } on TimeoutException catch (_) {
    showInSnackBar('Timed out, Try again');
  } catch (e) {
    showInSnackBar('Error : ${e.toString()}');
    print('Error : $e');
  }
  return null;
}

class Wishlist extends StatefulWidget {
  Wishlist({Key key, this.title}) : super(key: key);
  final String title;
  @override
  State<StatefulWidget> createState() {
    return _WishlistState();
  }
}

class _WishlistState extends State<Wishlist> {
  int totalRefresh = 0;
  refreshFunction() async {
    setState(() {
      totalRefresh += 1;
    });
  }

  @override
  void initState() {
    _scaffoldKeyX = new GlobalKey<ScaffoldState>();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKeyX,
      appBar: AppBar(
        title: Text('Data Wishlist Customer'),
        actions: <Widget>[
          IconButton(
            icon: Icon(FontAwesomeIcons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  settings: RouteSettings(name: '/cari_wishlist'),
                  builder: (BuildContext context) => CariWishList(),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Text(
          'Wishlist Terbanyak',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        color: Colors.red,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => WishListTerbanyak(),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: RefreshIndicator(
        onRefresh: () => refreshFunction(),
        child: Scrollbar(
          child: FutureBuilder(
            future: listWishlist(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return ListTile(
                    title: Text('Tekan Tombol Mulai.'),
                  );
                case ConnectionState.active:
                case ConnectionState.waiting:
                  // return Center(
                  //   child: CircularProgressIndicator(),
                  // );
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
                            'Tidak ada data',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    );
                  } else if (snapshot.data != null || snapshot.data != 0) {
                    return ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                          child: ListTile(
                            leading: Icon(FontAwesomeIcons.userAlt),
                            title: Text(
                                '( ${snapshot.data[index].kodeCustomer} ) ${snapshot.data[index].customer}'),
                            subtitle: Text(snapshot.data[index].email != null
                                ? snapshot.data[index].email
                                : '-'),
                            trailing: Text(snapshot.data[index].noHP != null
                                ? snapshot.data[index].noHP
                                : '-'),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailWishlist(
                                    id: snapshot.data[index].id,
                                    customer: snapshot.data[index].customer,
                                    email: snapshot.data[index].email,
                                    kodeCustomer:
                                        snapshot.data[index].kodeCustomer,
                                    noHp: snapshot.data[index].noHP,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  }
              }
              return null; // unreachable
            },
          ),
        ),
      ),
    );
  }
}
