class ListNota {
  String barang, kodeBarang, id, status, qty, namaSatuan, namaGudang, idGudang, confirmBy, doneBy;

  ListNota({
    this.namaSatuan,
    this.id,
    this.barang,
    this.status,
    this.qty,
    this.kodeBarang,
    this.idGudang,
    this.namaGudang,
    this.confirmBy,
    this.doneBy,
  });
}

class CheckedNota {
  String kodeBarang, idLayananNota, status, qty, namaGudang, idGudang;
  bool checked;

  CheckedNota({
    this.idGudang,
    this.namaGudang,
    this.kodeBarang,
    this.checked,
    this.idLayananNota,
    this.status,
    this.qty,
  });
}
