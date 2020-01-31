// import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
// import 'package:invee2/gudang/opname_stock/cariOpnameStock.dart';
import 'dart:io';
import 'package:invee2/gudang/opname_stock/model.dart';
import 'package:invee2/routes/env.dart';
import 'package:invee2/shimmer_loading.dart';
// import 'package:invee2/shimmer_loading.dart';
import './custom_list_circle.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:invee2/localStorage/localStorage.dart';
import './detail_circletime.dart';

String tokenType, accessToken;
Map<String, String> requestHeaders = Map();
bool isLoading;
GlobalKey<ScaffoldState> _scaffoldKeyY;
PagewiseLoadController pagewiseCircleTimeController;
int pageSize;

void showInSnackBarCircle(String value) {
  _scaffoldKeyY.currentState.showSnackBar(
    SnackBar(
      content: Text(value),
    ),
  );
}

class TabCircle extends StatefulWidget {
  final bool loading;
  TabCircle({this.loading});
  @override
  State<StatefulWidget> createState() {
    return _TabCircleState();
  }
}

List<String> _status = [
  'Semua',
  'Belum diinput',
  'Hari Ini',
  'Terlambat',
  'Di Setujui'
];
String _selectedValue = 'Semua';

class _TabCircleState extends State<TabCircle> {
  var indexx;
  Future<List<ListCircleTime>> listCircleTimeAndroid({filter, index}) async {
    var storage = new DataStore();

    var tokenTypeStorage = await storage.getDataString('token_type');
    var accessTokenStorage = await storage.getDataString('access_token');

    tokenType = tokenTypeStorage;
    accessToken = accessTokenStorage;

    requestHeaders['Accept'] = 'application/json';
    requestHeaders['Authorization'] = '$tokenType $accessToken';
    print(requestHeaders);

    if (filter == null || filter == '') {
      filter = 'Semua';
    }
    // setState(() {
    //   isLoading = true;
    // });
    try {
      Map<String, dynamic> form = Map();
      form['filter'] = filter;
      form['size'] = pageSize.toString();
      form['index'] = index.toString();
      indexx = index.toString();

      final circle = await http.post(
        url('api/listCircleTimeAndroid'),
        headers: requestHeaders,
        body: form,
      );

      // Dio dio = new Dio();

      // Response circle = await dio.post(
      //   url('api/listCircleTimeAndroid'),
      //   data: form,
      //   options: Options(
      //     headers: requestHeaders,
      //   ),
      // );

      if (circle.statusCode == 200) {
        // return nota;
        // var circleJson = circle.data;
        var circleJson = jsonDecode(circle.body);

        print('circleJson $circleJson');
        listCircleTimeArray = [];
        for (var i in circleJson) {
          ListCircleTime circleX = ListCircleTime(
            idOpname: i['os_id'].toString(),
            idProduk: i['i_id'].toString(),
            namaProduk: i['i_name'],
            nextCircle: i['next_opname'],
            gudang: i['w_name'],
            status: i['os_statusadjust'].toString(),
            satuan: i['iu_name'],
            stokSistem: i['stok_sistem'].toString(),
            circleTime: i['its_sopname'].toString(),
            lastCircle: i['os_lastdate'],
          );
          listCircleTimeArray.add(circleX);
        }

        print('listnota $listCircleTimeArray');
        print('listnota length ${listCircleTimeArray.length}');

        // setState(() {
        //   isLoading = false;
        // });
        return listCircleTimeArray;
      } else if (circle.statusCode == 401) {
        showInSnackBarCircle(
            'Token kedaluwarsa, silahkan logout dan login kembali');
      } else {
        showInSnackBarCircle(
            'Request failed with status: ${circle.statusCode}');
        Map responseJsonX = jsonDecode(circle.body);
        if (responseJsonX.containsKey('message')) {
          showInSnackBarCircle(responseJsonX['message']);
        }
        print(jsonDecode(circle.body));
        return null;
      }
    } on TimeoutException catch (_) {
      showInSnackBarCircle('Timed out, Try again');
      // setState(() {
      //   isLoading = false;
      // });
    } on SocketException catch (_) {
      showInSnackBarCircle('Host not found');
      // setState(() {
      //   isLoading = false;
      // });
      // } on DioError catch (e) {
      //   // The request was made and the server responded with a status code
      //   // that falls out of the range of 2xx and is also not 304.
      //   print("TYPE = ${e.type}");
      //   print("REQUEST > SUB = ${e.request}");
      //   print("RESPONSE = ${e.response}");
      //   print("ERROR = ${e.error}");
      //   print("HASHCODE = ${e.hashCode}");
      //   print("MESSAGE = ${e.message.}");
      //   print("RUNTIME TYPE = ${e.runtimeType}");
      //   if (e.response != null) {
      //     print(e.response.data);
      //     print(e.response.headers);
      //     print(e.response.request);
      //   } else {
      //     // Something happened in setting up or sending the request that triggered an Error
      //     print(e.request);
      //     print(e.message);
      //   }
      //   // throw (e);
    } catch (e, stacktrace) {
      debugPrint('unknownError : $e, $stacktrace');
      // setState(() {
      //   isLoading = false;
      // });
    }
    // setState(() {
    //   isLoading = false;
    // });
    return null;
  }

  int totalRefresh = 0;
  refreshFunction() async {
    setState(() {
      totalRefresh += 1;
    });
    await Future.delayed(
      Duration(
        milliseconds: 100,
      ),
    );
  }

