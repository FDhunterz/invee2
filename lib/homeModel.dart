class Cabang {
  String id, namaCabang;
  Cabang({this.id, this.namaCabang});

  bool operator ==(Object other) => other is Cabang && other.id == id;

  int get hashCode => id.hashCode;
}

class Gudang {
  String idGudang, namaGudang;

  Gudang({
    this.idGudang,
    this.namaGudang,
  });

  bool operator ==(Object other) =>
      other is Gudang && other.idGudang == idGudang;

  int get hashCode => idGudang.hashCode;
}
