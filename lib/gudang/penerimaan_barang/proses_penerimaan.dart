import 'package:flutter/material.dart';
// import 'package:invee2/gudang/penerimaan_barang/tab_daftar_proses.dart';
import 'package:invee2/gudang/penerimaan_barang/tab_detail.dart';
import 'package:invee2/gudang/penerimaan_barang/model.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:invee2/localStorage/localStorage.dart';
import 'package:invee2/routes/env.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';

GlobalKey<FormState> _form = GlobalKey<FormState>();
TextEditingController password;
GlobalKey<ScaffoldState> _scaffoldKeyZ = new GlobalKey<ScaffoldState>();
String tokenType, accessToken;
Map<String, String> requestHeaders = Map();
bool isLoading, isError;

class ProsesPenerimaanBarangSupplier extends StatefulWidget {
  final String id, nota, tglTerima, tglRencana, staff, notaPlan, status;
  final List list;
  ProsesPenerimaanBarangSupplier({
    @required this.status,
    @required this.nota,
    @required this.list,
    @required this.id,
    @required this.tglTerima,
    @required this.tglRencana,
    @required this.staff,
    @required this.notaPlan,
  });
  @override
  _ProsesPenerimaanBarangSupplierState createState() =>
      _ProsesPenerimaanBarangSupplierState();
}

