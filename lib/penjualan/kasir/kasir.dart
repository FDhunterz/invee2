import 'package:flutter/material.dart';
import 'package:invee2/localStorage/localStorage.dart';
import 'package:invee2/penjualan/kasir/cari/cari.dart';
import 'package:invee2/penjualan/kasir/pricelist.dart';
import 'package:invee2/penjualan/kasir/tab_cariPrint.dart';
import './tab_penjualan.dart';
// import './tab_pembayaran.dart';
import './tab_cekstok.dart';

bool userAksesMenuKasirCreate,
    userGroupAksesMenuKasirCreate,
    userAksesMenuKasirDelete,
    userGroupAksesMenuKasirDelete,
    userGroupAksesMenuKasirEdit,
    userAksesMenuKasirEdit;

class Kasir extends StatefulWidget {
  const Kasir({Key key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _KasirState();
  }
}

class _KasirState extends State<Kasir> with SingleTickerProviderStateMixin {
  getUserAksesDanGroupAkses() async {
    DataStore store = new DataStore();

    userAksesMenuKasirCreate = await store.getDataBool('Kasir Create (Akses)');
    userGroupAksesMenuKasirCreate =
        await store.getDataBool('Kasir Create (Group)');

    userAksesMenuKasirDelete = await store.getDataBool('Kasir Delete (Akses)');
    userGroupAksesMenuKasirDelete =
        await store.getDataBool('Kasir Delete (Group)');

    userAksesMenuKasirEdit = await store.getDataBool('Kasir Edit (Akses)');
    userGroupAksesMenuKasirEdit = await store.getDataBool('Kasir Edit (Group)');

    setState(() {
      userAksesMenuKasirCreate = userAksesMenuKasirCreate;
      userGroupAksesMenuKasirCreate = userGroupAksesMenuKasirCreate;
      userAksesMenuKasirEdit = userAksesMenuKasirEdit;
      userGroupAksesMenuKasirEdit = userGroupAksesMenuKasirEdit;
      userAksesMenuKasirDelete = userAksesMenuKasirDelete;
      userGroupAksesMenuKasirDelete = userGroupAksesMenuKasirDelete;
    });
  }

  @override
  void initState() {
    getUserAksesDanGroupAkses();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    settings: RouteSettings(name: '/cari_kasir'),
                    builder: (BuildContext context) => CariKasir(),
                  ),
                );
              },
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(
                icon: Icon(Icons.shopping_cart),
                text: 'Penjualan',
              ),
              // Tab(
              //   icon: Icon(Icons.attach_money),
              //   text: 'Pembayaran',
              // ),
              Tab(
                icon: Icon(Icons.find_in_page),
                text: 'Cek Stok',
              ),
              Tab(
                icon: Icon(Icons.library_books),
                text: 'Price List',
              ),
              Tab(
                icon: Icon(Icons.print),
                text: 'Cari Print',
              )
            ],
          ),
          title: Text('Kasir'),
        ),
        body: TabBarView(
          children: [
            TabPenjualan(
              userAksesMenuKasirCreate: userAksesMenuKasirCreate,
              userAksesMenuKasirDelete: userAksesMenuKasirDelete,
              userAksesMenuKasirEdit: userAksesMenuKasirEdit,
              userGroupAksesMenuKasirCreate: userGroupAksesMenuKasirCreate,
              userGroupAksesMenuKasirDelete: userGroupAksesMenuKasirDelete,
              userGroupAksesMenuKasirEdit: userGroupAksesMenuKasirEdit,
            ),
            // TabPembayaran(),
            TabCekStok(),
            Pricelist(),
            TabCariPrint(),
          ],
        ),
      ),
    );
  }
}
