import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:invee2/error/error.dart';
import 'package:invee2/gudang/penerimaan_barang/customTilePenerimaan.dart';
import 'package:invee2/gudang/penerimaan_barang/detail_penerimaan.dart';
import 'package:invee2/localStorage/localStorage.dart';
import 'model.dart';
import 'dart:convert';
import 'package:invee2/routes/env.dart';

GlobalKey<ScaffoldState> _scaffoldKeyCariPenerimaanBarang;
TextEditingController cariController;
FocusNode cariFocus;

bool isLoading, isError;
String tokenType, accessToken;
Map<String, String> requestHeaders = Map();

List<NotaPembelian> listWishlist = List<NotaPembelian>();

showInSnackbar(String content) {
  _scaffoldKeyCariPenerimaanBarang.currentState.showSnackBar(
    SnackBar(
      content: Text(content),
    ),
  );
}

class CariPenerimaanBarang extends StatefulWidget {
  @override
  _CariPenerimaanBarangState createState() => _CariPenerimaanBarangState();
}

class _CariPenerimaanBarangState extends State<CariPenerimaanBarang> {
  Future<Null> cariPenerimaanBarang() async {
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
        url('api/cariPenerimaanBarang'),
        headers: requestHeaders,
        body: {
          'cari': cariController.text,
        },
      );

      if (response.statusCode == 200) {
        dynamic responseJson = jsonDecode(response.body);

        listWishlist = List<NotaPembelian>();

        for (var i in responseJson) {
          NotaPembelian wishlistLoop = NotaPembelian(
            id: i['pp_id'].toString(),
            nota: i['po_nota'],
            tglRencana: i['pp_plandate'],
            tglOrder: i['po_orderdate'],
            tglTerima: i['pp_accdate'],
            staff: i['u_name'] == null ? i['pp_staff'] : i['u_name'],
            notaPlan: i['pp_code'],
            status: i['pp_status'],
          );
          listWishlist.add(wishlistLoop);
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

  @override
  void initState() {
    isLoading = true;
    isError = false;
    _scaffoldKeyCariPenerimaanBarang = GlobalKey<ScaffoldState>();
    cariController = TextEditingController();
    cariFocus = FocusNode();

    cariPenerimaanBarang();
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
      key: _scaffoldKeyCariPenerimaanBarang,
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
              Future.delayed(
                Duration(milliseconds: 200),
                cariPenerimaanBarang,
              );
            },
          ),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : isError
              ? ErrorCobalLagi(
                  onPress: cariPenerimaanBarang,
                )
              : ListView.builder(
                  itemCount: listWishlist.length,
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
                    child: CustomTilePenerimaan(
                      leading: Icon(FontAwesomeIcons.cubes,size: 20.0,),
                      title: listWishlist[i].nota,
                      subtitle: listWishlist[i].tglOrder,
                      subtitle2: listWishlist[i].staff,
                      trailing: listWishlist[i].tglTerima,
                      status: listWishlist[i].status,
                      onTab: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            settings: RouteSettings(
                                name: '/detail_penerimaan_barang'),
                            builder: (BuildContext context) {
                              return DetailPenerimaan(
                                status: listWishlist[i].status,
                                nota: listWishlist[i].nota,
                                staff: listWishlist[i].staff,
                                tglRencana: listWishlist[i].tglRencana,
                                tglTerima: listWishlist[i].tglTerima,
                                notaPlan: listWishlist[i].notaPlan,
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
    );
  }
}
