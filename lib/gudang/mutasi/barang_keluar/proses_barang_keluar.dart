import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:invee2/error/error.dart';
import 'package:invee2/gudang/mutasi/barang_keluar/customtile_barangkeluar.dart';
import 'package:invee2/gudang/mutasi/barang_keluar/model.dart';
import 'package:invee2/localStorage/localStorage.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
// import 'dart:io';

import 'package:invee2/routes/env.dart';

TabController _tabController;
int tabIndex;

TextEditingController _catatan, _tanggalPengiriman, _noResi;
FocusNode _catatanFocus, _tanggalPengirimanFocus, _noResiFocus;

String tokenType, accessToken;
Map<String, String> requestHeaders = Map();

String noReff, noReq;
List<Produk> listProduk;

bool isLoading, isError;
DateTime selectedDate;

List<TextEditingController> listController;
List<FocusNode> listFocus;

GlobalKey<FormState> _form;
Map<String, dynamic> formSerialize;

GlobalKey<ScaffoldState> _scaffoldBK = GlobalKey<ScaffoldState>();

showInSnackBarBK(String value) {
  _scaffoldBK.currentState.showSnackBar(
    new SnackBar(
      content: Text(value),
    ),
  );
}

class ProsesBarangKeluar extends StatefulWidget {
  final String ref, idGudang, gudang;
  ProsesBarangKeluar({
    this.ref,
    this.idGudang,
    this.gudang,
  });
  @override
  _ProsesBarangKeluarState createState() => _ProsesBarangKeluarState();
}

