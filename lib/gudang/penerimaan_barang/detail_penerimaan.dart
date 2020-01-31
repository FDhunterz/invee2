import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:invee2/error/error.dart';
import 'package:invee2/gudang/penerimaan_barang/proses_penerimaan.dart';
// import 'package:invee2/gudang/penerimaan_barang/tab_daftar.dart';
import 'package:intl/intl.dart';
import 'package:invee2/gudang/penerimaan_barang/tab_detail.dart';
import 'package:invee2/localStorage/localStorage.dart';
import 'package:http/http.dart' as http;
import 'package:invee2/routes/env.dart';
// import 'package:invee2/shimmer_loading.dart';
import './model.dart';

String tokenType, accessToken;
Map<String, String> requestHeaders = Map();
GlobalKey<ScaffoldState> _scaffoldKeyPenerimaanBarang;

bool userAksesMenuPenerimaanBarang, userGroupAksesMenuPenerimaanBarang;
bool isLoading, isError;

List<ListProduk> listProduk;

class DetailPenerimaan extends StatefulWidget {
  final String id, nota, tglTerima, tglRencana, staff, notaPlan, status;
  DetailPenerimaan({
    this.id,
    @required this.nota,
    @required this.tglTerima,
    @required this.tglRencana,
    @required this.staff,
    this.notaPlan,
    @required this.status,
  });
  @override
  _DetailPenerimaanState createState() => _DetailPenerimaanState();
}

class _DetailPenerimaanState extends State<DetailPenerimaan> {
  NumberFormat _numberFormat =
      new NumberFormat.simpleCurrency(decimalDigits: 2, name: 'Rp. ');

