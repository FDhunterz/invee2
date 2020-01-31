import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:invee2/error/error.dart';
import 'package:invee2/localStorage/localStorage.dart';
import 'package:invee2/penjualan/antrian_layanan/detail.dart';
import 'package:invee2/penjualan/antrian_layanan/filterHistoryAntrian.dart';
import 'package:invee2/penjualan/antrian_layanan/secondary/model.dart';
import 'dart:convert';
import 'dart:async';
import 'package:invee2/routes/env.dart';

GlobalKey<ScaffoldState> _scaffoldKeyCariHistoryAntrian;
TextEditingController cariController;
FocusNode cariFocus;

bool isLoading, isError;
String tokenType, accessToken;
Map<String, String> requestHeaders = Map();

DateTime tanggal1, tanggal2;
List<ListAntrian> listAntrian = List<ListAntrian>();
Timer timer;
int delayRequest;

showInSnackbar(String content) {
  _scaffoldKeyCariHistoryAntrian.currentState.showSnackBar(
    SnackBar(
      content: Text(content),
    ),
  );
}

class CariHistoryAntrian extends StatefulWidget {
  @override
  _CariHistoryAntrianState createState() => _CariHistoryAntrianState();
}

class _CariHistoryAntrianState extends State<CariHistoryAntrian> {
  Future<Null> cariHistoryAntrian() async {
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
    Map requestBody;
    requestBody = Map();
    if (tanggal1 != null && tanggal2 != null) {
      requestBody['tanggal1'] = tanggal1.toString();
      requestBody['tanggal2'] = tanggal2.toString();
      requestBody['cari'] = cariController.text;
    } else {
      requestBody['cari'] = cariController.text;
    }

    try {
      final response = await http.post(
        url('api/cariHistoryAntrian'),
        headers: requestHeaders,
        body: requestBody,
      );

      if (response.statusCode == 200) {
        dynamic responseJson = jsonDecode(response.body);

        listAntrian = List<ListAntrian>();

        for (var i in responseJson) {
          ListAntrian wishlistLoop = ListAntrian(
            id: i['sq_id'].toString(),
            nomor: '${i['sq_nomor']}',
            name: i['cm_name'],
            tanggalDiBuat: i['sq_create_at'],
            status: i['sq_status'],
            email: i['cm_email'],
            noTelp: i['cm_nphone'],
          );
          listAntrian.add(wishlistLoop);
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

        if(responseJson.containsKey('message')){
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

  Widget statusAntrian(String status) {
    if (status == 'O') {
      return Container(
        padding: EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          color: Colors.cyan,
        ),
        child: Text(
          'Menunggu Antrian',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      );
    } else if (status == 'P') {
      return Container(
        padding: EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          color: Colors.orange,
        ),
        child: Text(
          'Proses',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      );
    } else if (status == 'C') {
      return Container(
        padding: EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          color: Colors.red,
        ),
        child: Text(
          'Batal',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      );
    } else if (status == 'D') {
      return Container(
        padding: EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          color: Colors.green,
        ),
        child: Text(
          'Selesai',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      );
    }
    return Container();
  }

  timerUntukRequest() async {
    timer = Timer.periodic(
      Duration(
        seconds: 1,
      ),
      (Timer timerX) {
        if (delayRequest < 1) {
          cariHistoryAntrian();
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
    tanggal1 = null;
    tanggal2 = null;

    _scaffoldKeyCariHistoryAntrian = GlobalKey<ScaffoldState>();
    cariController = TextEditingController();
    cariFocus = FocusNode();
    delayRequest = 0;

    cariHistoryAntrian();
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
      key: _scaffoldKeyCariHistoryAntrian,
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
            decoration:
                InputDecoration(border: InputBorder.none, hintText: 'Cari'),
            onChanged: (ini) {
              cariController.value = TextEditingValue(
                selection: cariController.selection,
                text: ini,
              );
              
              if(delayRequest < 2 && delayRequest != 0){
                timer.cancel();
              }
              delayRequest = 2;
              timerUntukRequest();
            },
          ),
        ),
      ),
      floatingActionButton: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
        onPressed: () async {
          Map<String, DateTime> filter = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => FilterHistoryAntrian(
                tanggalX: tanggal1,
                tanggal2X: tanggal2,
              ),
            ),
          );

          if (filter != null) {
            tanggal1 = filter['tanggal1'];
            tanggal2 = filter['tanggal2'];

            cariHistoryAntrian();
          }
        },
        child: Text('Filter'),
        textColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : isError
              ? ErrorCobalLagi(
                  onPress: cariHistoryAntrian,
                )
              : ListView.builder(
                  itemCount: listAntrian.length,
                  itemBuilder: (BuildContext context, int i) => Container(
                    margin: EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5.0),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.grey[300].withOpacity(0.5),
                          blurRadius: 1.0,
                          spreadRadius: 1.0,
                          offset: Offset(1.0, 1.0),
                        ),
                      ],
                    ),
                    child: Card(
                      child: ListTile(
                        leading: Icon(FontAwesomeIcons.listOl),
                        title: Text("Nomor " + listAntrian[i].nomor),
                        subtitle: Text('${listAntrian[i].name}'),
                        trailing: Column(
                          children: <Widget>[
                            statusAntrian(listAntrian[i].status),
                            Container(
                              padding: EdgeInsets.only(
                                top: 5.0,
                                bottom: 5.0,
                              ),
                              child: Text(
                                DateFormat('dd MMMM yyyy H:mm:ss').format(
                                  DateTime.parse(listAntrian[i].tanggalDiBuat),
                                ),
                              ),
                            )
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) => DetailAntrian(
                                id: listAntrian[i].id,
                                nomor: listAntrian[i].nomor,
                                name: listAntrian[i].name,
                                tanggalDibuat: listAntrian[i].tanggalDiBuat,
                                status: listAntrian[i].status,
                                cumanHistory: true,
                                email: listAntrian[i].email,
                                noTelp: listAntrian[i].noTelp,
                              ),
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