class _ProsesBarangKeluarState extends State<ProsesBarangKeluar>
    with TickerProviderStateMixin {
  Future<Null> getHeaderHTTP() async {
    var storage = new DataStore();

    var tokenTypeStorage = await storage.getDataString('token_type');
    var accessTokenStorage = await storage.getDataString('access_token');

    // setState(() {
    tokenType = tokenTypeStorage;
    accessToken = accessTokenStorage;

    requestHeaders['Accept'] = 'application/json';
    requestHeaders['Authorization'] = '$tokenType $accessToken';
    print(requestHeaders);
    // });
    prosesBarangKeluar();
  }

  Future<Null> prosesBarangKeluar() async {
    setState(() {
      isError = false;
      isLoading = true;
    });
    try {
      final response = await http.post(
        url('api/prosesBarangKeluar'),
        headers: requestHeaders,
        body: {
          'ref': widget.ref,
        },
      );

      if (response.statusCode == 200) {
        dynamic responseJson = jsonDecode(response.body);

        // if (responseJson['error'] == 'Unauthenticated') {
        //   showInSnackBarBK(
        //       'Token kedaluwarsa, silahkan logout dan login kembali');
        // }

        setState(() {
          noReff = responseJson['ref'];
        });

        listProduk = List();
        listController = List();
        listFocus = List();

        for (int i = 0; i < responseJson['data'].length; i++) {
          TextEditingController _controller = TextEditingController();
          FocusNode _focus = FocusNode();

          listController.add(_controller);
          listFocus.add(_focus);

          Produk produk = Produk(
            idRequestMutasi: '${responseJson['data'][i]['rm_id']}',
            namaProduk: responseJson['data'][i]['i_name'],
            namaSatuan: responseJson['data'][i]['iu_name'],
            kodeSatuan: responseJson['data'][i]['iu_code'],
            gudangPeminta: responseJson['data'][i]['w_name'],
            idGudangPeminta: responseJson['data'][i]['w_code'],
            idGudangDiminta: widget.idGudang,
            gudangDiminta: widget.gudang,
            codeProduk: responseJson['data'][i]['i_code'],
            stokDiminta: '${responseJson['data'][i]['rm_requestqty']}',
            stokGudangDiminta: '${responseJson['data'][i]['st_qty']}',
          );
          listProduk.add(produk);
        }
        setState(() {
          isError = false;
          isLoading = false;
        });
      } else {
        print('Error Code : ${response.statusCode}');
        showInSnackBarBK('Error Code : ${response.statusCode}');
        Map responseJson = jsonDecode(response.body);

        if (responseJson.containsKey('message')) {
          showInSnackBarBK(responseJson['message']);
        }
        setState(() {
          isError = true;
          isLoading = false;
        });
      }
    } catch (e, stacktrace) {
      print('Error code : $e || Stacktrace : $stacktrace');
      setState(() {
        isError = true;
        isLoading = false;
      });
    }
  }

  void getTabIndex() {
    setState(() {
      tabIndex = _tabController.index;
    });
  }

  @override
  void initState() {
    isLoading = true;
    isError = false;
    selectedDate = DateTime.now();

    _tabController = TabController(vsync: this, length: 2);
    _tabController.addListener(getTabIndex);

    _noResi = TextEditingController();
    _catatan = TextEditingController();
    _tanggalPengiriman = TextEditingController();

    _catatanFocus = FocusNode();
    _noResiFocus = FocusNode();
    _tanggalPengirimanFocus = FocusNode();

    noReq = widget.ref;
    _form = GlobalKey<FormState>();

    formSerialize = Map();
    getHeaderHTTP();

    super.initState();
  }

  @override
  void deactivate() {
    listController.clear();
    listProduk.clear();
    listFocus.clear();
    super.deactivate();
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
          key: _scaffoldBK,
          backgroundColor: Colors.grey[300],
          appBar: AppBar(
            title: Text('Proses Barang Keluar'),
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: <Widget>[
                Tab(
                  icon: Icon(Icons.add),
                  text: 'Form Barang Keluar',
                ),
                Tab(
                  icon: Icon(Icons.list),
                  text: 'Daftar Produk',
                ),
              ],
            ),
          ),
          body: Form(
            key: _form,
            child: TabBarView(
              controller: _tabController,
              children: <Widget>[
                isLoading == true
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : isError == true
                        ? Center(child: ErrorCobalLagi(
                            onPress: () {
                              prosesBarangKeluar();
                            },
                          ))
                        : Scrollbar(
                            child: SingleChildScrollView(
                              child: Container(
                                child: Card(
                                  child: Container(
                                    padding: EdgeInsets.all(10.0),
                                    child: Column(
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                'No. Reff Barang Keluar',
                                                style: TextStyle(
                                                  fontSize: 16.0,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 5,
                                              child: Text(noReff),
                                            ),
                                          ],
                                        ),
                                        Divider(),
                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                'No. Request Mutasi',
                                                style: TextStyle(
                                                  fontSize: 16.0,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 5,
                                              child: Text(noReq),
                                            ),
                                          ],
                                        ),
                                        Divider(),
                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                'Catatan Pengiriman',
                                                style: TextStyle(
                                                  fontSize: 16.0,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 5,
                                              child: TextFormField(
                                                controller: _catatan,
                                                focusNode: _catatanFocus,
                                                maxLines: 3,
                                                decoration: InputDecoration(
                                                  hintText:
                                                      'Catatan Pengiriman',
                                                ),
                                                onFieldSubmitted: (thisValue) {
                                                  _catatan.text = thisValue;
                                                },
                                                validator: (thisValue) {
                                                  if (thisValue.isEmpty) {
                                                    return 'Catatan tidak boleh kosong';
                                                  }
                                                  return null;
                                                },
                                                onEditingComplete: () {
                                                  FocusScope.of(context)
                                                      .requestFocus(
                                                          _tanggalPengirimanFocus);
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        Divider(),
                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                'Tanggal Pengiriman',
                                                style: TextStyle(
                                                  fontSize: 16.0,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 5,
                                              child: DateTimeField(
                                                focusNode:
                                                    _tanggalPengirimanFocus,
                                                format:
                                                    DateFormat('dd-MM-yyyy'),
                                                initialValue: selectedDate,
                                                readOnly: true,
                                                onShowPicker:
                                                    (context, currentValue) {
                                                  return showDatePicker(
                                                    firstDate: DateTime(
                                                      DateTime.now().year,
                                                    ),
                                                    initialDate: currentValue ??
                                                        DateTime.now(),
                                                    context: context,
                                                    lastDate: DateTime.now(),
                                                  );
                                                },
                                                decoration: InputDecoration(
                                                  hintText:
                                                      'Tanggal Pengiriman',
                                                ),
                                                validator: (thisValue) {
                                                  print(thisValue.toString());
                                                  if (thisValue == null) {
                                                    return 'Tanggal pengiriman tidak boleh kosong';
                                                  }
                                                  return null;
                                                },
                                                onChanged: (ini) {
                                                  setState(() {
                                                    selectedDate = ini;
                                                  });
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        Divider(),
                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                'Nomor Resi',
                                                style: TextStyle(
                                                  fontSize: 16.0,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 5,
                                              child: TextFormField(
                                                controller: _noResi,
                                                decoration: InputDecoration(
                                                  hintText: 'Nomor Resi',
                                                ),
                                                validator: (thisValue) {
                                                  if (thisValue.isEmpty) {
                                                    return 'Nomor resi tidak boleh kosong';
                                                  }
                                                  return null;
                                                },
                                                focusNode: _noResiFocus,
                                                onFieldSubmitted: (thisValue) {
                                                  _noResi.text = thisValue;
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                isLoading == true
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : isError == true
                        ? Center(
                            child: ErrorCobalLagi(
                              onPress: () {
                                prosesBarangKeluar();
                              },
                            ),
                          )
                        : Container(
                            child: Scrollbar(
                              child: ListView.builder(
                                padding: EdgeInsets.only(
                                  bottom: 50.0,
                                ),
                                itemCount: listProduk.length,
                                itemBuilder: (BuildContext context, int i) {
                                  return TileProsesBarangKeluar(
                                    namaProduk: listProduk[i].namaProduk,
                                    gudangDiminta: listProduk[i].gudangDiminta,
                                    gudangPeminta: listProduk[i].gudangPeminta,
                                    jumlahDiminta: listProduk[i].stokDiminta,
                                    satuan: listProduk[i].namaSatuan,
                                    stokGudangDiminta:
                                        listProduk[i].stokGudangDiminta,
                                    controllerJumlahDiminta: listController[i],
                                    focusJumlahDiminta: listFocus[i],
                                    textInputAction: listProduk.length - 1 == i
                                        ? TextInputAction.done
                                        : TextInputAction.next,
                                    onChanged: (thisValue) {
                                      print(thisValue);
                                      int validateValue = int.parse(thisValue);
                                      if (validateValue < 0) {
                                        validateValue = 0;
                                        listController[i].selection =
                                            TextSelection.collapsed(
                                                offset: validateValue
                                                    .toString()
                                                    .length);
                                        // } else if (validateValue >
                                        //     int.parse(
                                        //         listProduk[i].stokDiminta)) {
                                        //   validateValue = int.parse(
                                        //       listProduk[i].stokDiminta);
                                        //   listController[i].selection =
                                        //       TextSelection.collapsed(
                                        //           offset: validateValue
                                        //               .toString()
                                        //               .length);
                                      }

                                      listProduk[i] = Produk(
                                        idRequestMutasi:
                                            listProduk[i].idRequestMutasi,
                                        namaProduk: listProduk[i].namaProduk,
                                        namaSatuan: listProduk[i].namaSatuan,
                                        kodeSatuan: listProduk[i].kodeSatuan,
                                        gudangPeminta:
                                            listProduk[i].gudangPeminta,
                                        idGudangPeminta:
                                            listProduk[i].idGudangPeminta,
                                        idGudangDiminta: widget.idGudang,
                                        gudangDiminta: widget.gudang,
                                        codeProduk: listProduk[i].codeProduk,
                                        stokDiminta: listProduk[i].stokDiminta,
                                        stokGudangDiminta:
                                            listProduk[i].stokGudangDiminta,
                                        stokDisetujui: '$validateValue',
                                      );

                                      listController[i].text = '$validateValue';
                                      listController[i].selection =
                                          TextSelection.collapsed(
                                              offset: validateValue
                                                  .toString()
                                                  .length);
                                    },
                                    onEditingComplete: () {
                                      if (listFocus.length - 1 != i) {
                                        FocusScope.of(context)
                                            .requestFocus(listFocus[i + 1]);
                                      } else {
                                        FocusScope.of(context).unfocus();
                                      }
                                    },
                                    onIncrease: () {
                                      int keTambah;
                                      if (listProduk[i].stokDisetujui == null) {
                                        keTambah = 1;
                                      } else {
                                        keTambah = int.parse(
                                                listProduk[i].stokDisetujui) +
                                            1;
                                      }
                                      // if (keTambah >
                                      //     int.parse(
                                      //         listProduk[i].stokDiminta)) {
                                      //   keTambah = int.parse(
                                      //       listProduk[i].stokDiminta);
                                      // }
                                      // setState(() {
                                      listController[i].text = '$keTambah';
                                      // });
                                      listProduk[i] = Produk(
                                        idRequestMutasi:
                                            listProduk[i].idRequestMutasi,
                                        namaProduk: listProduk[i].namaProduk,
                                        namaSatuan: listProduk[i].namaSatuan,
                                        kodeSatuan: listProduk[i].kodeSatuan,
                                        gudangPeminta:
                                            listProduk[i].gudangPeminta,
                                        idGudangPeminta:
                                            listProduk[i].idGudangPeminta,
                                        idGudangDiminta: widget.idGudang,
                                        gudangDiminta: widget.gudang,
                                        codeProduk: listProduk[i].codeProduk,
                                        stokDiminta: listProduk[i].stokDiminta,
                                        stokGudangDiminta:
                                            listProduk[i].stokGudangDiminta,
                                        stokDisetujui: '$keTambah',
                                      );
                                    },
                                    onDecrease: () {
                                      int keKurang;
                                      if (listProduk[i].stokDisetujui == null) {
                                        keKurang = 1;
                                      } else {
                                        keKurang = int.parse(
                                                listProduk[i].stokDisetujui) -
                                            1;
                                      }

                                      if (keKurang < 0) {
                                        keKurang = 0;
                                      }

                                      // setState(() {
                                      listController[i].text = '$keKurang';
                                      // });
                                      listProduk[i] = Produk(
                                        idRequestMutasi:
                                            listProduk[i].idRequestMutasi,
                                        namaProduk: listProduk[i].namaProduk,
                                        namaSatuan: listProduk[i].namaSatuan,
                                        kodeSatuan: listProduk[i].kodeSatuan,
                                        gudangPeminta:
                                            listProduk[i].gudangPeminta,
                                        idGudangPeminta:
                                            listProduk[i].idGudangPeminta,
                                        idGudangDiminta: widget.idGudang,
                                        gudangDiminta: widget.gudang,
                                        codeProduk: listProduk[i].codeProduk,
                                        stokDiminta: listProduk[i].stokDiminta,
                                        stokGudangDiminta:
                                            listProduk[i].stokGudangDiminta,
                                        stokDisetujui: '$keKurang',
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.check),
            onPressed: () {
              for (int i = 0; i < listProduk.length; i++) {
                if (listProduk[i].stokDisetujui == null ||
                    listProduk[i].stokDisetujui.isEmpty) {
                  showInSnackBarBK('Input jumlah disetujui tidak boleh kosong');
                  _tabController.animateTo(1);
                  _form.currentState.validate();
                  break;
                } else {
                  _tabController.animateTo(0);
                  Future.delayed(
                    Duration(
                      milliseconds: 200,
                    ),
                    () {
                      if (_form.currentState.validate()) {
                        _tabController.animateTo(0);

                        formSerialize['accqty'] = List<String>();
                        formSerialize['catatan'] = null;
                        formSerialize['ciproduct'] = List<String>();
                        formSerialize['gudang'] = null;
                        formSerialize['gudangout'] = List<String>();
                        formSerialize['id'] = List<String>();
                        formSerialize['lstock'] = List<String>();
                        formSerialize['mutasi'] = null;
                        formSerialize['ref'] = null;
                        formSerialize['resi'] = null;
                        formSerialize['satuan'] = List<String>();
                        formSerialize['tanggal'] = null;
                        formSerialize['type_platform'] = null;

                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Apa anda yakin'),
                              content: Text('Data akan disimpan'),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text(
                                    'Tidak',
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                                FlatButton(
                                  child: Text('Ya'),
                                  onPressed: () async {
                                    Map<String, String> requestHeadersPost =
                                        Map();

                                    requestHeadersPost = requestHeaders;

                                    requestHeadersPost['Content-Type'] =
                                        "application/x-www-form-urlencoded";

                                    for (int i = 0;
                                        i < listProduk.length;
                                        i++) {
                                      formSerialize['accqty']
                                          .add(listProduk[i].stokDisetujui);
                                      formSerialize['ciproduct']
                                          .add(listProduk[i].codeProduk);
                                      formSerialize['gudangout']
                                          .add(listProduk[i].idGudangDiminta);
                                      formSerialize['id']
                                          .add(listProduk[i].idRequestMutasi);
                                      formSerialize['lstock']
                                          .add(listProduk[i].stokGudangDiminta);
                                      formSerialize['satuan']
                                          .add(listProduk[i].kodeSatuan);
                                    }

                                    formSerialize['catatan'] = _catatan.text;
                                    formSerialize['gudang'] =
                                        listProduk[0].stokGudangDiminta;
                                    formSerialize['mutasi'] = noReq;
                                    formSerialize['ref'] = noReff;
                                    formSerialize['resi'] = _noResi.text;
                                    formSerialize['tanggal'] =
                                        _tanggalPengiriman.text;
                                    formSerialize['type_platform'] = 'android';

                                    print(formSerialize);
                                    print(
                                        'encoded ${jsonEncode(formSerialize)}');

                                    try {
                                      final response = await http.post(
                                        url('api/simpanBarangKeluar'),
                                        body: {
                                          "type_platform": 'android',
                                          "data": jsonEncode(formSerialize),
                                        },
                                        headers: requestHeadersPost,
                                        encoding: Encoding.getByName("utf-8"),
                                      );
                                      if (response.statusCode == 200) {
                                        dynamic responseJson =
                                            jsonDecode(response.body);

                                        if (responseJson['status'] ==
                                            'sukses') {
                                          showInSnackBarBK(
                                              'Sukses, Data berhasil disimpan');
                                          Navigator.popUntil(
                                              context,
                                              ModalRoute.withName(
                                                  '/barang_keluar'));
                                        } else if (responseJson['status'] ==
                                            'stok kurang') {
                                          showInSnackBarBK('Stok kurang');
                                          Navigator.pop(context);
                                        } else if (responseJson['error'] ==
                                            'Barang Tidak Terdaftar Di Gudang') {
                                          showInSnackBarBK(
                                              responseJson['error']);
                                        } else {
                                          print(responseJson);
                                          showInSnackBarBK(
                                              'Error, Hubungi pengembang aplikasi');
                                          Navigator.pop(context);
                                        }
                                      } else {
                                        print(jsonDecode(response.body));
                                        showInSnackBarBK(
                                            'Error code : ${response.statusCode}');
                                        Map responseJson =
                                            jsonDecode(response.body);

                                        if (responseJson
                                            .containsKey('message')) {
                                          showInSnackBarBK(
                                              responseJson['message']);
                                        }
                                      }
                                    } on TimeoutException catch (_) {
                                      showInSnackBarBK('Timedout, try again');
                                    } catch (e, stacktrace) {
                                      print(
                                          'Error : $e || Stacktrace : $stacktrace');

                                      showInSnackBarBK(
                                          'Error Hubungi pengembang aplikasi');
                                    }
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                  );
                  break;
                }
              }
            },
          ),
        ),
      ),
    );
  }
}
