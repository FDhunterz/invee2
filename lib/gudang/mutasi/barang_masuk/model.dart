class ListNota {
  String id,
      reffKeluar,
      gudang,
      idGudang,
      tglTerima,
      catatan,
      statusData,
      reffMasuk,
      resi,
      tglKirim,
      tglRequestMutasi;

  ListNota({
    this.id,
    this.tglTerima,
    this.reffKeluar,
    this.reffMasuk,
    this.tglKirim,
    this.gudang,
    this.catatan,
    this.idGudang,
    this.statusData,
    this.resi,
    this.tglRequestMutasi,
  });
}

class Produk {
  String kodeProduk,
      namaProduk,
      idSatuan,
      namaSatuan,
      idGudangPeminta,
      namaGudangPeminta,
      idGudangDiminta,
      stokGudang,
      jumlahDisetujui,
      informasiKekurangan,
      jumlahDiminta,
      idRequestMutasi,
      idMutasiBarangKeluar,
      jumlahDiterima;

  Produk({
    this.idGudangPeminta,
    this.idRequestMutasi,
    this.idMutasiBarangKeluar,
    this.idGudangDiminta,
    this.jumlahDiminta,
    this.informasiKekurangan,
    this.idSatuan,
    this.jumlahDisetujui,
    this.jumlahDiterima,
    this.kodeProduk,
    this.namaGudangPeminta,
    this.namaProduk,
    this.namaSatuan,
    this.stokGudang,
  });
}
