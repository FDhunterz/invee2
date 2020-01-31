import 'package:flutter/material.dart';
import 'package:invee2/localStorage/localStorage.dart';
import 'package:http/http.dart' as http;
import 'package:invee2/routes/env.dart';
import 'dart:async';
import 'dart:convert';
// import 'package:invee2/shimmer_loading.dart';

var tokenType, accessToken;
Map<String, String> requestHeaders = Map();
List<DaftarProdukOpname> listItemArray;
bool isLoading;

class TabDetailOpnameManual extends StatefulWidget {
  final String id, ref, date, gudang, status, catatan;

  TabDetailOpnameManual(
      {this.id, this.ref, this.date, this.gudang, this.status, this.catatan});

  @override
  State<StatefulWidget> createState() {
    return _TabDetailOpnameManualState(
      id: id,
      ref: ref,
      date: date,
      gudang: gudang,
      status: status,
      catatan: catatan,
    );
  }
}

class _TabDetailOpnameManualState extends State<TabDetailOpnameManual> {
  final String id, ref, date, gudang, status, catatan;
  _TabDetailOpnameManualState(
      {this.id, this.ref, this.date, this.gudang, this.status, this.catatan});

  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  Widget keteranganOpname(String status) {
    if (status == 'new') {
      return Text(
        'Opname Pertama Kali',
        style: TextStyle(
          color: Colors.black54,
        ),
      );
    } else if (status == 'temuan') {
      return Text(
        'Barang Temuan',
        style: TextStyle(
          color: Colors.black54,
        ),
      );
    } else if (status == 'hilang') {
      return Text(
        'Barang Hilang',
        style: TextStyle(
          color: Colors.black54,
        ),
      );
    } else if (status == 'sama') {
      return Text(
        'Tidak ada Kekurangan',
        style: TextStyle(
          color: Colors.black54,
        ),
      );
    } else if (status == 'rusak') {
      return Text(
        'Barang Rusak',
        style: TextStyle(
          color: Colors.black54,
        ),
      );
    }
    return Container();
  }

  Future<Null> getHeaderHTTP() async {
    var storage = new DataStore();

    var tokenTypeStorage = await storage.getDataString('token_type');
    var accessTokenStorage = await storage.getDataString('access_token');

    tokenType = tokenTypeStorage;
    accessToken = accessTokenStorage;

    requestHeaders['Accept'] = 'application/json';
    requestHeaders['Authorization'] = '$tokenType $accessToken';
    print(requestHeaders);

    await listItemOpnameStokAndroid();
  }

