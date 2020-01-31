import 'dart:convert';
import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:invee2/error/error.dart';
import 'package:invee2/localStorage/localStorage.dart';
import 'package:http/http.dart' as http;
import 'package:invee2/penjualan/kasir/detail_cekstock.dart';
import 'package:invee2/penjualan/kasir/detail_penjualan.dart';
import 'package:invee2/penjualan/kasir/edit_etalase.dart';
import 'package:invee2/routes/env.dart';
import 'package:invee2/penjualan/kasir/environment/model.dart';
import 'package:invee2/penjualan/kasir/secondary/modal.dart';
import 'package:intl/intl.dart';

GlobalKey<ScaffoldState> _scaffoldKeyCariKasir;
TextEditingController cariController;

String tokenType, accessToken;
Map<String, String> requestHeaders = Map();
List<ListKasir> listKasir;
List<Liststock> listStock;
List<PriceList> listPriceList;

bool isLoading, isError;
FocusNode cariFocus;
bool userAksesMenuKasirCreate;
bool userGroupAksesMenuKasirCreate;
bool userAksesMenuKasirDelete;
bool userGroupAksesMenuKasirDelete;
bool userAksesMenuKasirEdit;
bool userGroupAksesMenuKasirEdit;

showInSnackBarCariKasir(String content) {
  _scaffoldKeyCariKasir.currentState.showSnackBar(
    SnackBar(
      content: Text(content),
    ),
  );
}

class CariKasir extends StatefulWidget {
  @override
  _CariKasirState createState() => _CariKasirState();
}

