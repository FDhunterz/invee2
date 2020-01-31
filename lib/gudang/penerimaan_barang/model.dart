import 'package:flutter/widgets.dart';


class NotaPembelian {
  String id, nota, tglTerima, tglRencana, tglOrder, staff, notaPlan, status;
  NotaPembelian({
    this.id,
    this.nota,
    this.tglTerima,
    this.tglRencana,
    this.tglOrder,
    this.staff,
    this.notaPlan,
    this.status,
  });
}


Map<String, dynamic> qtyTerima = Map();
List<TextEditingController> inputQtyTerimaList = [];
List<FocusNode> focusInputQtyTerimaList = [];

class ListQtyTerima {
  String qty;
  ListQtyTerima({this.qty});
}

int onlyRunOnce = 0;
List<ListProduk> listNotaPO = [];

class ListProduk {
  String qty, namaBarang, satuan, qtyTerima, hargaSatuan, hargaTotal, supplier, kodeProduk, notaRencana, idSatuan, idGudang, idNotaRencana, kodeSupplier, qtySisa, qtyTerimaInput;
  ListProduk({
    @required this.notaRencana,
    @required this.kodeProduk,
    @required this.supplier,
    @required this.qty,
    @required this.namaBarang,
    @required this.satuan,
    @required this.hargaSatuan,
    @required this.hargaTotal,
    @required this.qtyTerima, // qty terima dari database
    @required this.idSatuan,
    @required this.idGudang,
    @required this.idNotaRencana,
    @required this.kodeSupplier,
    @required this.qtySisa,
    this.qtyTerimaInput // qty terima untuk input/textfield
  });
}