  Future<List<DaftarProdukOpname>> listItemOpnameStokAndroid() async {
    setState(() {
      isLoading = true;
    });
    try {
      final item = await http.post(
        url('api/DetailOpnameStockAndroid'),
        headers: requestHeaders,
        body: {'ref': ref},
      );

      if (item.statusCode == 200) {
        // return nota;
        var itemJson = json.decode(item.body);
        print(itemJson);
        listItemArray = [];
        for (var i in itemJson) {
          DaftarProdukOpname notax = DaftarProdukOpname(
            nama: i['i_name'],
            satuan: i['iu_name'],
            stokAdjustment: i['os_stockadjust'].toString(),
            stokGudang: i['os_stocknow'].toString(),
            stokSistem: i['os_stocksystem'].toString(),
            keterangan: i['os_status'],
          );
          listItemArray.add(notax);
        }

        print('listItemArray $listItemArray');
        print('length listItemArray ${listItemArray.length}');
        setState(() {
          isLoading = false;
        });
        return listItemArray;
      } else {
        showInSnackBar('Request failed with status: ${item.statusCode}');
        Map responseJson = jsonDecode(item.body);

        if(responseJson.containsKey('message')){
          showInSnackBar(responseJson['message']);
        }
        setState(() {
          isLoading = false;
        });
      }
    } on TimeoutException catch (_) {
      showInSnackBar('Timed out, Try again');
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
  initState() {
    getHeaderHTTP();

    listItemArray = [];
    isLoading = false;
    super.initState();
  }

  Widget statusOpname(status) {
    if (status == 'waiting') {
      return Text(
        'Belum disetujui',
        style: TextStyle(backgroundColor: Colors.orange, color: Colors.white),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Detail Opname Manual'),
          bottom: TabBar(
            tabs: <Widget>[
              Tab(
                icon: Icon(Icons.check_circle),
                text: 'Detail Opname',
              ),
              Tab(
                icon: Icon(Icons.list),
                text: 'Daftar Produk',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            Scaffold(
              backgroundColor: Colors.grey[300],
              body: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Card(
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(5.0),
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(5.0),
                                    child: Text(
                                      'No.ref',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(5.0),
                                    child: Text(
                                      '$ref',
                                      style: TextStyle(
                                        color: Colors.black54,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(5.0),
                                    child: Text(
                                      'Lokasi Opname',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(5.0),
                                    child: Text(
                                      '$gudang',
                                      style: TextStyle(
                                        color: Colors.black54,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(5.0),
                                    child: Text(
                                      'Tanggal Opname',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(5.0),
                                    child: Text(
                                      '$date',
                                      style: TextStyle(
                                        color: Colors.black54,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(5.0),
                                    child: Text(
                                      'Catatan Opname',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(5.0),
                                    child: Text(
                                      '$catatan',
                                      style: TextStyle(
                                        color: Colors.black54,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(5.0),
                                    child: Text(
                                      'Status Opname',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(5.0),
                                    child: statusOpname(status),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Scaffold(
              backgroundColor: Colors.grey[300],
              body: Container(
                child: isLoading == true
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : listItemArray.length == 0
                        ? Center(
                            child: ListTile(
                              title: Text(
                                'Tidak ada data',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : Scrollbar(
                            child: ListView.builder(
                              // scrollDirection: Axis.horizontal,
                              itemCount: listItemArray.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Card(
                                  child: Container(
                                    padding: EdgeInsets.all(10.0),
                                    child: Column(
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                              flex: 4,
                                              child: Text(
                                                'Nama Produk',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 5,
                                              child: Text(
                                                listItemArray[index].nama,
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
                                                'Satuan',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 5,
                                              child: Text(
                                                listItemArray[index].satuan,
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
                                                'Catatan Opname',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 5,
                                              child: keteranganOpname(listItemArray[index].keterangan),
                                              
                                            ),
                                          ],
                                        ),
                                        Divider(),
                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Column(
                                                children: <Widget>[
                                                  Container(
                                                    width: double.infinity,
                                                    child: Text(
                                                      'Stok Sistem',
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    width: double.infinity,
                                                    child: Text(
                                                      listItemArray[index]
                                                          .stokSistem,
                                                      style: TextStyle(
                                                        color: Colors.black54,
                                                        fontSize: 16.0,
                                                      ),
                                                      textAlign: TextAlign.left,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: Column(
                                                children: <Widget>[
                                                  Container(
                                                    width: double.infinity,
                                                    child: Text(
                                                      'Stok Gudang',
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    width: double.infinity,
                                                    child: Text(
                                                      listItemArray[index]
                                                          .stokGudang,
                                                      style: TextStyle(
                                                        color: Colors.black54,
                                                        fontSize: 16.0,
                                                      ),
                                                      textAlign: TextAlign.left,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: Column(
                                                children: <Widget>[
                                                  Container(
                                                    width: double.infinity,
                                                    child: Text(
                                                      'Stok Adjustment',
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    width: double.infinity,
                                                    child: Text(
                                                      listItemArray[index]
                                                          .stokAdjustment,
                                                      style: TextStyle(
                                                        color: Colors.black54,
                                                        fontSize: 16.0,
                                                      ),
                                                      textAlign: TextAlign.left,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DaftarProdukOpname {
  String nama, satuan, stokSistem, stokGudang, stokAdjustment, keterangan;
  DaftarProdukOpname({
    this.nama,
    this.satuan,
    this.stokSistem,
    this.stokAdjustment,
    this.stokGudang,
    this.keterangan,
  });
}
