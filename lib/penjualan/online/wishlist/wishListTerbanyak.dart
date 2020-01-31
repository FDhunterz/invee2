import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:invee2/error/error.dart';
import 'package:invee2/localStorage/localStorage.dart';
import 'package:invee2/penjualan/online/wishlist/modelWishlist.dart';
import 'dart:async';
import 'dart:convert';
import 'package:invee2/routes/env.dart';
import 'dart:math';

String tokenType, accessToken;
Map<String, String> requestHeaders = Map();
GlobalKey<ScaffoldState> _scaffoldKeyWishlistTerbanyak;

bool isLoading, isError;
List<ProdukWishList> listWishlistTerbanyak;

showInSnackbarWishlistTerbanyak(String content) {
  _scaffoldKeyWishlistTerbanyak.currentState.showSnackBar(
    SnackBar(
      content: Text(content),
    ),
  );
}

class WishListTerbanyak extends StatefulWidget {
  @override
  _WishListTerbanyakState createState() => _WishListTerbanyakState();
}

class _WishListTerbanyakState extends State<WishListTerbanyak> {
  Future<Null> getWishlistTerbanyak() async {
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
      final response = await http.get(
        url('api/wishlistTerbanyak'),
        headers: requestHeaders,
      );

      if (response.statusCode == 200) {
        dynamic responseJson = jsonDecode(response.body);

        listWishlistTerbanyak = List<ProdukWishList>();

        for (var i in responseJson) {
          ProdukWishList wishlistLoop = ProdukWishList(
            code: i['i_code'],
            nama: i['i_name'],
            count: i['count'].toString(),
          );
          listWishlistTerbanyak.add(wishlistLoop);
        }
        setState(() {
          isLoading = false;
          isError = false;
        });
      } else if (response.statusCode == 401) {
        showInSnackbarWishlistTerbanyak(
            'Token kedaluwarsa, silahkan login kembali');

        setState(() {
          isLoading = false;
          isError = true;
        });
      } else {
        showInSnackbarWishlistTerbanyak('Error Code : ${response.statusCode}');
        Map responseJson = jsonDecode(response.body);

        if(responseJson.containsKey('message')){
          showInSnackbarWishlistTerbanyak(responseJson['message']);
        }
        print(jsonDecode(response.body));
        setState(() {
          isLoading = false;
          isError = true;
        });
      }
    } catch (e) {
      showInSnackbarWishlistTerbanyak('Error : ${e.toString()}');
      print('Error : $e');
      setState(() {
        isLoading = false;
        isError = true;
      });
    }
  }

  Color colorCondition(int index) {
    if (index == 0) {
      return Colors.red;
    } else if (index == 1) {
      return Colors.blue;
    } else if (index == 2) {
      return Colors.orange;
    } else {
      return Colors.primaries[Random().nextInt(Colors.primaries.length)];
      // List<Color> list = [
      //   Colors.green,
      //   Colors.brown,
      //   Colors.purple,
      //   Colors.cyan,
      //   Colors.teal,
      //   Colors.grey,
      //   Colors.black,
      //   Colors.indigo,
      //   Colors.lime,
      //   Colors.blueGrey,
      // ];

      // // generates a new Random object
      // final _random = new Random();

      // // generate a random index based on the list length
      // // and use it to retrieve the element
      // Color element = list[_random.nextInt(list.length)];

      // return element;
    }
  }

  @override
  void initState() {
    _scaffoldKeyWishlistTerbanyak = new GlobalKey<ScaffoldState>();

    getWishlistTerbanyak();

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
    return Scaffold(
      key: _scaffoldKeyWishlistTerbanyak,
      appBar: AppBar(
        title: Text('Wishlist Terbanyak'),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : isError
              ? ErrorCobalLagi(
                  onPress: getWishlistTerbanyak,
                )
              : RefreshIndicator(
                  onRefresh: getWishlistTerbanyak,
                  child: ListView.builder(
                      itemCount: listWishlistTerbanyak.length,
                      itemBuilder: (BuildContext context, int i) {
                        return Container(
                          height: 200,
                          margin: EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            color: colorCondition(i),
                            borderRadius: BorderRadius.circular(5.0),
                            border: Border.all(
                              width: 0.5,
                              color: Colors.grey,
                            ),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                blurRadius: 3.0,
                                color: Colors.grey[400],
                                offset: Offset(0.0, 2.0),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: <Widget>[
                              Positioned(
                                top: 10.0,
                                right: 10.0,
                                child: Icon(
                                  FontAwesomeIcons.solidHeart,
                                  color: i < 1 ? Colors.white : i < 3 ? Colors.pink : Colors.white,
                                  size: i < 1
                                      ? 60.0
                                      : i < 2 ? 50.0 : i < 3 ? 40 : 30,
                                ),
                              ),
                              Positioned(
                                top: 0.0,
                                bottom: 0.0,
                                left: 0.0,
                                right: 0.0,
                                child: Center(
                                    child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Container(
                                      // color: Colors.black,
                                      child: Text(
                                        listWishlistTerbanyak[i].nama,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20.0,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      // color: Colors.black,
                                      child: Text(
                                        listWishlistTerbanyak[i].count,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 24.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                )),
                              ),
                            ],
                          ),
                        );
                      }),
                ),
    );
  }
}