class _CariKasirState extends State<CariKasir>
    with SingleTickerProviderStateMixin {
  NumberFormat numberFormat =
      NumberFormat.simpleCurrency(decimalDigits: 2, name: 'Rp. ');

  Future<void> getHakAkses() async {
    DataStore store = DataStore();

    userAksesMenuKasirCreate = await store.getDataBool('Kasir Create (Akses)');
    userGroupAksesMenuKasirCreate =
        await store.getDataBool('Kasir Create (Group)');

    userAksesMenuKasirDelete = await store.getDataBool('Kasir Delete (Akses)');
    userGroupAksesMenuKasirDelete =
        await store.getDataBool('Kasir Delete (Group)');

    userAksesMenuKasirEdit = await store.getDataBool('Kasir Edit (Akses)');
    userGroupAksesMenuKasirEdit = await store.getDataBool('Kasir Edit (Group)');
  }

  tolakPenjualan(String idPenjualan) async {
    try {
      final response = await http.post(
        url('api/tolakPenjualan'),
        body: {
          'id': idPenjualan,
        },
        headers: requestHeaders,
      );

      if (response.statusCode == 200) {
        dynamic responseJson = jsonDecode(response.body);

        print(responseJson);

        if (responseJson['status'] == 'sukses') {
          getCari();
          showInSnackBarCariKasir('Sukses, data berhasil diupdate');
        } else if (responseJson['status'] == 'gagal') {
          showInSnackBarCariKasir('Gagal, ${responseJson['message']}');
        }
      } else if (response.statusCode == 401) {
        showInSnackBarCariKasir(
            'Token kedaluwarsa, silahkan logout dan login kembali');
      } else {
        showInSnackBarCariKasir('Error Code : ${response.statusCode}');
        Map responseJson = jsonDecode(response.body);

        if(responseJson.containsKey('message')){
          showInSnackBarCariKasir(responseJson['message']);
        }
        print(jsonDecode(response.body));
      }
    } catch (e) {
      print('Error : ${e.toString()}');
      showInSnackBarCariKasir('Error : ${e.toString()}');
    }
  }

  konfirmPenjualan(String idPenjualan) async {
    try {
      final response = await http.post(
        url('api/confirmKasir'),
        body: {
          'id': idPenjualan,
        },
        headers: requestHeaders,
      );

      if (response.statusCode == 200) {
        dynamic responseJson = jsonDecode(response.body);

        print(responseJson);

        if (responseJson['status'] == 'sukses') {
          getCari();
          showInSnackBarCariKasir('Sukses, data berhasil diupdate');
        } else if (responseJson['status'] == 'gagal') {
          showInSnackBarCariKasir('Gagal, ${responseJson['message']}');
        }
      } else if (response.statusCode == 401) {
        showInSnackBarCariKasir(
            'Token kedaluwarsa, silahkan logout dan login kembali');
      } else {
        showInSnackBarCariKasir('Error Code : ${response.statusCode}');
        Map responseJson = jsonDecode(response.body);

        if(responseJson.containsKey('message')){
          showInSnackBarCariKasir(responseJson['message']);
        }
        print(jsonDecode(response.body));
      }
    } catch (e) {
      print('Error : ${e.toString()}');
      showInSnackBarCariKasir('Error : ${e.toString()}');
    }
  }

  penjualanSelesai(String idPenjualan) async {
    try {
      final response = await http.post(
        url('api/penjualanSelesai'),
        body: {
          'id': idPenjualan,
        },
        headers: requestHeaders,
      );

      if (response.statusCode == 200) {
        dynamic responseJson = jsonDecode(response.body);

        print(responseJson);

        if (responseJson['status'] == 'sukses') {
          getCari();
          showInSnackBarCariKasir('Sukses, data berhasil diupdate');
        } else if (responseJson['status'] == 'gagal') {
          showInSnackBarCariKasir('Gagal, ${responseJson['message']}');
        }
      } else if (response.statusCode == 401) {
        showInSnackBarCariKasir(
            'Token kedaluwarsa, silahkan logout dan login kembali');
      } else {
        showInSnackBarCariKasir('Error Code : ${response.statusCode}');
        Map responseJson = jsonDecode(response.body);

        if(responseJson.containsKey('message')){
          showInSnackBarCariKasir(responseJson['message']);
        }
        print(jsonDecode(response.body));
      }
    } catch (e) {
      print('Error : ${e.toString()}');
      showInSnackBarCariKasir('Error : ${e.toString()}');
    }
  }

  Widget _status({
    String statusPembayaran,
    String statusDeliver,
    String statusPacking,
    String statusSetuju,
    String metodePembayaran,
  }) {
    if (statusSetuju == 'C') {
      return Text(
        'Menunggu Konfirmasi',
        style: TextStyle(
          color: Colors.white,
          backgroundColor: Colors.orange,
        ),
      );
    }

    if (statusSetuju == 'N') {
      return Text(
        'Dibatalkan',
        style: TextStyle(
          color: Colors.white,
          backgroundColor: Colors.red,
        ),
      );
    }

    if (statusDeliver == 'Y') {
      return Text(
        'Transaksi Selesai',
        style: TextStyle(
          color: Colors.white,
          backgroundColor: Colors.green,
        ),
      );
    }

    if (statusDeliver == 'A' && statusPacking == 'Y') {
      return Text(
        'Ambil Sendiri',
        style: TextStyle(
          color: Colors.white,
          backgroundColor: Colors.cyan,
        ),
      );
    }

    if (statusDeliver == 'L') {
      return Text(
        'Pengiriman Terhambat',
        style: TextStyle(
          color: Colors.white,
          backgroundColor: Colors.red,
        ),
      );
    }

    if (statusDeliver == 'P') {
      return Text(
        'Sedang Dikirim',
        style: TextStyle(
          color: Colors.white,
          backgroundColor: Colors.cyan,
        ),
      );
    }

    if (statusPacking == 'Y') {
      return Text(
        'Packing Selesai',
        style: TextStyle(
          color: Colors.white,
          backgroundColor: Colors.blue,
        ),
      );
    }

    if (statusSetuju == 'Y') {
      return Text(
        'Proses Packing',
        style: TextStyle(
          color: Colors.white,
          backgroundColor: Colors.cyan,
        ),
      );
    }

    if (statusPembayaran == 'Y') {
      return Text(
        'Sudah Bayar',
        style: TextStyle(
          color: Colors.white,
          backgroundColor: Colors.cyan,
        ),
      );
    }

    if (statusPembayaran == 'N' &&
        statusSetuju == 'P' &&
        metodePembayaran == 'N') {
      return Text(
        'Sudah Pembayaran Tempo',
        style: TextStyle(
          color: Colors.white,
          backgroundColor: Colors.orange,
        ),
      );
    }

    if (statusPembayaran == 'N' &&
        statusSetuju == 'T' &&
        metodePembayaran == 'N') {
      return Text(
        'Pembayaran Tempo',
        style: TextStyle(
          color: Colors.white,
          backgroundColor: Colors.orange,
        ),
      );
    }

    if (statusPembayaran == 'N' && metodePembayaran == 'T') {
      return Text(
        'Pembayaran',
        style: TextStyle(
          color: Colors.white,
          backgroundColor: Colors.orange,
        ),
      );
    }
    return Text(
      'Ada yang salah',
      style: TextStyle(
        color: Colors.white,
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> getCari() async {
    setState(() {
      isLoading = true;
      isError = false;
    });

    DataStore store = DataStore();

    tokenType = await store.getDataString('token_type');
    accessToken = await store.getDataString('access_token');

    requestHeaders['accept'] = 'application/json';
    requestHeaders['Authorization'] = '$tokenType $accessToken';

    try {
      final response = await http.post(
        url('api/cariKasir'),
        headers: requestHeaders,
        body: {
          'cari': cariController.text,
        },
      );

      if (response.statusCode == 200) {
        dynamic responseJson = jsonDecode(response.body);

        print(responseJson);

        listStock = List();
        listKasir = List();
        listPriceList = List();

        for (var data in responseJson['etalase']) {
          listStock.add(
            Liststock(
              code: data['e_id'].toString(),
              nama: data['e_name'],
            ),
          );
        }

        for (var data in responseJson['kasir']) {
          listKasir.add(
            ListKasir(
              idNota: data['s_id'].toString(),
              kodeNota: data['s_nota'],
              namaCustomer: data['cm_name'],
              statusDeliver: data['s_delivered'],
              statusPacking: data['s_packing'],
              statusPembayaran: data['s_paystatus'],
              statusSetuju: data['s_isapprove'],
              metodePembayaran: data['s_paymethod'],
              kabupatenKota: data['c_nama'],
              kecamatan: data['d_nama'],
              provinsi: data['p_nama'],
              tanggalPembelian: data['s_date'],
              kodePos: data['s_postalcode'],
              alamat: data['s_address'],
              // gambar: data['ip_path'],
              tipePenjualan: data['s_category'],
              biayaPengiriman: data['s_payexpedition'],
              namaBank: data['s_detailpay'],
              noRekening: data['s_bankcode'],
            ),
          );
        }

        for (var data in responseJson['price_list']) {
          listPriceList.add(
            PriceList(
              barang: data['i_name'],
              harga1: data['ipr_sunitprice'],
              harga2: data['ipr_sunitprice2'],
              harga3: data['ipr_sunitprice3'],
              satuan1: data['satuan1'],
              satuan2: data['satuan2'],
              satuan3: data['satuan3'],
            ),
          );
        }

        setState(() {
          isLoading = false;
          isError = false;
        });
      } else if (response.statusCode == 401) {
        showInSnackBarCariKasir('Token kedaluwarsa, silahkan login kembali');
        setState(() {
          isLoading = false;
          isError = true;
        });
      } else {
        showInSnackBarCariKasir('Error Code : ${response.statusCode}');
        Map responseJson = jsonDecode(response.body);

        if(responseJson.containsKey('message')){
          showInSnackBarCariKasir(responseJson['message']);
        }
        print(jsonDecode(response.body));
        setState(() {
          isLoading = false;
          isError = true;
        });
      }
    } catch (e) {
      print('Error : $e');
      showInSnackBarCariKasir('Error : ${e.toString()}');
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

    listKasir = List<ListKasir>();
    listStock = List<Liststock>();
    listPriceList = List<PriceList>();

    _scaffoldKeyCariKasir = GlobalKey<ScaffoldState>();
    cariController = TextEditingController();
    cariFocus = FocusNode();

    getCari();

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
        length: 3,
        child: Scaffold(
          key: _scaffoldKeyCariKasir,
          appBar: AppBar(
            backgroundColor: Colors.white,
            textTheme: TextTheme(
              title: TextStyle(
                color: Colors.black,
              ),
              button: TextStyle(
                color: Colors.black,
              ),
            ),
            iconTheme: IconThemeData(
              color: Colors.black,
            ),
            title: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              child: TextField(
                autofocus: true,
                focusNode: cariFocus,
                controller: cariController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Cari Nota/Customer/Produk',
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.black,
                  ),
                  contentPadding: EdgeInsets.all(13.0),
                ),
                onChanged: (ini) {
                  cariController.value = TextEditingValue(
                    selection: cariController.selection,
                    text: ini,
                  );
                  Future.delayed(
                    Duration(
                      milliseconds: 100,
                    ),
                    getCari,
                  );
                },
              ),
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {},
              ),
            ],
            bottom: TabBar(
              isScrollable: true,
              labelColor: Colors.black,
              dragStartBehavior: DragStartBehavior.start,
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(
                  width: 4,
                  color: Colors.green,
                ),
              ),
              tabs: <Widget>[
                Tab(
                  icon: Icon(
                    Icons.shopping_cart,
                  ),
                  text: 'Penjualan',
                ),
                Tab(
                  icon: Icon(
                    Icons.find_in_page,
                  ),
                  text: 'Cek Stok',
                ),
                Tab(
                  icon: Icon(
                    Icons.library_books,
                  ),
                  text: 'Price List',
                ),
              ],
            ),
          ),
          backgroundColor: Colors.white,
          body: TabBarView(
            children: <Widget>[
              // Tab Index 0
              isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : isError
                      ? ErrorCobalLagi(
                          onPress: getCari,
                        )
                      : Scrollbar(
                          child: ListView(
                            children: listKasir.length == 0
                                ? [
                                    ListTile(
                                      title: Text(
                                        'Tidak ada data',
                                        textAlign: TextAlign.center,
                                      ),
                                    )
                                  ]
                                : listKasir
                                    .map(
                                      (ListKasir listKasir) => Card(
                                        child: ListTile(
                                          title: Text(listKasir.kodeNota),
                                          subtitle:
                                              Text(listKasir.namaCustomer),
                                          leading: Icon(Icons.note),
                                          trailing: Column(
                                            children: <Widget>[
                                              _status(
                                                statusDeliver:
                                                    listKasir.statusDeliver,
                                                statusPacking:
                                                    listKasir.statusPacking,
                                                statusPembayaran:
                                                    listKasir.statusPembayaran,
                                                statusSetuju:
                                                    listKasir.statusSetuju,
                                                metodePembayaran:
                                                    listKasir.metodePembayaran,
                                              ),
                                              Container(
                                                padding: EdgeInsets.only(
                                                    top: 5.0, bottom: 5.0),
                                                child: Text(
                                                  DateFormat('dd MMMM y')
                                                      .format(
                                                    DateTime.parse(
                                                        '${listKasir.tanggalPembelian} 00:00:00.000'),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text('Aksi'),
                                                  actions: <Widget>[
                                                    if (userAksesMenuKasirDelete ||
                                                        userGroupAksesMenuKasirDelete)
                                                      if (listKasir
                                                              .statusSetuju ==
                                                          'C')
                                                        RaisedButton(
                                                          color: Colors.red,
                                                          textColor:
                                                              Colors.white,
                                                          onPressed: () {
                                                            showDialog(
                                                              context: context,
                                                              builder: (BuildContext
                                                                      context) =>
                                                                  AlertDialog(
                                                                title: Text(
                                                                    'Peringatan'),
                                                                content: Text(
                                                                    'Apa anda yakin membatalkan transaksi ini?'),
                                                                actions: <
                                                                    Widget>[
                                                                  FlatButton(
                                                                    child: Text(
                                                                      'Tidak',
                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .black54,
                                                                      ),
                                                                    ),
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.popUntil(
                                                                          context,
                                                                          ModalRoute.withName(
                                                                              '/kasir'));
                                                                    },
                                                                  ),
                                                                  FlatButton(
                                                                    child: Text(
                                                                        'Ya'),
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.popUntil(
                                                                          context,
                                                                          ModalRoute.withName(
                                                                              '/kasir'));
                                                                      tolakPenjualan(
                                                                          listKasir
                                                                              .idNota);
                                                                    },
                                                                  )
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                          child:
                                                              Text('Batalkan'),
                                                        ),
                                                    if (userAksesMenuKasirEdit ||
                                                        userGroupAksesMenuKasirEdit)
                                                      FlatButton(
                                                        // color: Colors.orange,
                                                        textColor: Colors.cyan,
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              settings:
                                                                  RouteSettings(
                                                                      name:
                                                                          '/detail_penjualan'),
                                                              builder: (BuildContext
                                                                      context) =>
                                                                  DetailPenjualan(
                                                                namaCustomer:
                                                                    listKasir
                                                                        .namaCustomer,
                                                                nota: listKasir
                                                                    .kodeNota,
                                                                statusDeliver:
                                                                    listKasir
                                                                        .statusDeliver,
                                                                statusPacking:
                                                                    listKasir
                                                                        .statusPacking,
                                                                statusPembayaran:
                                                                    listKasir
                                                                        .statusPembayaran,
                                                                statusSetuju:
                                                                    listKasir
                                                                        .statusSetuju,
                                                                tanggalPembelian:
                                                                    listKasir
                                                                        .tanggalPembelian,
                                                                alamat:
                                                                    listKasir
                                                                        .alamat,
                                                                kabupatenKota:
                                                                    listKasir
                                                                        .kabupatenKota,
                                                                kecamatan:
                                                                    listKasir
                                                                        .kecamatan,
                                                                kodePos:
                                                                    listKasir
                                                                        .kodePos,
                                                                provinsi:
                                                                    listKasir
                                                                        .provinsi,
                                                                metodePembayaran:
                                                                    listKasir
                                                                        .metodePembayaran,
                                                                biayaPengiriman:
                                                                    listKasir
                                                                        .biayaPengiriman,
                                                                tipePenjualan:
                                                                    listKasir
                                                                        .tipePenjualan,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        child: Text('Detail'),
                                                      ),
                                                    if (userAksesMenuKasirEdit ||
                                                        userGroupAksesMenuKasirEdit)
                                                      if (listKasir
                                                              .statusSetuju ==
                                                          'C')
                                                        FlatButton(
                                                          textColor:
                                                              Colors.green,
                                                          onPressed: () {
                                                            showDialog(
                                                              context: context,
                                                              builder: (BuildContext
                                                                      context) =>
                                                                  AlertDialog(
                                                                title: Text(
                                                                    'Peringatan'),
                                                                content: Text(
                                                                    'Apa anda yakin menkonfirmasi transaksi ini?'),
                                                                actions: <
                                                                    Widget>[
                                                                  FlatButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator
                                                                          .popUntil(
                                                                        context,
                                                                        ModalRoute.withName(
                                                                            '/kasir'),
                                                                      );
                                                                    },
                                                                    child: Text(
                                                                      'Tidak',
                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .black54,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  FlatButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator
                                                                          .popUntil(
                                                                        context,
                                                                        ModalRoute.withName(
                                                                            '/kasir'),
                                                                      );
                                                                      konfirmPenjualan(
                                                                          listKasir
                                                                              .idNota);
                                                                    },
                                                                    child: Text(
                                                                        'Ya'),
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                          child:
                                                              Text('Konfirm'),
                                                        ),
                                                    if (listKasir
                                                                .statusDeliver ==
                                                            'A' &&
                                                        listKasir
                                                                .statusPacking ==
                                                            'Y')
                                                      FlatButton(
                                                        child: Text(
                                                            'Sudah Diambil?'),
                                                        onPressed: () {
                                                          showDialog(
                                                            context: context,
                                                            builder: (BuildContext
                                                                    context) =>
                                                                AlertDialog(
                                                              title: Text(
                                                                  'Peringtan!'),
                                                              content: Text(
                                                                  'Apa anda ingin mengakhiri transaksi ini?'),
                                                              actions: <Widget>[
                                                                FlatButton(
                                                                  child: Text(
                                                                    'Tidak',
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .black54,
                                                                    ),
                                                                  ),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                ),
                                                                FlatButton(
                                                                  child: Text(
                                                                      'Ya'),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator
                                                                        .popUntil(
                                                                      context,
                                                                      ModalRoute
                                                                          .withName(
                                                                              '/cari_kasir'),
                                                                    );
                                                                    penjualanSelesai(
                                                                        listKasir
                                                                            .idNota);
                                                                  },
                                                                )
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                      )
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    )
                                    .toList(),
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
                          onPress: getCari,
                        )
                      : Scrollbar(
                          child: ListView(
                            children: listStock.length == 0
                                ? [
                                    ListTile(
                                      title: Text(
                                        'Tidak ada data',
                                        textAlign: TextAlign.center,
                                      ),
                                    )
                                  ]
                                : listStock
                                    .map(
                                      (Liststock listStock) => Card(
                                        child: ListTile(
                                          title: Text(listStock.nama),
                                          onTap: () {
                                            showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: Text('aksi'),
                                                    actions: <Widget>[
                                                      RaisedButton(
                                                        // color: Colors.red,
                                                        textColor: Colors.white,
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                      DetailCek(
                                                                code: listStock
                                                                    .code,
                                                                nama: listStock
                                                                    .nama,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        child: Text('Detail'),
                                                      ),
                                                      RaisedButton(
                                                        // color: Colors.red,
                                                        textColor: Colors.white,
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                      EditEtalase(
                                                                etalase:
                                                                    listStock
                                                                        .code,
                                                                nama: listStock
                                                                    .nama,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        child: Text('Edit'),
                                                      ),
                                                    ],
                                                  );
                                                });
                                          },
                                        ),
                                      ),
                                    )
                                    .toList(),
                          ),
                        ),
              // End Tab Index 1

              // Tab Index 2
              isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : isError
                      ? ErrorCobalLagi(
                          onPress: getCari,
                        )
                      : Scrollbar(
                          child: ListView(
                            children: listPriceList
                                .map(
                                  (PriceList listPriceList) => Card(
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                              title: Text(listPriceList.barang),
                              subtitle: Container(
                                child : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    listPriceList.satuan1 == null ? Text('No Set') : Text(listPriceList.satuan1),
                                    listPriceList.satuan2 == null ? Text('No Set') : Text(listPriceList.satuan2),
                                    listPriceList.satuan3 == null ? Text('No Set') : Text(listPriceList.satuan3)
                                  ],
                                )
                              ),
                              trailing: Container(
                                height: 120,
                                child : Column(
                                  children: <Widget>[
                                    listPriceList.satuan1 == null ? Text('No Set') : Text(
                                      listPriceList.harga1 == null ? '0' :
                                      numberFormat.format(
                                          double.parse(listPriceList.harga1)),
                                    ),
                                    listPriceList.satuan2 == null ? Text('No Set') : Text(
                                      listPriceList.harga2 == null ? '0' :
                                      numberFormat.format(
                                          double.parse(listPriceList.harga2)),
                                    ),

                                    listPriceList.satuan3 == null ? Text('No Set') : Text(
                                      listPriceList.harga3 == null ? '0' :
                                      numberFormat.format(
                                          double.parse(listPriceList.harga3)),
                                    ),
                                  ],
                                )
                              ),
                            ),
                          ),
                                )
                                .toList(),
                          ),
                        ),
              // End Tab Index 2
            ],
          ),
        ),
      ),
    );
  }
}
