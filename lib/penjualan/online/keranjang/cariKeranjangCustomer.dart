import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:invee2/error/error.dart';
import 'package:invee2/localStorage/localStorage.dart';
import 'package:invee2/penjualan/online/keranjang/detail.dart';
import 'package:invee2/penjualan/online/keranjang/model.dart';
import 'package:invee2/routes/env.dart';
import 'dart:async';
import 'dart:convert';

GlobalKey<ScaffoldState> _scaffoldKeyCariKeranjangCustomer;

String accessToken, tokenType;
Map<String, String> requestHeaders = Map();

TextEditingController cariController;
FocusNode cariFocus;
bool isLoading, isError;

List<KeranjangModel> listKeranjang;
Timer timer;
int delayRequest;

showInSnackbarCariKeranjangCustomer(String content) {
  _scaffoldKeyCariKeranjangCustomer.currentState.showSnackBar(
    SnackBar(
      content: Text(content),
    ),
  );
}

class CariKeranjangCustomer extends StatefulWidget {
  @override
  _CariKeranjangCustomerState createState() => _CariKeranjangCustomerState();
}

class _CariKeranjangCustomerState extends State<CariKeranjangCustomer> {
  Future<List<KeranjangModel>> cariKeranjangCustomerAndroid() async {
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
        url('api/cariKeranjangCustomerAndroid'),
        headers: requestHeaders,
        body: {
          'cari': cariController.text,
        },
      );

      if (item.statusCode == 200) {
        // return nota;
        dynamic itemJson = json.decode(item.body);
        // print(itemJson);
        listKeranjang = [];
        for (var i in itemJson) {
          KeranjangModel notax = KeranjangModel(
            id: i['cm_id'].toString(),
            customer: i['cm_name'],
            createdAt: i['cm_create_at'],
            email: i['cm_email'],
            kodeCustomer: i['cm_code'],
            telpon: i['cm_nphone'],
          );
          listKeranjang.add(notax);
        }

        // print('listKeranjang $listKeranjang');
        // print('length listKeranjang ${listKeranjang.length}');
        setState(() {
          isLoading = false;
          isError = false;
        });
        return listKeranjang;
      } else if (item.statusCode == 401) {
        showInSnackbarCariKeranjangCustomer(
            'Token kedaluwarsa, silahkan login kembali');
      } else {
        showInSnackbarCariKeranjangCustomer('Error Code : ${item.statusCode}');
        print('Error Code : ${item.statusCode}');
        Map responseJson = jsonDecode(item.body);

        if (responseJson.containsKey('message')) {
          showInSnackbarCariKeranjangCustomer(responseJson['message']);
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

  timerUntukRequest() async {
    timer = Timer.periodic(
      Duration(
        seconds: 1,
      ),
      (Timer timerX) {
        if (delayRequest < 1) {
          cariKeranjangCustomerAndroid();
          timer.cancel();
        } else {
          delayRequest -= 1;
        }
      },
    );
  }

  @override
  void initState() {
    _scaffoldKeyCariKeranjangCustomer = GlobalKey<ScaffoldState>();
    cariController = TextEditingController();
    cariFocus = FocusNode();

    isError = false;
    isLoading = true;
    listKeranjang = List();

    delayRequest = 0;

    cariKeranjangCustomerAndroid();

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
        key: _scaffoldKeyCariKeranjangCustomer,
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
          title: Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: TextField(
              controller: cariController,
              focusNode: cariFocus,
              autofocus: true,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Cari Nama/Email/Kode/HP',
              ),
              onChanged: (ini) {
                cariController.value = TextEditingValue(
                  selection: cariController.selection,
                  text: ini,
                );

                if (delayRequest < 2 && delayRequest != 0) {
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
                    onPress: cariKeranjangCustomerAndroid,
                  )
                : RefreshIndicator(
                    onRefresh: cariKeranjangCustomerAndroid,
                    child: Scrollbar(
                      child: ListView.builder(
                        itemCount: listKeranjang.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                            child: ListTile(
                              leading: Icon(FontAwesomeIcons.userAlt),
                              title: Text(
                                '( ${listKeranjang[index].kodeCustomer} ) ${listKeranjang[index].customer}',
                              ),
                              subtitle: Text(listKeranjang[index].email),
                              trailing: Text(listKeranjang[index].telpon),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailKeranjang(
                                      id: listKeranjang[index].id,
                                      customer: listKeranjang[index].customer,
                                      email: listKeranjang[index].email,
                                      kodeCustomer:
                                          listKeranjang[index].kodeCustomer,
                                      telpon: listKeranjang[index].telpon,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
      ),
    );
  }
}
