import 'package:flutter/material.dart';
import 'package:invee2/error/error.dart';
import 'package:invee2/gudang/mutasi/barang_keluar/proses_barang_keluar.dart';
import 'package:invee2/gudang/mutasi/barang_masuk/customTileBarangMasuk.dart';
import 'package:invee2/gudang/mutasi/barang_masuk/model.dart';
import 'package:invee2/gudang/mutasi/barang_masuk/tab_proses_barang_masuk.dart';
import 'package:invee2/localStorage/localStorage.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
// import 'dart:io';

import 'package:invee2/routes/env.dart';

GlobalKey<ScaffoldState> _scaffoldKeyProsesBarangMasuk;
TabController _tabController;

String tokenType, accessToken;
Map<String, String> requestHeaders = Map();

List<Produk> listProduk;
bool isLoading, isError, isSend;

TextEditingController datepickerController;
DateTime selectedDate;

GlobalKey<FormState> _form;
List<TextEditingController> listController;

List<FocusNode> focusNode;
Map<int, List<String>> listInformasiKekurangan;
List<String> listSelectedInformasiKekurangan;

Map<String, dynamic> formSerialize;
FocusNode datepickerFocus;
showInSnackbarBM(String title) {
  _scaffoldKeyProsesBarangMasuk.currentState.showSnackBar(
    SnackBar(
      content: Text(title),
    ),
  );
}

class ProsesBarangMasuk extends StatefulWidget {
  final String reffBarangKeluar,
      reffBarangMasuk,
      resi,
      gudangPengirim,
      tglPengiriman,
      catatanPengiriman;

  ProsesBarangMasuk({
    @required this.catatanPengiriman,
    @required this.gudangPengirim,
    @required this.reffBarangKeluar,
    @required this.reffBarangMasuk,
    @required this.resi,
    @required this.tglPengiriman,
  });

  @override
  _ProsesBarangMasukState createState() => _ProsesBarangMasukState();
}

