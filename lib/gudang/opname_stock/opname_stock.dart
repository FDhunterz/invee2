import 'package:flutter/material.dart';
import 'package:invee2/gudang/opname_stock/cariOpnameStock.dart';
// import 'package:invee2/gudang/opname_stock/tab_circle/custom_list_circle.dart';
// import 'package:invee2/gudang/opname_stock/tab_circle/detail_circletime.dart';
// import 'package:invee2/gudang/opname_stock/tab_manual/tab_detail_manual.dart';
import 'package:invee2/localStorage/localStorage.dart';

import './tab_circle/tab_circletime.dart';
import './tab_manual/tab_manual.dart';
// import './model.dart';

int tabControllerIndex = 0;

String tokenType, accessToken;
Map<String, String> requestHeaders = Map();
GlobalKey<ScaffoldState> _scaffoldKeyY = new GlobalKey<ScaffoldState>();
bool isLoading;

bool userAksesMenuOpnameManual, userGroupAksesMenuOpnameManual;

void showInSnackBarOpnameStok(String value) {
  _scaffoldKeyY.currentState.showSnackBar(
    SnackBar(
      content: Text(value),
    ),
  );
}

class OpnameStock extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _OpnameStockState();
  }
}

class _OpnameStockState extends State<OpnameStock>
    with TickerProviderStateMixin {
  TabController _tabController;

  void _getIndexCurrentTab() {
    print(tabControllerIndex);
    setState(() {
      tabControllerIndex = _tabController.index;
    });
  }

  getUserAksesDanGroupAkses() async {
    DataStore store = new DataStore();

    userAksesMenuOpnameManual =
        await store.getDataBool('Opname Stock Create (Akses)');
    userGroupAksesMenuOpnameManual =
        await store.getDataBool('Opname Stock Create (Group)');

    userAksesMenuOpnameManual = userAksesMenuOpnameManual;
    userGroupAksesMenuOpnameManual = userGroupAksesMenuOpnameManual;
  }

  @override
  void initState() {
    getUserAksesDanGroupAkses();
    isLoading = false;
    _tabController = new TabController(vsync: this, length: 2);
    _tabController.addListener(_getIndexCurrentTab);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: _scaffoldKeyY,
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    settings: RouteSettings(name: '/cari_opname_stock'),
                    builder: (BuildContext context) => CariOpnameStock(),
                  ),
                );
              },
            )
          ],
          bottom: TabBar(
            controller: _tabController,
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
          title: Text('Opname Stock'),
        ),
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            TabCircle(),
            TabManual(
              userAksesMenuOpnameManual: userAksesMenuOpnameManual,
              userGroupAksesMenuOpnameManual: userGroupAksesMenuOpnameManual,
            ),
          ],
        ),
      ),
    );
  }
}
