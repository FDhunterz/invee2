// import 'dart:io';

import 'package:flutter/material.dart';
import 'package:invee2/_sidebar.dart';
import 'package:invee2/error/error.dart';
import 'package:invee2/localStorage/localStorage.dart';
import 'package:http/http.dart' as http;
import 'package:invee2/notification/notification_service.dart';
import 'package:invee2/pusher/pusher_service.dart';
import 'dart:async';
import 'dart:convert';
import 'package:invee2/routes/env.dart';

final controller = PageController(
  initialPage: 1,
);
Map<String, String> requestHeaders = Map();
var tokenType, accessToken;
NotificationService notificationService;
bool _isLoading, _isError;
String customerSudahBayar,
    customerSudahBayarOff,
    prosesPacking,
    prosesPackingOff,
    requestMutasi,
    penerimaanBarang,
    circleTime,
    opnameStok;

String errorMessage;

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldKeyX = new GlobalKey<ScaffoldState>();

  void showInSnackBar(String value) {
    _scaffoldKeyX.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  Future<Null> getHeaderHTTP() async {
    var storage = new DataStore();

    var tokenTypeStorage = await storage.getDataString('token_type');
    var accessTokenStorage = await storage.getDataString('access_token');

    // setState(() {
    tokenType = tokenTypeStorage;
    accessToken = accessTokenStorage;
    requestHeaders['Accept'] = 'application/json';
    requestHeaders['Authorization'] = '$tokenType $accessToken';
    // });

    getDashboard();
  }

  getDashboard() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.get(
        url('api/getDashboard'),
        headers: requestHeaders,
      );

      if (response.statusCode == 200) {
        dynamic responseJson = jsonDecode(response.body);

        // if (responseJson['error'] == 'Unauthenticated') {
        //   showInSnackBar(
        //       'Token kedaluwarsa, silahkan logout dan login kembali');
        // }

        setSuperUser(responseJson['superuser']);

        DataStore store = DataStore();

        store.setDataString("username", responseJson['user']["u_username"]);
        store.setDataString("name", responseJson['user']["u_name"]);
        store.setDataString("email", responseJson['user']["u_email"]);
        store.setDataBool('u_typeuser', responseJson['superuser']);
        store.setDataString('idCabang', responseJson['cabang']['b_code']);
        store.setDataString('namaCabang', responseJson['cabang']['b_name']);
        store.setDataString('gambarUser', responseJson['user']['ed_path']);

        setState(() {
          _isError = false;
          requestMutasi = "${responseJson['count_request_mutasi']}";
          customerSudahBayar = "${responseJson['count_customer']}";
          customerSudahBayarOff = "${responseJson['count_customer_off']}";
          prosesPacking = "${responseJson['count_proses_packing']}";
          prosesPackingOff = "${responseJson['count_proses_packing_off']}";
          circleTime = '${responseJson['count_circle_time']}';
          opnameStok = '${responseJson['count_opname_stock']}';
          penerimaanBarang = '${responseJson['count_penerimaan_barang']}';
          _isLoading = false;
        });
      } else if (response.statusCode == 401) {
        showInSnackBar('Token kedaluwarsa, silahkan logout dan login kembali');
        setState(() {
          _isLoading = false;
          _isError = true;
          errorMessage = 'Token kedaluwarsa, silahkan logout dan login kembali';
        });
      } else {
        showInSnackBar('Error code : ${response.statusCode}');
        Map responseJson = jsonDecode(response.body);

        if (responseJson.containsKey('message')) {
          showInSnackBar(responseJson['message']);
          setState(() {
            _isLoading = false;
            _isError = true;
            errorMessage = responseJson['message'];
          });
        } else {
          print(jsonDecode(response.body));
          setState(() {
            _isLoading = false;
            _isError = true;
            errorMessage = 'Ada yang salah';
          });
        }
      }
    } on TimeoutException catch (_) {
      showInSnackBar('Timeout, please try again');
      setState(() {
        _isLoading = false;
        _isError = true;

        requestMutasi = '- Error -';
        customerSudahBayar = '- Error -';
        prosesPacking = '- Error -';

        errorMessage = 'Request Timeout, try again';
      });
    } catch (e, stacktrace) {
      print('Error: $e || StackTrace : $stacktrace');
      setState(() {
        _isError = true;
        _isLoading = false;
        requestMutasi = '- Error -';
        customerSudahBayar = '- Error -';
        prosesPacking = '- Error -';
        // errorMessage = e.toString();
        errorMessage = 'Error : $e';
      });
    }
  }

  setSuperUser(bool superuser) async {
    DataStore store = new DataStore();
    setState(() {
      store.setDataBool('u_typeuser', superuser);
    });
  }

  PusherService pusherService =
      PusherService(notificationService: notificationService);

  @override
  void initState() {
    _isLoading = false;
    _isError = false;
    errorMessage = '';

    requestMutasi = '- Loading -';
    customerSudahBayar = '- Loading -';
    customerSudahBayarOff = '- Loading -';
    prosesPacking = '- Loading -';
    prosesPackingOff = '- Loading -';
    opnameStok = '- Loading -';
    circleTime = '- Loading -';
    penerimaanBarang = '- Loading -';
    getHeaderHTTP();

    notificationService = new NotificationService(context: context);

    notificationService.initStateNotificationCustomerSudahBayarService();
    pusherService = PusherService(notificationService: notificationService);
    pusherService.firePusher();

    super.initState();
  }

  void dispose() {
    // pusherService.unbindEvent();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKeyX,
      appBar: AppBar(
        title: Text('Home'),
        // actions: <Widget>[
        //   IconButton(
        //     onPressed: () {
        //       print(MediaQuery.of(context).size.width);
        //     },
        //     icon: Icon(Icons.print),
        //   )
        // ],
      ),
      drawer: Sidebar(),
      body: _isLoading == true
          ? Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () => getDashboard(),
              child: _isError == true
                  ? Center(
                      child: ErrorOutputWidget(
                        errorMessage: errorMessage,
                        onPress: () {
                          getDashboard();
                        },
                      ),
                    )
                  : ListView(
                      padding: EdgeInsets.only(bottom: 10.0),
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(5.0),
                          margin: EdgeInsets.only(
                              top: 10.0, left: 10.0, right: 10.0),
                          // color: Colors.blue,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            gradient: LinearGradient(
                              colors: [
                                Colors.cyan[600],
                                Colors.blue[700],
                                Colors.cyan[400],
                              ],
                            ),
                          ),
                          child: Center(
                            child: IntrinsicHeight(
                              child: Column(
                                children: <Widget>[
                                  Icon(
                                    Icons.monetization_on,
                                    color: Colors.white,
                                    size: 80.0,
                                  ),
                                  Text(
                                    'Customer sudah bayar (Online)',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    customerSudahBayar,
                                    style: TextStyle(
                                      fontSize: 40.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(5.0),
                          margin: EdgeInsets.only(
                              top: 10.0, left: 10.0, right: 10.0),
                          // color: Colors.blue,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            gradient: LinearGradient(
                              colors: [
                                Colors.green[700],
                                Colors.green[300],
                                Colors.yellow,
                              ],
                            ),
                          ),
                          child: Center(
                            child: IntrinsicHeight(
                              child: Column(
                                children: <Widget>[
                                  Icon(
                                    Icons.monetization_on,
                                    color: Colors.white,
                                    size: 80.0,
                                  ),
                                  Text(
                                    'Customer sudah bayar (Offline)',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    customerSudahBayarOff,
                                    style: TextStyle(
                                      fontSize: 40.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(5.0),
                          // color: Colors.yellow,
                          margin: EdgeInsets.only(
                              top: 10.0, left: 10.0, right: 10.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            gradient: LinearGradient(
                              colors: [
                                Colors.purple[900],
                                Colors.purple[400],
                                Colors.pink[600],
                              ],
                            ),
                          ),
                          child: Center(
                            child: IntrinsicHeight(
                              child: Column(
                                children: <Widget>[
                                  Icon(
                                    Icons.sync,
                                    color: Colors.white,
                                    size: 80.0,
                                  ),
                                  Text(
                                    'Layanan Penjualan Offline - Proses Packing',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    prosesPackingOff,
                                    style: TextStyle(
                                      fontSize: 40.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(5.0),
                          // color: Colors.yellow,
                          margin: EdgeInsets.only(
                              top: 10.0, left: 10.0, right: 10.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            gradient: LinearGradient(
                              colors: [
                                Colors.yellow[400],
                                Colors.yellow[700],
                                Colors.orange[600],
                              ],
                            ),
                          ),
                          child: Center(
                            child: IntrinsicHeight(
                              child: Column(
                                children: <Widget>[
                                  Icon(
                                    Icons.sync,
                                    color: Colors.black54,
                                    size: 80.0,
                                  ),
                                  Text(
                                    'Layanan Penjualan Online - Proses Packing',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  Text(
                                    prosesPacking,
                                    style: TextStyle(
                                      fontSize: 40.0,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(5.0),
                          // color: Colors.green[700],
                          margin: EdgeInsets.only(
                              top: 10.0, left: 10.0, right: 10.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            gradient: LinearGradient(
                              colors: [
                                Colors.pink[200],
                                Colors.pink[600],
                                Colors.pink[400],
                              ],
                            ),
                          ),
                          child: Center(
                            child: IntrinsicHeight(
                              child: Column(
                                children: <Widget>[
                                  Icon(
                                    Icons.home,
                                    color: Colors.white,
                                    size: 80.0,
                                  ),
                                  Text(
                                    'Request mutasi antar gudang',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    requestMutasi,
                                    style: TextStyle(
                                      fontSize: 40.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(5.0),
                          // color: Colors.red,
                          margin: EdgeInsets.only(
                              top: 10.0, left: 10.0, right: 10.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            gradient: LinearGradient(
                              colors: [
                                Colors.cyan[800],
                                Colors.cyan[600],
                                Colors.cyan[900],
                              ],
                            ),
                          ),

                          child: Center(
                            child: IntrinsicHeight(
                              child: Column(
                                children: <Widget>[
                                  Icon(
                                    Icons.input,
                                    color: Colors.white,
                                    size: 80.0,
                                  ),
                                  Text(
                                    'Penerimaan barang masuk dari supplier',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    penerimaanBarang,
                                    style: TextStyle(
                                      fontSize: 40.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(5.0),
                          // color: Colors.orange,
                          margin: EdgeInsets.only(
                              top: 10.0, left: 10.0, right: 10.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            gradient: LinearGradient(
                              colors: [
                                Colors.pink[800],
                                Colors.purple[700],
                                Colors.purple[400],
                              ],
                            ),
                          ),

                          child: Center(
                            child: IntrinsicHeight(
                              child: Column(
                                children: <Widget>[
                                  Icon(
                                    Icons.crop_5_4,
                                    color: Colors.white,
                                    size: 80.0,
                                  ),
                                  Text(
                                    'Produk yang sudah diopname pertama kali',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    circleTime,
                                    style: TextStyle(
                                      fontSize: 40.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(5.0),
                          // color: Colors.purple,
                          margin: EdgeInsets.only(
                              top: 10.0, left: 10.0, right: 10.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            gradient: LinearGradient(
                              colors: [
                                Colors.orange[600],
                                Colors.redAccent[700],
                                Colors.red,
                              ],
                            ),
                          ),
                          child: Center(
                            child: IntrinsicHeight(
                              child: Column(
                                children: <Widget>[
                                  Icon(
                                    Icons.crop_square,
                                    color: Colors.white,
                                    size: 80.0,
                                  ),
                                  Text(
                                    'Produk yang belum diopname pertama kali',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    opnameStok,
                                    style: TextStyle(
                                      fontSize: 40.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),
    );
  }
}