class _ProsesPenerimaanBarangSupplierState
    extends State<ProsesPenerimaanBarangSupplier>
    with SingleTickerProviderStateMixin {
  void showInSnackBar(String value, {SnackBarAction action}) {
    _scaffoldKeyZ.currentState.showSnackBar(new SnackBar(
      content: new Text(value),
      action: action,
    ));
  }

  Future<Null> getHeaderHTTP() async {
    detailPenerimaanBarangSupplierAndroid();
  }

  Future<void> detailPenerimaanBarangSupplierAndroid() async {
    var storage = new DataStore();

    var tokenTypeStorage = await storage.getDataString('token_type');
    var accessTokenStorage = await storage.getDataString('access_token');

    tokenType = tokenTypeStorage;
    accessToken = accessTokenStorage;

    requestHeaders['Accept'] = 'application/json';
    requestHeaders['Authorization'] = '$tokenType $accessToken';
    print(requestHeaders);
    setState(() {
      isLoading = true;
    });

    try {
      final nota = await http.post(
          url('api/detailPenerimaanBarangSupplierAndroid'),
          headers: requestHeaders,
          body: {
            'nomor_po': widget.nota,
            'detail': 'T',
          });

      if (nota.statusCode == 200) {
        print(nota);
        var notaJson = json.decode(nota.body);

        // print('notaJson $notaJson');

        listNotaPO = [];
        inputQtyTerimaList = [];

        for (var i in notaJson['listitem']) {
          int qtyAsli = i['pp_quantity'] - i['pp_accstock'];

          ListProduk notax = ListProduk(
            idGudang: "${i['pp_cwhouse']}",
            idNotaRencana: "${i['pp_id']}",
            idSatuan: "${i['iu_code']}",
            kodeSupplier: i['pp_csupplier'],
            notaRencana: i['pp_code'],
            kodeProduk: i['pp_ciproduct'],
            supplier: i['s_name'],
            namaBarang: i['i_name'],
            satuan: i['iu_name'],
            hargaSatuan: i['pp_price'],
            hargaTotal: i['pp_total'],
            qty: "${i['pp_quantity']}",
            qtyTerima: "${i['pp_accstock']}",
            qtySisa: "$qtyAsli",
          );
          listNotaPO.add(notax);
          
          TextEditingController inputQtyTerima = new TextEditingController(
              // text: listNotaPO[i].qtyTerima,
              );
          inputQtyTerimaList.add(inputQtyTerima);

          FocusNode focusInputQtyTerima = new FocusNode();
          focusInputQtyTerimaList.add(focusInputQtyTerima);

        }
        
        setState(() {
          isLoading = false;
        });
        print('fututer func');
      } else if (nota.statusCode == 401) {
        showInSnackBar('Token kedaluwarsa, silahkan logout dan login kembali');
        setState(() {
          isLoading = false;
        });
      } else {
        showInSnackBar('Request failed with status: ${nota.statusCode}');
        Map responseJson = jsonDecode(nota.body);

        if(responseJson.containsKey('message')){
          showInSnackBar(responseJson['message']);
        }
        setState(() {
          isLoading = false;
        });
        return null;
      }
    } on TimeoutException catch (_) {
      showInSnackBar('Timed out, Try again');
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint('$e');
      setState(() {
        isLoading = false;
      });
    }
    return null;
  }

//  Validasi konfirmasi password
  konfirmValidasi() {
    GlobalKey<FormState> _passwordForm = GlobalKey<FormState>();
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: AlertDialog(
            title: Text('Masukkan Password'),
            content: Form(
              key: _passwordForm,
              child: TextFormField(
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password',
                ),
                controller: password,
                validator: (thisValue) {
                  if (thisValue.isEmpty) {
                    return 'Password tidak boleh kosong!';
                  }
                  return null;
                },
                onSaved: (thisValue) {
                  setState(() {
                    password.text = thisValue;
                    qtyTerima['password'] = thisValue;
                    password.selection =
                        TextSelection.collapsed(offset: thisValue.length);
                  });
                },
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Simpan'),
                onPressed: () {
                  print(qtyTerima);
                  if (_passwordForm.currentState.validate()) {
                    _passwordForm.currentState.save();
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: Text('Apa anda yakin?'),
                        content: Text('Data akan disimpan'),
                        actions: <Widget>[
                          FlatButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Tidak',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          FlatButton(
                            child: Text('Ya'),
                            onPressed: () {
                              print(qtyTerima);
                              simpanPenerimaanBarang();
                            },
                          ),
                        ],
                      ),
                    );
                  } else {
                    return null;
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

//  function simpanPenerimaanBarang
  simpanPenerimaanBarang() async {
    //  qtyTerima = form serialize
    qtyTerima['qty_terima'] = [];
    qtyTerima['ciproduct'] = [];
    qtyTerima['code'] = [];
    qtyTerima['nomor_po'] = [];
    qtyTerima['gudang'] = [];
    qtyTerima['satuan'] = [];
    qtyTerima['supplier'] = [];
    qtyTerima['sisa'] = [];
    qtyTerima['total_stock'] = [];
    qtyTerima['total'] = [];
    qtyTerima['id'] = [];
    for (var i = 0; i < listNotaPO.length; i++) {
      qtyTerima['qty_terima'].add(int.parse(listNotaPO[i].qtyTerimaInput));
      qtyTerima['ciproduct'].add(listNotaPO[i].kodeProduk);
      qtyTerima['code'].add(listNotaPO[i].notaRencana);
      qtyTerima['gudang'].add(listNotaPO[i].idGudang);
      qtyTerima['satuan'].add(listNotaPO[i].idSatuan);
      qtyTerima['supplier'].add(listNotaPO[i].kodeSupplier);
      qtyTerima['sisa'].add(int.parse(listNotaPO[i].qtyTerima));
      qtyTerima['total_stock'].add(int.parse(listNotaPO[i].qty));
      qtyTerima['total'].add(listNotaPO[i].hargaTotal);
      qtyTerima['id'].add(listNotaPO[i].idNotaRencana);
    }
    qtyTerima['nomor_po'] = widget.nota;

    try {
      // final penerimaanBarang = await http.post(
      //   url('api/simpanPenerimaanBarang'),
      //   body: json.encode(request),
      //   headers: requestHeaders,
      // );

      print(requestHeaders);

      Dio dio = new Dio();

      Response penerimaanBarang = await dio.post(
        url('api/simpanPenerimaanBarang'),
        options: Options(
          headers: requestHeaders,
        ),
        data: qtyTerima,
      );

      if (penerimaanBarang.statusCode == 200) {
        dynamic penerimaanBarangJson = penerimaanBarang.data;
        print("from response $penerimaanBarangJson, ${penerimaanBarang.data}");

        if (penerimaanBarangJson['status'] == 'sukses') {
          showInSnackBar('Data Berhasil disimpan');
          Navigator.popUntil(
              context, ModalRoute.withName('/penerimaan_barang'));
        } else if (penerimaanBarangJson['status'] == 'gagal') {
          showInSnackBar('Data gagal disimpan, hubungi pengembang aplikasi');
        } else if (penerimaanBarangJson['error'] ==
            'Barang input melebihi Barang order') {
          showInSnackBar(
              'Input terima melebihi jumlah order pembelian/sisa order pembelian');
          Navigator.popUntil(
              context, ModalRoute.withName('/proses_penerimaan_barang'));
        } else {
          print(penerimaanBarangJson);
        }
        print(penerimaanBarangJson);
      } else {
        showInSnackBar('Error Code : ${penerimaanBarang.statusCode}');
      }
    } on TimeoutException catch (_) {
      showInSnackBar('Timed out, try again');
    } on SocketException catch (_) {
      showInSnackBar('Hosting not found');
    } on DioError catch (e) {
      print(e);
    } catch (e) {
      print(e);
    }
  }

//  function cek floatingButton pindah tab ke index 0
  Widget _floatingButtonToDaftarProdukTab(tabIndex) {
    print(tabIndex);
    if (tabIndex == 1) {
      return FloatingActionButton(
        child: Icon(Icons.check),
        onPressed: () {
          _tabController.animateTo(1);
          konfirmValidasi();
        },
      );
    } else if (tabIndex == 0) {
      return FloatingActionButton(
        child: Icon(Icons.list),
        onPressed: () {
          _tabController.animateTo(1);
        },
      );
    }
    return Icon(Icons.close);
  }

//  tabController untuk mendapatkan index tab
  TabController _tabController;
  int _tabControllerIndex = 0;
  void _getCurrentTab() {
    setState(() {
      _tabControllerIndex = _tabController.index;
    });
  }

//  initState() Class ProsesPenerimaanBarangSupplier
  @override
  void initState() {
    isLoading = false;
    isError = false;
    getHeaderHTTP();
    qtyTerima['password'] = '';
    _tabController = new TabController(vsync: this, length: 2);
    _tabController.addListener(_getCurrentTab);
    password = new TextEditingController();

    print(listNotaPO);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          key: _scaffoldKeyZ,
          floatingActionButton:
              _floatingButtonToDaftarProdukTab(_tabControllerIndex),
          backgroundColor: Colors.grey[300],
          appBar: AppBar(
            title: Text('Proses Penerimaan Barang dari Supplier'),
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: <Widget>[
                Tab(
                  icon: Icon(Icons.person),
                  text: 'Detail Order Pembelian',
                ),
                Tab(
                  icon: Icon(Icons.list),
                  text: 'Daftar Produk Order',
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: <Widget>[
              TabDetail(
                status: widget.status,
                nota: widget.nota,
                id: widget.id,
                notaPlan: widget.notaPlan,
                staff: widget.staff,
                tglRencana: widget.tglRencana,
                tglTerima: widget.tglTerima,
              ),
              isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : TabDaftarProses(
                      form: _form,
                      nota: widget.nota,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class TabDaftarProses extends StatefulWidget {
  final String nota;
  final GlobalKey<FormState> form;
  TabDaftarProses({
    @required this.form,
    @required this.nota,
  });
  @override
  _TabDaftarProsesState createState() => _TabDaftarProsesState();
}

class _TabDaftarProsesState extends State<TabDaftarProses> {
//  initState() Class TabDaftarProsesState
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // print(inputQtyTerimaList);
    return Scrollbar(
      child: Form(
        autovalidate: true,
        key: widget.form,
        child: ListView.builder(
          addAutomaticKeepAlives: true,
          itemCount: listNotaPO.length,
          itemBuilder: (BuildContext context, int i) {
            double getHargaSatuan = double.parse(listNotaPO[i].hargaSatuan);
            double getHargaTotal = double.parse(listNotaPO[i].hargaTotal);

            NumberFormat _numberFormat =
                new NumberFormat.simpleCurrency(decimalDigits: 2, name: 'Rp. ');
            String hargaSatuan = _numberFormat.format(getHargaSatuan);
            String hargaTotal = _numberFormat.format(getHargaTotal);

            // print(i);
            return Card(
              child: Container(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 3,
                            child: Text(
                              'Nama Produk',
                              style: TextStyle(fontSize: 15.0),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Text(
                              listNotaPO[i].namaBarang,
                              style: TextStyle(
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(),
                    Container(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 3,
                            child: Text(
                              'Nama Supplier',
                              style: TextStyle(fontSize: 15.0),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Text(
                              listNotaPO[i].supplier,
                              style: TextStyle(
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(),
                    Container(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 3,
                            child: Text(
                              'Harga Persatuan',
                              style: TextStyle(fontSize: 15.0),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Text(
                              hargaSatuan,
                              style: TextStyle(
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(),
                    Container(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 3,
                            child: Text(
                              'Total Harga',
                              style: TextStyle(fontSize: 15.0),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Text(
                              hargaTotal,
                              style: TextStyle(
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(),
                    Container(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                Container(
                                  child: Text(
                                    'Satuan',
                                    style: TextStyle(fontSize: 15.0),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    listNotaPO[i].satuan,
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                Container(
                                  child: Text(
                                    'Jumlah',
                                    style: TextStyle(fontSize: 15.0),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    listNotaPO[i].qty,
                                    style: TextStyle(color: Colors.orange[800]),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                Container(
                                  child: Text(
                                    'Jumlah Diterima',
                                    style: TextStyle(fontSize: 15.0),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    listNotaPO[i].qtyTerima,
                                    style: TextStyle(color: Colors.orange[800]),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(),
                    Container(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                Container(
                                  child: Text(
                                    'Sisa',
                                    style: TextStyle(fontSize: 15.0),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    listNotaPO[i].qtySisa,
                                    style: TextStyle(color: Colors.orange[800]),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                Container(
                                  child: Text(
                                    'Jumlah diterima',
                                    style: TextStyle(fontSize: 15.0),
                                  ),
                                ),
                                Container(
                                  height: 30.0,
                                  child: TextField(
                                    controller: inputQtyTerimaList[i],
                                    keyboardType: TextInputType.number,
                                    inputFormatters: <TextInputFormatter>[
                                      WhitelistingTextInputFormatter.digitsOnly,
                                    ],
                                    style: TextStyle(
                                      fontSize: 14.0,
                                    ),
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.all(5.0),
                                      hintText: 'Qty terima',
                                    ),
                                    textInputAction: listNotaPO.length - 1 == i
                                        ? TextInputAction.done
                                        : TextInputAction.next,
                                    focusNode: focusInputQtyTerimaList[i],
                                    onSubmitted: (iniVal) {
                                      setState(() {
                                        listNotaPO[i] = ListProduk(
                                          idSatuan: listNotaPO[i].idSatuan,
                                          idGudang: listNotaPO[i].idGudang,
                                          idNotaRencana:
                                              listNotaPO[i].idNotaRencana,
                                          kodeSupplier:
                                              listNotaPO[i].kodeSupplier,
                                          notaRencana:
                                              listNotaPO[i].notaRencana,
                                          kodeProduk: listNotaPO[i].kodeProduk,
                                          supplier: listNotaPO[i].supplier,
                                          qtyTerima: listNotaPO[i].qtyTerima,
                                          hargaSatuan:
                                              listNotaPO[i].hargaSatuan,
                                          hargaTotal: listNotaPO[i].hargaTotal,
                                          namaBarang: listNotaPO[i].namaBarang,
                                          qty: listNotaPO[i].qty,
                                          satuan: listNotaPO[i].satuan,
                                          qtySisa: listNotaPO[i].qtySisa,
                                          qtyTerimaInput: iniVal,
                                        );
                                        inputQtyTerimaList[i].text = iniVal;
                                        // qtyTerima['qty_terima'][i] =
                                        //     int.parse(iniVal);
                                      });
                                      if (listNotaPO.length - 1 != i) {
                                        FocusScope.of(context).requestFocus(
                                            focusInputQtyTerimaList[i + 1]);
                                      }
                                    },
                                    onChanged: (iniVal) {
                                      print(inputQtyTerimaList[i].text);
                                      setState(() {
                                        if (int.parse(listNotaPO[i].qtySisa) <
                                            int.parse(iniVal)) {
                                          print('a');
                                          inputQtyTerimaList[i].text =
                                              listNotaPO[i].qtySisa;

                                          inputQtyTerimaList[i].selection =
                                              TextSelection.collapsed(
                                                  offset: iniVal.length);
                                        } else {
                                          inputQtyTerimaList[i].text = iniVal;
                                          print('b');
                                        }
                                        print('c');
                                        listNotaPO[i] = ListProduk(
                                          idSatuan: listNotaPO[i].idSatuan,
                                          idGudang: listNotaPO[i].idGudang,
                                          idNotaRencana:
                                              listNotaPO[i].idNotaRencana,
                                          kodeSupplier:
                                              listNotaPO[i].kodeSupplier,
                                          notaRencana:
                                              listNotaPO[i].notaRencana,
                                          kodeProduk: listNotaPO[i].kodeProduk,
                                          supplier: listNotaPO[i].supplier,
                                          qtyTerima: listNotaPO[i].qtyTerima,
                                          hargaSatuan:
                                              listNotaPO[i].hargaSatuan,
                                          hargaTotal: listNotaPO[i].hargaTotal,
                                          namaBarang: listNotaPO[i].namaBarang,
                                          qty: listNotaPO[i].qty,
                                          satuan: listNotaPO[i].satuan,
                                          qtySisa: listNotaPO[i].qtySisa,
                                          qtyTerimaInput: iniVal,
                                        );
                                        // qtyTerima['qty_terima'][i] =
                                        //     int.parse(iniVal);
                                        inputQtyTerimaList[i].selection =
                                            TextSelection.collapsed(
                                                offset: iniVal.length);
                                      });
                                    },
                                    // onSubmitted: (iniVal) {
                                    //   setState(() {
                                    //     inputQtyTerimaList[i].text = iniVal;
                                    //     qtyTerima['qty_terima'][i] = iniVal;
                                    //   });
                                    // },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
