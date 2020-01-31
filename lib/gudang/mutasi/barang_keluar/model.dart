class Produk {
  String codeProduk,
      namaProduk,
      kodeSatuan,
      namaSatuan,
      stokDiminta,
      stokDisetujui,
      gudangDiminta,
      gudangPeminta,
      idGudangPeminta,
      stokGudangDiminta,
      idGudangDiminta,
      idRequestMutasi,
      statusData;

  Produk({
    this.statusData,
    this.idRequestMutasi,
    this.codeProduk,
    this.namaProduk,
    this.kodeSatuan,
    this.namaSatuan,
    this.stokDiminta,
    this.gudangDiminta,
    this.gudangPeminta,
    this.stokDisetujui,
    this.stokGudangDiminta,
    this.idGudangDiminta,
    this.idGudangPeminta,
  });
}
