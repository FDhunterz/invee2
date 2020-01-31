import 'dart:async';

import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:invee2/error/error.dart';
import 'package:invee2/gudang/opname_stock/model.dart';
import 'package:invee2/gudang/opname_stock/tab_circle/custom_list_circle.dart';
import 'package:invee2/gudang/opname_stock/tab_circle/detail_circletime.dart';
import 'package:invee2/gudang/opname_stock/tab_manual/tab_detail_manual.dart';
import 'package:invee2/localStorage/localStorage.dart';
import 'dart:convert';
import 'package:invee2/routes/env.dart';

GlobalKey<ScaffoldState> _scaffoldKeyCariOpnameStock;
TextEditingController cariController;
FocusNode cariFocus;

bool isLoading, isError;
String tokenType, accessToken;
Map<String, String> requestHeaders = Map();

List<ListCircleTime> listCircleTime = List<ListCircleTime>();
List<ListOpnameStok> listOpnameStock = List<ListOpnameStok>();

int delayRequest;
Timer timer;

showInSnackbar(String content) {
  _scaffoldKeyCariOpnameStock.currentState.showSnackBar(
    SnackBar(
      content: Text(content),
    ),
  );
}

class CariOpnameStock extends StatefulWidget {
  @override
  _CariOpnameStockState createState() => _CariOpnameStockState();
}

class _CariOpnameStockState extends State<CariOpnameStock> {
  Widget statusOpname(status) {
    if (status == 'waiting') {
      return Text(
        'Belum disetujui',
        style: TextStyle(backgroundColor: Colors.orange, color: Colors.white),
      );
    }
    return null;
  }

  Future<Null> cariOpnameStock() async {
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
        url('api/cariOpnameStock'),
        headers: requestHeaders,
        body: {
          'cari': cariController.text,
        },
      );

      if (response.statusCode == 200) {
        dynamic responseJson = jsonDecode(response.body);

        listCircleTime = List<ListCircleTime>();

        for (var i in responseJson['circle_time']) {
          ListCircleTime wishlistLoop = ListCircleTime(
            idOpname: i['os_id'].toString(),
            idProduk: i['i_id'].toString(),
            namaProduk: i['i_name'],
            nextCircle: i['next_opname'],
            gudang: i['w_name'],
            status: i['os_statusadjust'],
            satuan: i['iu_name'],
            stokSistem: i['stok_sistem'].toString(),
            circleTime: i['its_sopname'].toString(),
            lastCircle: i['os_lastdate'],
          );
          listCircleTime.add(wishlistLoop);
        }

        listOpnameStock = List<ListOpnameStok>();

        for (var i in responseJson['opname_stock']) {
          ListOpnameStok opnamex = ListOpnameStok(
            id: i['os_id'].toString(),
            ref: i['os_ref'],
            date: i['os_date'],
            gudang: i['w_name'],
            status: i['os_statusadjust'],
            catatan: i['os_note'],
          );
          listOpnameStock.add(opnamex);
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
        print(jsonDecode(response.body));
        Map responseJson = jsonDecode(response.body);

        if(responseJson.containsKey('message')){
          showInSnackbar(responseJson['message']);
        }
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
          cariOpnameStock();
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
    _scaffoldKeyCariOpnameStock = GlobalKey<ScaffoldState>();
    cariController = TextEditingController();
    cariFocus = FocusNode();
    delayRequest = 0;

    cariOpnameStock();
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
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          key: _scaffoldKeyCariOpnameStock,
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
                    border: InputBorder.none, hintText: 'Cari Nama/Nota'),
                onChanged: (ini) async {
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
            bottom: TabBar(
              labelColor: Colors.black,
              indicatorColor: Colors.green,
              isScrollable: true,
              tabs: <Widget>[
                Tab(
                  icon: Icon(Icons.access_time),
                  text: 'Opname Stok Circle Time',
                ),
                Tab(
                  icon: Icon(Icons.crop_square),
                  text: 'Opname Stok Manual',
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: <Widget>[
              // Tab Index 0
              isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : isError
                      ? ErrorCobalLagi(
                          onPress: cariOpnameStock,
                        )
                      : ListView.builder(
                          itemCount: listCircleTime.length,
                          itemBuilder: (BuildContext context, int i) => Card(
                            child: CustomListCircle(
                              idOpname: listCircleTime[i].idOpname,
                              idProduk: listCircleTime[i].idProduk,
                              circleTime: listCircleTime[i].circleTime,
                              gudang: listCircleTime[i].gudang,
                              namaProduk: listCircleTime[i].namaProduk,
                              nextCircle: listCircleTime[i].nextCircle,
                              status: listCircleTime[i].status,
                              satuan: listCircleTime[i].satuan,
                              stokSistem: listCircleTime[i].stokSistem,
                              lastCircle: listCircleTime[i].lastCircle,
                              onTap: () {
                                //Some Function
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) {
                                      return DetailCircleTime(
                                        idOpname: listCircleTime[i].idOpname,
                                        idProduk: listCircleTime[i].idProduk,
                                        circleTime:
                                            listCircleTime[i].circleTime,
                                        gudang: listCircleTime[i].gudang,
                                        namaProduk:
                                            listCircleTime[i].namaProduk,
                                        nextCircle:
                                            listCircleTime[i].nextCircle,
                                        status: listCircleTime[i].status,
                                        satuan: listCircleTime[i].satuan,
                                        stokSistem:
                                            listCircleTime[i].stokSistem,
                                        lastCircle:
                                            listCircleTime[i].lastCircle,
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

              // End Tab Index 0

              // Tab Index 1
              isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : isError
                      ? ErrorCobalLagi(
                          onPress: cariOpnameStock,
                        )
                      : ListView.builder(
                          itemCount: listOpnameStock.length,
                          itemBuilder: (BuildContext context, int i) => Card(
                            child: ListTile(
                              leading: Icon(Icons.note),
                              title: Text(listOpnameStock[i].ref),
                              subtitle: Text('${listOpnameStock[i].gudang}'),
                              trailing: Column(
                                children: <Widget>[
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.all(5.0),
                                      child: Text(listOpnameStock[i].date),
                                    ),
                                  ),
                                  Expanded(
                                    child:
                                        statusOpname(listOpnameStock[i].status),
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        TabDetailOpnameManual(
                                      id: listOpnameStock[i].id,
                                      ref: listOpnameStock[i].ref,
                                      date: listOpnameStock[i].date,
                                      gudang: listOpnameStock[i].gudang,
                                      status: listOpnameStock[i].status,
                                      catatan: listOpnameStock[i].catatan,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
              // End Tab Index 1
            ],
          ),
        ),
      ),
    );
  }
}