  void showInSnackBarPenerimaanBarang(String value) {
    _scaffoldKeyPenerimaanBarang.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  Widget _cekTglTerimaProses({String status}) {
    if (userAksesMenuPenerimaanBarang || userGroupAksesMenuPenerimaanBarang) {
      if (status == 'process') {
        return FloatingActionButton(
          child: Icon(Icons.input),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              settings: RouteSettings(name: '/proses_penerimaan_barang'),
              builder: (BuildContext context) => ProsesPenerimaanBarangSupplier(
                status: widget.status,
                nota: widget.nota,
                id: widget.id,
                notaPlan: widget.notaPlan,
                staff: widget.staff,
                tglRencana: widget.tglRencana,
                tglTerima: widget.tglTerima,
                list: listNotaPO,
              ),
            ),
          ),
        );
      } else if (status == 'success') {
        return Container();
      }
    }
    return Container();
  }

  Future<Null> detailPenerimaanBarangSupplierAndroid() async {
    DataStore storage = new DataStore();

    String tokenTypeStorage = await storage.getDataString('token_type');
    String accessTokenStorage = await storage.getDataString('access_token');

    tokenType = tokenTypeStorage;
    accessToken = accessTokenStorage;

    requestHeaders['Accept'] = 'application/json';
    requestHeaders['Authorization'] = '$tokenType $accessToken';

    setState(() {
      isLoading = true;
      isError = false;
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
        dynamic notaJson = json.decode(nota.body);

        listProduk = [];
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

          listProduk.add(notax);
        }

        // print('fututer func');

        setState(() {
          isLoading = false;
          isError = false;
        });
      } else if (nota.statusCode == 401) {
        showInSnackBarPenerimaanBarang(
            'Token kedaluwarsa, silahkan login kembali');

        setState(() {
          isLoading = false;
          isError = true;
        });
      } else {
        showInSnackBarPenerimaanBarang(
            'Request failed with status: ${nota.statusCode}');
        print(jsonDecode(nota.body));
        Map responseJson = jsonDecode(nota.body);

        if(responseJson.containsKey('message')){
          showInSnackBarPenerimaanBarang(responseJson['message']);
        }
        setState(() {
          isLoading = false;
          isError = true;
        });
      }
    } on TimeoutException catch (_) {
      showInSnackBarPenerimaanBarang('Timed out, Try again');
      setState(() {
        isLoading = false;
        isError = true;
      });
    } catch (e) {
      print('Error : $e');
      showInSnackBarPenerimaanBarang('Error : $e');
      setState(() {
        isLoading = false;
        isError = true;
      });
    }
    // return null;
  }

  getUserAksesDanGroupAkses() async {
    DataStore store = new DataStore();

    userAksesMenuPenerimaanBarang = await store
        .getDataBool('Penerimaan Barang Masuk dari Supplier Edit (Akses)');
    userGroupAksesMenuPenerimaanBarang = await store
        .getDataBool('Penerimaan Barang Masuk dari Supplier Edit (Group)');

    setState(() {
      userAksesMenuPenerimaanBarang = userAksesMenuPenerimaanBarang;
      userGroupAksesMenuPenerimaanBarang = userGroupAksesMenuPenerimaanBarang;
    });
  }

  void initState() {
    isLoading = true;
    isError = false;
    _scaffoldKeyPenerimaanBarang = new GlobalKey<ScaffoldState>();
    userAksesMenuPenerimaanBarang = false;
    userGroupAksesMenuPenerimaanBarang = false;
    getUserAksesDanGroupAkses();

    detailPenerimaanBarangSupplierAndroid();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        floatingActionButton: _cekTglTerimaProses(status: widget.status),
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          title: Text('Detail Penerimaan Barang'),
          bottom: TabBar(
            isScrollable: true,
            tabs: <Widget>[
              Tab(
                icon: Icon(Icons.details),
                text: 'Detail Order Pembelian',
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
            // Tab Index 0
            TabDetail(
              status: widget.status,
              nota: widget.nota,
              staff: widget.staff,
              tglRencana: widget.tglRencana,
              tglTerima: widget.tglTerima,
              notaPlan: widget.notaPlan,
            ),
            // End Tab Index 0

            // Tab Index 1
            isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : isError
                    ? ErrorCobalLagi(
                        onPress: detailPenerimaanBarangSupplierAndroid,
                      )
                    : Scrollbar(
                        child: RefreshIndicator(
                          onRefresh: detailPenerimaanBarangSupplierAndroid,
                          child: ListView.builder(
                            itemCount: listProduk.length,
                            itemBuilder: (BuildContext context, int i) {
                              double getHargaSatuan =
                                  double.parse(listProduk[i].hargaSatuan);
                              double getHargaTotal =
                                  double.parse(listProduk[i].hargaTotal);

                              String hargaSatuan =
                                  _numberFormat.format(getHargaSatuan);
                              String hargaTotal =
                                  _numberFormat.format(getHargaTotal);

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
                                                style:
                                                    TextStyle(fontSize: 15.0),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 5,
                                              child: Text(
                                                listProduk[i].namaBarang,
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
                                                style:
                                                    TextStyle(fontSize: 15.0),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 5,
                                              child: Text(
                                                listProduk[i].supplier,
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
                                                style:
                                                    TextStyle(fontSize: 15.0),
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
                                                style:
                                                    TextStyle(fontSize: 15.0),
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
                                                      style: TextStyle(
                                                          fontSize: 15.0),
                                                    ),
                                                  ),
                                                  Container(
                                                    child: Text(
                                                      listProduk[i].satuan,
                                                      style: TextStyle(
                                                          color:
                                                              Colors.black54),
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
                                                      style: TextStyle(
                                                          fontSize: 15.0),
                                                    ),
                                                  ),
                                                  Container(
                                                    child: Text(
                                                      listProduk[i].qty,
                                                      style: TextStyle(
                                                          color: Colors
                                                              .orange[800]),
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
                                                      style: TextStyle(
                                                          fontSize: 15.0),
                                                    ),
                                                  ),
                                                  Container(
                                                    child: Text(
                                                      listProduk[i].qtyTerima,
                                                      style: TextStyle(
                                                          color: Colors
                                                              .orange[800]),
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
                                                      'Sisa',
                                                      style: TextStyle(
                                                          fontSize: 15.0),
                                                    ),
                                                  ),
                                                  Container(
                                                    child: Text(
                                                      listProduk[i].qtySisa,
                                                      style: TextStyle(
                                                          color: Colors
                                                              .orange[800]),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
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
    );
  }
}
