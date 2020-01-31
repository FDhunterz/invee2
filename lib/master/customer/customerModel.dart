class Customer {
  String idCustomer,
      namaCustomer,
      kodeCustomer,
      alamat,
      idProvinsi,
      idKabupatenKota,
      idKecamatan,
      namaProvinsi,
      namaKabupatenKota,
      namaKecamatan,
      telpon,
      kodePos,
      gambar,
      username,
      password,
      gender,
      tanggalLahir,
      tempatLahir,
      noRekening,
      email,
      statusData,
      namaBank;

  Customer({
    this.idProvinsi,
    this.email,
    this.idKecamatan,
    this.idKabupatenKota,
    this.kodeCustomer,
    this.telpon,
    this.alamat,
    this.gambar,
    this.gender,
    this.idCustomer,
    this.kodePos,
    this.namaBank,
    this.namaCustomer,
    this.noRekening,
    this.password,
    this.tanggalLahir,
    this.tempatLahir,
    this.username,
    this.namaProvinsi,
    this.namaKabupatenKota,
    this.namaKecamatan,
    this.statusData,
  });
}

class JenisKelamin {
  String isi, nama;
  JenisKelamin({
    this.isi,
    this.nama,
  });

  bool operator ==(Object other) => other is JenisKelamin && other.isi == isi;

  int get hashCode => isi.hashCode;
}
