import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:invee2/error/error.dart';
import 'package:invee2/localStorage/localStorage.dart';
import 'package:invee2/penjualan/online/wishlist/detail.dart';
import 'package:invee2/penjualan/online/wishlist/modelWishlist.dart';
import 'dart:convert';
import 'package:invee2/routes/env.dart';

GlobalKey<ScaffoldState> _scaffoldKeyCariWishlist;
TextEditingController cariController;
FocusNode cariFocus;

bool isLoading, isError;
String tokenType, accessToken;
Map<String, String> requestHeaders = Map();

List<WishListModel> listWishlist = List<WishListModel>();
Timer timer;
int delayRequest;

showInSnackbar(String content) {
  _scaffoldKeyCariWishlist.currentState.showSnackBar(
    SnackBar(
      content: Text(content),
    ),
  );
}

class CariWishList extends StatefulWidget {
  @override
  _CariWishListState createState() => _CariWishListState();
}

class _CariWishListState extends State<CariWishList> {
  Future<Null> cariWishlist() async {
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
      final response = await http.post(
        url('api/cariCustomerWishlistAndroid'),
        headers: requestHeaders,
        body: {
          'cari': cariController.text,
        },
      );

      if (response.statusCode == 200) {
        dynamic responseJson = jsonDecode(response.body);

        listWishlist = List<WishListModel>();

        for (var i in responseJson) {
          WishListModel wishlistLoop = WishListModel(
            id: i['cm_id'].toString(),
            customer: i['cm_name'],
            email: i['cm_email'],
            kodeCustomer: i['cm_code'],
            noHP: i['cm_nphone'],
          );
          listWishlist.add(wishlistLoop);
        }
        setState(() {
          isLoading = false;
          isError = false;
        });
      } else if (response.statusCode == 401) {
        showInSnackbar('Token kedaluwarsa, silahkan login kembali');

        setState(() {
          isLoading = false;
          isError = true;
        });
      } else {
        showInSnackbar('Error Code : ${response.statusCode}');
        Map responseJson = jsonDecode(response.body);

        if (responseJson.containsKey('message')) {
          showInSnackbar(responseJson['message']);
        }
        print(jsonDecode(response.body));
        setState(() {
          isLoading = false;
          isError = true;
        });
      }
    } catch (e) {
      showInSnackbar('Error : ${e.toString()}');
      print('Error : $e');
      setState(() {
        isLoading = false;
        isError = true;
      });
    }
  }

  timerUntukRequest() async {
    timer = Timer.periodic(
      Duration(
        seconds: 1,
      ),
      (Timer timerX) {
        if (delayRequest < 1) {
          cariWishlist();
          timer.cancel();
        } else {
          delayRequest -= 1;
        }
      },
    );
  }

  @override
  void initState() {
    isLoading = true;
    isError = false;
    _scaffoldKeyCariWishlist = GlobalKey<ScaffoldState>();
    cariController = TextEditingController();
    cariFocus = FocusNode();
    delayRequest = 0;

    cariWishlist();
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
      key: _scaffoldKeyCariWishlist,
      appBar: AppBar(
        backgroundColor: Colors.white,
        textTheme: TextTheme(
          title: TextStyle(
            color: Colors.black,
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        title: Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: TextField(
            autofocus: true,
            focusNode: cariFocus,
            controller: cariController,
            decoration: InputDecoration(
                border: InputBorder.none, hintText: 'Cari Nama/Email/Kode/HP'),
            onChanged: (ini) {
              cariController.value = TextEditingValue(
                selection: cariController.selection,
                text: ini,
              );
              if (delayRequest <= 2 && delayRequest != 0) {
                timer.cancel();
              }
              delayRequest = 2;
              timerUntukRequest();
            },
          ),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : isError
              ? ErrorCobalLagi(
                  onPress: cariWishlist,
                )
              : ListView.builder(
                  itemCount: listWishlist.length,
                  itemBuilder: (BuildContext context, int i) => Card(
                    child: ListTile(
                      leading: Icon(FontAwesomeIcons.userAlt),
                      title: Text(
                          '( ${listWishlist[i].kodeCustomer} ) ${listWishlist[i].customer}'),
                      subtitle: Text(listWishlist[i].email != null
                          ? listWishlist[i].email
                          : '-'),
                      trailing: Text(listWishlist[i].noHP != null
                          ? listWishlist[i].noHP
                          : '-'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailWishlist(
                              id: listWishlist[i].id,
                              customer: listWishlist[i].customer,
                              email: listWishlist[i].email,
                              kodeCustomer: listWishlist[i].kodeCustomer,
                              noHp: listWishlist[i].noHP,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
    );
  }
}
