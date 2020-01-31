import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:invee2/localStorage/localStorage.dart';
import 'package:invee2/penjualan/kasir/environment/cari_customer.dart';
import 'package:invee2/routes/env.dart';
import 'model.dart';
import 'package:flutter/rendering.dart';
import 'package:invee2/penjualan/kasir/environment/model.dart';
// import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';

String tokenType, accessToken;
Map<String, String> requestHeaders = Map();
Map<String, dynamic> _formSerialize = Map();

TextEditingController _memberInput;

bool isLoading;

int tabControllerIndex = 0;

GlobalKey<ScaffoldState> _scaffoldKey;

// GlobalKey<FormState> _form;

// FocusNode _memberInputFokus;
Customer selectedCustomer;

void showInSnackBarO(String value, {SnackBarAction action}) {
  _scaffoldKey.currentState.showSnackBar(new SnackBar(
    content: new Text(value),
    action: action,
  ));
}

class CreateAntrian extends StatefulWidget {
  CreateAntrian({
    Key key,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _CreateAntrianState();
  }
}

class _CreateAntrianState extends State<CreateAntrian>
    with TickerProviderStateMixin {
  Future<Null> getHeaderHTTP() async {
    var storage = new DataStore();

    var tokenTypeStorage = await storage.getDataString('token_type');
    var accessTokenStorage = await storage.getDataString('access_token');

    tokenType = tokenTypeStorage;
    accessToken = accessTokenStorage;

    requestHeaders['Accept'] = 'application/json';
    requestHeaders['Authorization'] = '$tokenType $accessToken';
    print(requestHeaders);
  }

  TabController _tabController;
  void currentTabIndex() {
    setState(() {
      tabControllerIndex = _tabController.index;
    });
  }

  @override
  void initState() {
    isLoading = false;
    selectedCustomer = null;
    // _form = GlobalKey<FormState>();

    tabControllerIndex = 0;
    getHeaderHTTP();

    _scaffoldKey = new GlobalKey<ScaffoldState>();

    _memberInput = TextEditingController();

    // _memberInputFokus = FocusNode();

    _tabController = new TabController(vsync: this, length: 2);
    _tabController.addListener(currentTabIndex);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading == false) {
      return Container(
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.grey[300],
          appBar: AppBar(
            title: Text('Tambah Antrian'),
          ),
          body: Padding(
            padding: EdgeInsets.all(3.0),
            child: Column(
              children: <Widget>[
                SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 100.0),
                  child: Column(
                    children: <Widget>[
                      Card(
                        child: ListTile(
                          title: Text(selectedCustomer != null
                              ? selectedCustomer.namaCustomer
                              : 'Pilih Customer'),
                          trailing: selectedCustomer != null
                              ? selectedCustomer.noTelp == 'null'
                                  ? Text('-')
                                  : Text(selectedCustomer.noTelp)
                              : null,
                          subtitle: selectedCustomer != null
                              ? selectedCustomer.email == 'null'
                                  ? Text('-')
                                  : Text(selectedCustomer.email)
                              : null,
                          onTap: () async {
                            Customer customerX = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) => CariCustomer(
                                  customer: selectedCustomer,
                                ),
                              ),
                            );

                            if (customerX != null) {
                              setState(() {
                                selectedCustomer = customerX;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.check),
            onPressed: () {
              _tabController.animateTo(0);
              if (selectedCustomer != null) {
                print('validate true');

                _formSerialize = Map<String, dynamic>();

                _formSerialize['member'] = selectedCustomer.kodeCustomer;

                print("serialized ${jsonEncode(FormSerialize(
                  member: _memberInput.text,
                ).toJson())}");
                print("formSerialize $_formSerialize");
                showInSnackBarO('Memproses data');

                saveData(context);
              } else {
                showInSnackBarO('Customer tidak boleh kosong');
              }
            },
          ),
        ),
      );
    } else {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }
}

void saveData(BuildContext context) async {
  try {
    Dio dio = new Dio();

    final response = await dio.post(
      url('api/addListAntrianAndroid'),
      options: Options(
        headers: requestHeaders,
      ),
      data: FormData.fromMap(_formSerialize),
    );

    print(_formSerialize);
    print("decoded ${response.data}");
    if (response.statusCode == 200) {
      var responseJson = response.data;
      print(responseJson);

      if (responseJson['status'] == 'Success') {
        showInSnackBarO('Antrian Layanan Berhasil Dibuat');
        Navigator.popUntil(context, ModalRoute.withName('/antrian'));
      } else {
        showInSnackBarO(
            'Antrian Layanan gagal dibuat, hubungi pengembang software');
        Navigator.pop(context);
      }
    } else {
      print('Error code : ${response.statusCode}');
      showInSnackBarO('Error Code : ${response.statusCode}');
    }
  } catch (e, stacktrace) {
    print("Error: $e, Stacktrace : $stacktrace");
  }
}