  @override
  void initState() {
    _scaffoldKeyY = new GlobalKey<ScaffoldState>();
    isLoading = widget.loading;
    pageSize = 16;
    pagewiseCircleTimeController = PagewiseLoadController(
      pageSize: pageSize,
      pageFuture: (index) {
        return listCircleTimeAndroid(
          filter: _selectedValue,
          index: index,
        );
      },
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKeyY,
      body: RefreshIndicator(
        onRefresh: () async {
          pagewiseCircleTimeController.reset();
          await Future.value({});
        },
        child: Scrollbar(
          child: PagewiseListView(
            pageLoadController: pagewiseCircleTimeController,
            loadingBuilder: (BuildContext context) => ShimmerLoadingList(),
            noItemsFoundBuilder: (BuildContext context) => ListTile(
              title: Text(
                'Tidak ada Data',
                textAlign: TextAlign.center,
              ),
            ),
            itemBuilder: (BuildContext context, dynamic listCircleTime, int i) {
              return Card(
                child: CustomListCircle(
                  idOpname: listCircleTime.idOpname,
                  idProduk: listCircleTime.idProduk,
                  circleTime: listCircleTime.circleTime,
                  gudang: listCircleTime.gudang,
                  namaProduk: listCircleTime.namaProduk,
                  nextCircle: listCircleTime.nextCircle,
                  status: listCircleTime.status,
                  satuan: listCircleTime.satuan,
                  stokSistem: listCircleTime.stokSistem,
                  lastCircle: listCircleTime.lastCircle,
                  onTap: () {
                    //Some Function
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return DetailCircleTime(
                            idOpname: listCircleTime.idOpname,
                            idProduk: listCircleTime.idProduk,
                            circleTime: listCircleTime.circleTime,
                            gudang: listCircleTime.gudang,
                            namaProduk: listCircleTime.namaProduk,
                            nextCircle: listCircleTime.nextCircle,
                            status: listCircleTime.status,
                            satuan: listCircleTime.satuan,
                            stokSistem: listCircleTime.stokSistem,
                            lastCircle: listCircleTime.lastCircle,
                          );
                        },
                      ),
                    );
                  },
                ),
              );
            },
          ),
          // FutureBuilder(
          //   future: listCircleTimeAndroid(filter: _selectedValue),
          //   builder: (BuildContext context, AsyncSnapshot snapshot) {
          //     switch (snapshot.connectionState) {
          //       case ConnectionState.none:
          //         return ListTile(
          //           title: Text('Tekan Tombol Mulai.'),
          //         );
          //       case ConnectionState.active:
          //       case ConnectionState.waiting:
          //         return ShimmerLoadingList();
          //       // return Center(
          //       //   child: CircularProgressIndicator(),
          //       // );
          //       case ConnectionState.done:
          //         if (snapshot.hasError) {
          //           return Text('Error: ${snapshot.error}');
          //         }
          //         if (snapshot.data == null ||
          //             snapshot.data == 0 ||
          //             snapshot.data.length == null ||
          //             snapshot.data.length == 0) {
          //           return ListView(
          //             children: <Widget>[
          //               Card(
          //                 child: ListTile(
          //                   title: Text(
          //                     'Tidak ada data',
          //                     textAlign: TextAlign.center,
          //                   ),
          //                 ),
          //               )
          //             ],
          //           );
          //         } else if (snapshot.data != null || snapshot.data != 0) {
          //           return ListView.builder(
          //             itemCount: snapshot.data.length,
          //             itemBuilder: (BuildContext context, int index) {
          //               return Card(
          //                 child: CustomListCircle(
          //                   idOpname: snapshot.data[index].idOpname,
          //                   idProduk: snapshot.data[index].idProduk,
          //                   circleTime: snapshot.data[index].circleTime,
          //                   gudang: snapshot.data[index].gudang,
          //                   namaProduk: snapshot.data[index].namaProduk,
          //                   nextCircle: snapshot.data[index].nextCircle,
          //                   status: snapshot.data[index].status,
          //                   satuan: snapshot.data[index].satuan,
          //                   stokSistem: snapshot.data[index].stokSistem,
          //                   lastCircle: snapshot.data[index].lastCircle,
          //                   onTap: () {
          //                     //Some Function
          //                     Navigator.push(
          //                       context,
          //                       MaterialPageRoute(
          //                         builder: (BuildContext context) {
          //                           return DetailCircleTime(
          //                             idOpname: snapshot.data[index].idOpname,
          //                             idProduk: snapshot.data[index].idProduk,
          //                             circleTime:
          //                                 snapshot.data[index].circleTime,
          //                             gudang: snapshot.data[index].gudang,
          //                             namaProduk:
          //                                 snapshot.data[index].namaProduk,
          //                             nextCircle:
          //                                 snapshot.data[index].nextCircle,
          //                             status: snapshot.data[index].status,
          //                             satuan: snapshot.data[index].satuan,
          //                             stokSistem:
          //                                 snapshot.data[index].stokSistem,
          //                             lastCircle:
          //                                 snapshot.data[index].lastCircle,
          //                           );
          //                         },
          //                       ),
          //                     );
          //                   },
          //                 ),
          //               );
          //             },
          //           );
          //         }
          //     }
          //     return null; // unreachable
          //   },
          // ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: <Widget>[
            Expanded(
              child: Container(
                  padding: EdgeInsets.all(15.0),
                  child: Text(
                    'Filter berdasarkan :',
                    textAlign: TextAlign.right,
                  )),
            ),
            Expanded(
              child: DropdownButton(
                items: _status.map((f) {
                  return DropdownMenuItem(
                    child: Text(f),
                    value: f,
                  );
                }).toList(),
                value: _selectedValue,
                onChanged: (thisValue) {
                  setState(() {
                    _selectedValue = thisValue;
                  });
                  pagewiseCircleTimeController.reset();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
