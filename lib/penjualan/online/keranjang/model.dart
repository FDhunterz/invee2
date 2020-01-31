class KeranjangModel {
  String id, customer, createdAt, email, telpon, kodeCustomer;

  KeranjangModel({
    this.id,
    this.customer,
    this.createdAt,
    this.email,
    this.kodeCustomer,
    this.telpon,
  });
}

class ListKeranjangModel {
  String nama, code, qty,satuan;

  ListKeranjangModel({
    this.nama,
    this.code,
    this.qty,
    this.satuan,
  });
}
