class ListItem {
  String nama, satuan, qty, gudang, kodeBarang, stokPacking, idGudang;

  ListItem({
    this.kodeBarang,
    this.stokPacking,
    this.nama,
    this.idGudang,
    this.satuan,
    this.qty,
    this.gudang,
  });
}

class ListNota {
  String id, nota, customer, status, userProses, userDone, createAt, durasi, tanggalProses;

  ListNota({
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
