class ListItem {
  String nama, satuan, qty, gudang, kodeBarang, stokPacking, idGudang;

  ListItem({
    this.idGudang,
    this.kodeBarang,
    this.stokPacking,
    this.nama,
    this.satuan,
    this.qty,
    this.gudang,
  });
}

class ListNotaOff {
  String id, nota, customer, status, userProses, userDone, createAt, durasi, tanggalProses;

  ListNotaOff({
    this.id,
    this.nota,
    this.status,
    this.customer,
    this.userDone,
    this.userProses,
    this.createAt,
    this.durasi,
    this.tanggalProses,
  });
}
