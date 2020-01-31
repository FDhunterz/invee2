import 'package:flutter/material.dart';

class ListKasir {
  String idNota,
      kodeNota,
      namaCustomer,
      statusPembayaran,
      statusPacking,
      statusDeliver,
      statusSetuju,
      metodePembayaran,
      tanggalPembelian,
      provinsi,
      kabupatenKota,
      kodePos,
      alamat,
      gambar,
      tipePenjualan,
      biayaPengiriman,
      namaBank,
      noRekening,
      kecamatan,
      createAt,
      durasi,
      tanggalConfirmPacking,
      tanggalSelesaiPacking,
      confirmPackingBy,
      donePackingBy;

  ListKasir({
    this.namaBank,
    this.noRekening,
    this.biayaPengiriman,
    this.tipePenjualan,
    this.metodePembayaran,
    this.alamat,
    this.tanggalPembelian,
    this.kodePos,
    this.idNota,
    this.kodeNota,
    this.namaCustomer,
    this.statusPembayaran,
    this.statusDeliver,
    this.statusPacking,
    this.statusSetuju,
    this.kabupatenKota,
    this.kecamatan,
    this.gambar,
    this.provinsi,
    this.createAt,
    this.durasi,
    this.tanggalConfirmPacking,
    this.tanggalSelesaiPacking,
    this.confirmPackingBy,
    this.donePackingBy,
  });
}

class DetailProdukKasir {
  String namaProduk,
      namaSatuan,
      hargaProduk,
      qty,
      gambar,
      diskonNilai,
      diskonPersen,
      totalHarga;

  DetailProdukKasir({
    this.gambar,
    this.hargaProduk,
    this.namaProduk,
    this.namaSatuan,
    this.qty,
    this.diskonNilai,
    this.diskonPersen,
    this.totalHarga,
  });
}

class Provinsi {
  String idProvinsi, namaProvinsi;

  Provinsi({
    this.idProvinsi,
    this.namaProvinsi,
  });
}

class KabupatenKota {
  String idKabupatenKota, namaKabupatenKota;

  KabupatenKota({
    this.idKabupatenKota,
    this.namaKabupatenKota,
  });
}

class Kecamatan {
  String idKecamatan, namaKecamatan;

  Kecamatan({
    this.idKecamatan,
    this.namaKecamatan,
  });
}

class Satuan {
  String idSatuan, kodeSatuan, namaSatuan;

  Satuan({
    this.idSatuan,
    this.kodeSatuan,
    this.namaSatuan,
  });
}

class GolonganHarga {
  String kodeGolongan, namaGolongan;

  GolonganHarga({
    this.kodeGolongan,
    this.namaGolongan,
  });
}

class Customer {
  String idCustomer,
      kodeCustomer,
      namaCustomer,
      alamat,
      namaProvinsi,
      namaKabupatenKota,
      namaKecamatan,
      kodePos,
      noTelp,
      email,
      idProvinsi,
      idKabupatenKota,
      idKecamatan;

  Customer({
    this.idCustomer,
    this.namaCustomer,
    this.kodeCustomer,
    this.alamat,
    this.namaKabupatenKota,
    this.namaKecamatan,
    this.namaProvinsi,
    this.kodePos,
    this.idKabupatenKota,
    this.idKecamatan,
    this.idProvinsi,
    this.email,
    this.noTelp,
  });
}

class Produk {
  String idProduk,
      kodeProduk,
      namaProduk,
      idSatuan1,
      kodeSatuan1,
      namaSatuan1,
      idSatuan2,
      kodeSatuan2,
      namaSatuan2,
      idSatuan3,
      kodeSatuan3,
      namaSatuan3,
      hargaProduk,
      selectedKodeSatuan,
      selectedNamaSatuan,
      stok,
      totalHarga,
      diskonNilai,
      diskonPersen,
      totalHargaSetelahDiskon,
      minimalBeliOffline;

  bool isDiskonFilled, isDiskonPersen;

  TextEditingController qtyController,
      diskonPersenController,
      diskonNilaiController;

  Produk({
    this.hargaProduk,
    this.idProduk,
    this.idSatuan1,
    this.kodeSatuan1,
    this.namaSatuan1,
    this.idSatuan2,
    this.kodeSatuan2,
    this.namaSatuan2,
    this.idSatuan3,
    this.kodeSatuan3,
    this.selectedKodeSatuan,
    this.selectedNamaSatuan,
    this.namaSatuan3,
    this.kodeProduk,
    this.namaProduk,
    this.stok,
    this.diskonNilaiController,
    this.diskonPersenController,
    this.qtyController,
    this.totalHarga,
    this.diskonPersen,
    this.diskonNilai,
    this.isDiskonFilled,
    this.isDiskonPersen,
    this.totalHargaSetelahDiskon,
    this.minimalBeliOffline,
  });
}