class _ProsesBarangMasukState extends State<ProsesBarangMasuk>
    with SingleTickerProviderStateMixin {
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

    detailBarangMasukAndroid();
  }

  Future<Null> detailBarangMasukAndroid() async {
    setState(() {
      isLoading = true;
      isError = false;
    });
    try {
      final response = await http.post(
        url('api/detailBarangMasukAndroid'),
        headers: requestHeaders,
        body: {
          'ref': widget.reffBarangMasuk,
        },
      );

      if (response.statusCode == 200) {
        dynamic responseJson = jsonDecode(response.body);

        // if (responseJson['error'] == 'Unauthenticated') {
        //   showInSnackbarBM(
        //       'Token kedaluwarsa, silahkan logout dan login kembali');
        // }

        print(responseJson);

        listProduk = List<Produk>();
        listController = List<TextEditingController>();
        listFocus = List<FocusNode>();
        listSelectedInformasiKekurangan = List<String>();
        listInformasiKekurangan = Map<int, List<String>>();

        for (int i = 0; i < responseJson.length; i++) {
          TextEditingController controller = TextEditingController();
          listController.add(controller);

          FocusNode focusNode = FocusNode();
          listFocus.add(focusNode);

          listSelectedInformasiKekurangan.add('(Belum ada)');

          listInformasiKekurangan[i] = List<String>();

          listInformasiKekurangan[i].add('(Belum ada)');

          listProduk.add(
            Produk(
              idGudangPeminta: responseJson[i]['rm_cwhouse'],
              kodeProduk: responseJson[i]['i_code'],
              namaProduk: responseJson[i]['i_name'],
              idSatuan: responseJson[i]['iu_code'],
              namaSatuan: responseJson[i]['iu_name'],
              namaGudangPeminta: responseJson[i]['w_name'],
              jumlahDisetujui: "${responseJson[i]['om_qtyconfirm']}",
              stokGudang: "${responseJson[i]['rm_laststock']}",
              jumlahDiterima: "${responseJson[i]['im_instock']}",
              informasiKekurangan: responseJson[i]['im_lessinfo'],
              jumlahDiminta: "${responseJson[i]['rm_requestqty']}",
              idGudangDiminta: responseJson[i]['rm_whouseout'],
              idMutasiBarangKeluar: responseJson[i]['om_id'].toString(),
              idRequestMutasi: responseJson[i]['rm_id'].toString(),
            ),
          );
        }

        setState(() {
          isLoading = false;
          isError = false;
        });
      } else {
        showInSnackbarBM('Error Code: ${response.statusCode}');
        Map responseJson = jsonDecode(response.body);

        if(responseJson.containsKey('message')){
          showInSnackbarBM(responseJson['message']);
        }
        print('print response.body ${jsonDecode(response.body)}');
        setState(() {
          isLoading = false;
          isError = true;
        });
      }
    } on TimeoutException catch (_) {
      showInSnackbarBM('Timedout, try again');
      setState(() {
        isLoading = false;
        isError = true;
      });
    } catch (e, stacktrace) {
      print('Error : $e || Stactrace : $stacktrace');
      showInSnackbarBM('Error Hubungi Pengembang Aplikasi');
      setState(() {
        isLoading = false;
        isError = true;
      });
    }
  }

  @override
  void initState() {
    isLoading = true;
    isError = false;

    _tabController = TabController(vsync: this, length: 2);
    _scaffoldKeyProsesBarangMasuk = GlobalKey<ScaffoldState>();

    getHeaderHTTP();
    datepickerController = TextEditingController();

    _form = GlobalKey<FormState>();
    listInformasiKekurangan = Map<int, List<String>>();

    selectedDate = null;
    datepickerFocus = FocusNode();

    isSend = false;
    super.initState();
  }

  @override
  void deactivate() {
    listController.clear();
    listFocus.clear();
    listInformasiKekurangan.clear();
    listProduk.clear();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: _scaffoldKeyProsesBarangMasuk,
        backgroundColor: Colors.grey[300],
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.check),
          onPressed: isSend == true
              ? null
              : () {
                  for (int i = 0; i < listController.length; i++) {
                    if (listController[i].text.isEmpty) {
                      showInSnackbarBM(
                          'Input jumlah terima barang tidak boleh kosong');
                      _tabController.animateTo(1);
                      break;
                    } else {
                      _tabController.animateTo(0);
                      Future.delayed(
                        Duration(milliseconds: 300),
                        () {
                          if (_form.currentState.validate()) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Apa anda yakin?'),
                                  content: Text('Data akan disimpan'),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: Text(
                                        'Tidak',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                    FlatButton(
                                      child: Text('Ya'),
                                      onPressed: () async {
                                        // Navigator.pop(context);
                                        
                                        formSerialize = Map<String, dynamic>();
                                        formSerialize['no_ref'] = null;
                                        formSerialize['no_pengiriman'] = null;
                                        // formSerialize['id'] = null;
                                        formSerialize['datein'] = null;
                                        formSerialize['id_produk'] = List();
                                        formSerialize['om_id'] = List();
                                        formSerialize['rm_id'] = List();
                                        formSerialize['gudangout'] = List();
                                        formSerialize['id_satuan'] = List();
                                        formSerialize['id_gudang'] = List();
                                        formSerialize['stok_gudang'] = List();
                                        formSerialize['qty_dikirim'] = List();
                                        formSerialize['qty_diterima'] = List();
                                        formSerialize['qty_kurang'] = List();
                                        formSerialize['info_kekurangan'] =
                                            List();

                                        formSerialize['no_ref'] =
                                            widget.reffBarangMasuk;
                                        formSerialize['no_pengiriman'] =
                                            widget.resi;
                                        formSerialize['datein'] =
                                            selectedDate.toString();

                                        for (int i = 0;
                                            i < listProduk.length;
                                            i++) {
                                          formSerialize['id_produk']
                                              .add(listProduk[i].kodeProduk);
                                          formSerialize['id_satuan']
                                              .add(listProduk[i].idSatuan);
                                          formSerialize['id_gudang'].add(
                                              listProduk[i].idGudangPeminta);
                                          formSerialize['stok_gudang']
                                              .add(listProduk[i].stokGudang);
                                          formSerialize['qty_dikirim'].add(
                                              listProduk[i].jumlahDisetujui);
                                          formSerialize['qty_diterima'].add(
                                              listProduk[i].jumlahDiterima);
                                          formSerialize['qty_kurang'].add(
                                              int.parse(
                                                      listProduk[i]
                                                          .jumlahDisetujui) -
                                                  int.parse(listProduk[i]
                                                      .jumlahDiterima));
                                          formSerialize['info_kekurangan'].add(
                                              listSelectedInformasiKekurangan[
                                                  i]);
                                          formSerialize['om_id'].add(
                                              listProduk[i]
                                                  .idMutasiBarangKeluar);
                                          formSerialize['rm_id'].add(
                                              listProduk[i].idRequestMutasi);
                                          formSerialize['gudangout'].add(
                                              listProduk[i].idGudangDiminta);
                                        }

                                        print(formSerialize);

                                        Map<String, dynamic> requestHeadersX =
                                            requestHeaders;

                                        requestHeadersX['Content-Type'] =
                                            "application/x-www-form-urlencoded";
                                        try {
                                          setState(() {
                                            isSend = true;
                                          });
                                          final response = await http.post(
                                            url('api/simpanBarangMasuk'),
                                            headers: requestHeadersX,
                                            body: {
                                              'type_platform': 'android',
                                              'data': jsonEncode(formSerialize),
                                            },
                                            encoding:
                                                Encoding.getByName("utf-8"),
                                          );

                                          if (response.statusCode == 200) {
                                            setState(() {
                                              isSend = false;
                                            });
                                            dynamic responseJson =
                                                jsonDecode(response.body);

                                            // if (responseJson['error'] ==
                                            //     'Unauthenticated') {
                                            //   showInSnackbarBM(
                                            //       'Token kedaluwarsa, silahkan logout dan login kembali');
                                            // }
                                            if (responseJson['status'] ==
                                                'sukses') {
                                              Navigator.popUntil(
                                                context,
                                                ModalRoute.withName(
                                                    '/barang_masuk'),
                                              );
                                            }
                                            print(
                                                'response decoded $responseJson');
                                          } else if (response.statusCode ==
                                              401) {
                                            showInSnackbarBM(
                                                'Token kedaluwarsa, silahkan logout dan login kembali');
                                            setState(() {
                                              isSend = false;
                                            });
                                          } else {
                                            setState(() {
                                              isSend = false;
                                            });
                                            showInSnackbarBM(
                                                'Error Code : ${response.statusCode}');
                                            print(jsonDecode(response.body));
                                          }
                                        } on TimeoutException catch (_) {
                                          setState(() {
                                            isSend = false;
                                          });
                                          showInSnackbarBM(
                                              'Timeout, try again');
                                        } catch (e, stacktrace) {
                                          setState(() {
                                            isSend = false;
                                          });
                                          print(
                                              'Error : $e || StackTrace : $stacktrace');
                                          showInSnackbarBM(
                                              'Error, Hubungi pengembang aplikasi');
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
        appBar: AppBar(
          title: Text('Proses Barang Masuk'),
          bottom: TabBar(
            isScrollable: true,
            controller: _tabController,
            tabs: <Widget>[
              Tab(
                icon: Icon(Icons.input),
                text: 'Detail Barang Masuk',
              ),
              Tab(
                icon: Icon(Icons.list),
                text: 'Daftar Barang Masuk',
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
                      ? ErrorCobalLagi(
                          onPress: detailBarangMasukAndroid,
                        )
                      : TabProsesBarangMasuk(
                          datepickerFocus: datepickerFocus,
                          catatan: widget.catatanPengiriman,
                          gudangPengirim: widget.gudangPengirim,
                          noResi: widget.resi,
                          reffBarangKeluar: widget.reffBarangKeluar,
                          reffBarangMasuk: widget.reffBarangMasuk,
                          tanggalPengiriman: widget.tglPengiriman,
                          datePickerController: datepickerController,
                          initialValue: selectedDate,
                          onChanged: (ini) {
                            print(ini);
                            setState(() {
                              selectedDate = ini;
                              // datepickerController.text = ini.toString();
                            });
                          },
                        ),
              isLoading == true
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : isError == true
                      ? ErrorCobalLagi(
                          onPress: detailBarangMasukAndroid,
                        )
                      : Scrollbar(
                          child: ListView.builder(
                            itemCount: listProduk.length,
                            itemBuilder: (BuildContext context, int i) {
                              if (listProduk[i].jumlahDiterima == 'null' ||
                                  listProduk[i].jumlahDiterima.isEmpty) {
                                listProduk[i].jumlahDiterima = '0';
                                listSelectedInformasiKekurangan[i] =
                                    '(Belum ada)';
                              }

                              int hitungKurang;

                              if (listProduk[i].jumlahDiterima != 'null' ||
                                  listProduk[i].jumlahDiterima.isNotEmpty) {
                                hitungKurang =
                                    int.parse(listProduk[i].jumlahDisetujui) -
                                        int.parse(listProduk[i].jumlahDiterima);
                              }

                              return TileProsesBarangMasuk(
                                namaProduk: listProduk[i].namaProduk,
                                gudangPeminta: listProduk[i].namaGudangPeminta,
                                namaSatuan: listProduk[i].namaSatuan,
                                jumlahDisetujui: listProduk[i].jumlahDisetujui,
                                // jumlahDiterima:
                                //     listProduk[i].jumlahDiterima != 'null'
                                //         ? listProduk[i].jumlahDiterima
                                //         : '0',
                                kurang: listProduk[i].jumlahDiterima != 'null'
                                    ? hitungKurang.toString()
                                    : listProduk[i].jumlahDisetujui,
                                stokGudang: listProduk[i].stokGudang,
                                jumlahDiminta: listProduk[i].jumlahDiminta,
                                informasiKekurangan:
                                    listSelectedInformasiKekurangan[i],
                                controllerJumlahDiterima: listController[i],
                                focusJumlahDiterima: listFocus[i],
                                textInputAction: listProduk.length - 1 == i
                                    ? TextInputAction.done
                                    : TextInputAction.next,
                                inputOnChanged: (thisValue) {
                                  if (thisValue.isEmpty) {
                                    thisValue = 0.toString();
                                  }
                                  // if (listSelectedInformasiKekurangan.isEmpty) {
                                  //   listInformasiKekurangan.clear();
                                  //   listInformasiKekurangan.add('(Belum ada)');
                                  //   listSelectedInformasiKekurangan = '(Belum ada)';
                                  // }

                                  listController[i].text = thisValue;

                                  listProduk[i] = Produk(
                                    idGudangPeminta:
                                        listProduk[i].idGudangPeminta,
                                    idSatuan: listProduk[i].idSatuan,
                                    namaProduk: listProduk[i].namaProduk,
                                    kodeProduk: listProduk[i].kodeProduk,
                                    jumlahDisetujui:
                                        listProduk[i].jumlahDisetujui,
                                    jumlahDiterima: thisValue,
                                    namaGudangPeminta:
                                        listProduk[i].namaGudangPeminta,
                                    namaSatuan: listProduk[i].namaSatuan,
                                    stokGudang: listProduk[i].stokGudang,
                                    jumlahDiminta: listProduk[i].jumlahDiminta,
                                    informasiKekurangan:
                                        listSelectedInformasiKekurangan[i],
                                    idGudangDiminta:
                                        listProduk[i].idGudangDiminta,
                                    idMutasiBarangKeluar:
                                        listProduk[i].idMutasiBarangKeluar,
                                    idRequestMutasi:
                                        listProduk[i].idRequestMutasi,
                                  );

                                  if (int.parse(listProduk[i].jumlahDisetujui) <
                                          int.parse(listController[i].text) ||
                                      int.parse(listProduk[i].jumlahDisetujui) >
                                          int.parse(listController[i].text)) {
                                    setState(() {
                                      listInformasiKekurangan[i].clear();
                                      listInformasiKekurangan[i].add('hilang');
                                      listInformasiKekurangan[i].add('rusak');
                                      listInformasiKekurangan[i]
                                          .add('Kesalahan Pengirim');
                                      listSelectedInformasiKekurangan[i] =
                                          'hilang';
                                    });
                                  } else if (int.parse(
                                          listProduk[i].jumlahDisetujui) ==
                                      int.parse(listController[i].text)) {
                                    setState(() {
                                      listInformasiKekurangan[i].clear();
                                      listInformasiKekurangan[i]
                                          .add('Tidak ada kekurangan');
                                      listSelectedInformasiKekurangan[i] =
                                          'Tidak ada kekurangan';
                                    });
                                  }

                                  listController[i].selection =
                                      TextSelection.collapsed(
                                          offset: thisValue.length);
                                },
                                dropDownButton: DropdownButton(
                                  isExpanded: true,
                                  value: listSelectedInformasiKekurangan[i],
                                  onChanged: (thisValue) {
                                    setState(() {
                                      listSelectedInformasiKekurangan[i] =
                                          thisValue;
                                    });
                                  },
                                  items: listInformasiKekurangan[i]
                                      .map(
                                        (f) => DropdownMenuItem(
                                          child: Text(f),
                                          value: f,
                                        ),
                                      )
                                      .toList(),
                                ),
                                onChangedDropDown: (thisValue) {
                                  setState(() {
                                    listSelectedInformasiKekurangan[i] =
                                        thisValue;
                                    listProduk[i] = Produk(
                                      idGudangPeminta:
                                          listProduk[i].idGudangPeminta,
                                      idSatuan: listProduk[i].idSatuan,
                                      namaProduk: listProduk[i].namaProduk,
                                      kodeProduk: listProduk[i].kodeProduk,
                                      jumlahDisetujui:
                                          listProduk[i].jumlahDisetujui,
                                      jumlahDiterima: listController[i].text,
                                      namaGudangPeminta:
                                          listProduk[i].namaGudangPeminta,
                                      namaSatuan: listProduk[i].namaSatuan,
                                      stokGudang: listProduk[i].stokGudang,
                                      jumlahDiminta:
                                          listProduk[i].jumlahDiminta,
                                      informasiKekurangan: thisValue,
                                      idGudangDiminta:
                                          listProduk[i].idGudangDiminta,
                                      idMutasiBarangKeluar:
                                          listProduk[i].idMutasiBarangKeluar,
                                      idRequestMutasi:
                                          listProduk[i].idRequestMutasi,
                                    );
                                  });
                                },
                                onDecrease: () {
                                  print(listController[i].text);

                                  if (listController[i].text.isEmpty ||
                                      listController[i].text == '') {
                                    setState(() {
                                      listController[i].text = '0';
                                    });
                                  }

                                  String jumlahDiterima;

                                  if (listProduk[i].jumlahDiterima == 'null' ||
                                      listProduk[i].jumlahDiterima.isEmpty) {
                                    jumlahDiterima = '0';
                                  } else {
                                    jumlahDiterima = listController[i].text;
                                  }

                                  int diKurang = int.parse(jumlahDiterima) - 1;

                                  setState(() {
                                    listController[i].text =
                                        diKurang.toString();
                                    listProduk[i] = Produk(
                                      idGudangPeminta:
                                          listProduk[i].idGudangPeminta,
                                      idSatuan: listProduk[i].idSatuan,
                                      namaProduk: listProduk[i].namaProduk,
                                      kodeProduk: listProduk[i].kodeProduk,
                                      jumlahDisetujui:
                                          listProduk[i].jumlahDisetujui,
                                      jumlahDiterima: diKurang.toString(),
                                      namaGudangPeminta:
                                          listProduk[i].namaGudangPeminta,
                                      namaSatuan: listProduk[i].namaSatuan,
                                      stokGudang: listProduk[i].stokGudang,
                                      jumlahDiminta:
                                          listProduk[i].jumlahDiminta,
                                      informasiKekurangan:
                                          listSelectedInformasiKekurangan[i],
                                      idGudangDiminta:
                                          listProduk[i].idGudangDiminta,
                                      idMutasiBarangKeluar:
                                          listProduk[i].idMutasiBarangKeluar,
                                      idRequestMutasi:
                                          listProduk[i].idRequestMutasi,
                                    );
                                  });

                                  if (int.parse(listProduk[i].jumlahDisetujui) <
                                          int.parse(listController[i].text) ||
                                      int.parse(listProduk[i].jumlahDisetujui) >
                                          int.parse(listController[i].text)) {
                                    setState(() {
                                      listInformasiKekurangan[i].clear();
                                      listInformasiKekurangan[i].add('hilang');
                                      listInformasiKekurangan[i].add('rusak');
                                      listInformasiKekurangan[i]
                                          .add('Kesalahan Pengirim');
                                      listSelectedInformasiKekurangan[i] =
                                          'hilang';
                                    });
                                  } else if (int.parse(
                                          listProduk[i].jumlahDisetujui) ==
                                      int.parse(listController[i].text)) {
                                    setState(() {
                                      listInformasiKekurangan[i].clear();
                                      listInformasiKekurangan[i]
                                          .add('Tidak ada kekurangan');
                                      listSelectedInformasiKekurangan[i] =
                                          'Tidak ada kekurangan';
                                    });
                                  }
                                },
                                onIncrease: () {
                                  print(listController[i].text);

                                  if (listController[i].text.isEmpty) {
                                    setState(() {
                                      listController[i].text = '0';
                                      listInformasiKekurangan[i].clear();
                                      listInformasiKekurangan[i]
                                          .add('(Belum ada)');
                                      listSelectedInformasiKekurangan[i] =
                                          '(Belum ada)';
                                    });
                                  }

                                  String jumlahDiterima;

                                  if (listProduk[i].jumlahDiterima == 'null' ||
                                      listProduk[i].jumlahDiterima.isEmpty) {
                                    jumlahDiterima = '0';
                                  } else {
                                    jumlahDiterima = listController[i].text;
                                  }

                                  int diTambah = int.parse(jumlahDiterima) + 1;

                                  setState(() {
                                    listController[i].text =
                                        diTambah.toString();
                                    listProduk[i] = Produk(
                                      idGudangPeminta:
                                          listProduk[i].idGudangPeminta,
                                      idSatuan: listProduk[i].idSatuan,
                                      namaProduk: listProduk[i].namaProduk,
                                      kodeProduk: listProduk[i].kodeProduk,
                                      jumlahDisetujui:
                                          listProduk[i].jumlahDisetujui,
                                      jumlahDiterima: diTambah.toString(),
                                      namaGudangPeminta:
                                          listProduk[i].namaGudangPeminta,
                                      namaSatuan: listProduk[i].namaSatuan,
                                      stokGudang: listProduk[i].stokGudang,
                                      jumlahDiminta:
                                          listProduk[i].jumlahDiminta,
                                      informasiKekurangan:
                                          listSelectedInformasiKekurangan[i],
                                      idGudangDiminta:
                                          listProduk[i].idGudangDiminta,
                                      idMutasiBarangKeluar:
                                          listProduk[i].idMutasiBarangKeluar,
                                      idRequestMutasi:
                                          listProduk[i].idRequestMutasi,
                                    );
                                  });

                                  if (int.parse(listProduk[i].jumlahDisetujui) <
                                          int.parse(listController[i].text) ||
                                      int.parse(listProduk[i].jumlahDisetujui) >
                                          int.parse(listController[i].text)) {
                                    setState(() {
                                      listInformasiKekurangan[i].clear();
                                      listInformasiKekurangan[i].add('hilang');
                                      listInformasiKekurangan[i].add('rusak');
                                      listInformasiKekurangan[i]
                                          .add('Kesalahan Pengirim');
                                      listSelectedInformasiKekurangan[i] =
                                          'hilang';
                                    });
                                  } else if (int.parse(
                                          listProduk[i].jumlahDisetujui) ==
                                      int.parse(listController[i].text)) {
                                    setState(() {
                                      listInformasiKekurangan[i].clear();
                                      listInformasiKekurangan[i]
                                          .add('Tidak ada kekurangan');
                                      listSelectedInformasiKekurangan[i] =
                                          'Tidak ada kekurangan';
                                    });
                                  }
                                },
                                onEditingComplete: () {
                                  if (listController[i].text.isEmpty ||
                                      listController[i].text == '') {
                                    listController[i].text = '0';

                                    setState(() {
                                      listInformasiKekurangan[i].clear();
                                      listInformasiKekurangan[i]
                                          .add('(Belum ada)');
                                      listSelectedInformasiKekurangan[i] =
                                          '(Belum ada)';
                                    });
                                  }

                                  if (listFocus.length - 1 != i) {
                                    FocusScope.of(context)
                                        .requestFocus(listFocus[i + 1]);
                                  } else {
                                    FocusScope.of(context).unfocus();
                                  }

                                  setState(() {
                                    listController[i].text =
                                        listController[i].text;

                                    listProduk[i] = Produk(
                                      idGudangPeminta:
                                          listProduk[i].idGudangPeminta,
                                      idSatuan: listProduk[i].idSatuan,
                                      namaProduk: listProduk[i].namaProduk,
                                      kodeProduk: listProduk[i].kodeProduk,
                                      jumlahDisetujui:
                                          listProduk[i].jumlahDisetujui,
                                      jumlahDiterima: listController[i].text,
                                      namaGudangPeminta:
                                          listProduk[i].namaGudangPeminta,
                                      namaSatuan: listProduk[i].namaSatuan,
                                      stokGudang: listProduk[i].stokGudang,
                                      jumlahDiminta:
                                          listProduk[i].jumlahDiminta,
                                      informasiKekurangan:
                                          listSelectedInformasiKekurangan[i],
                                      idGudangDiminta:
                                          listProduk[i].idGudangDiminta,
                                      idMutasiBarangKeluar:
                                          listProduk[i].idMutasiBarangKeluar,
                                      idRequestMutasi:
                                          listProduk[i].idRequestMutasi,
                                    );
                                  });

                                  if (int.parse(listProduk[i].jumlahDisetujui) <
                                          int.parse(listController[i].text) ||
                                      int.parse(listProduk[i].jumlahDisetujui) >
                                          int.parse(listController[i].text)) {
                                    setState(() {
                                      listInformasiKekurangan[i].clear();
                                      listInformasiKekurangan[i].add('hilang');
                                      listInformasiKekurangan[i].add('rusak');
                                      listInformasiKekurangan[i]
                                          .add('Kesalahan Pengirim');
                                      listSelectedInformasiKekurangan[i] =
                                          'hilang';
                                    });
                                  } else if (int.parse(
                                          listProduk[i].jumlahDisetujui) ==
                                      int.parse(listController[i].text)) {
                                    setState(() {
                                      listInformasiKekurangan[i].clear();
                                      listInformasiKekurangan[i]
                                          .add('Tidak ada kekurangan');
                                      listSelectedInformasiKekurangan[i] =
                                          'Tidak ada kekurangan';
                                    });
                                  }
                                },
                              );
                            },
                          ),
                        ),
            ],
          ),
        ),
      ),
    );
  }
}
