import 'package:daftar_belanja/class/barang.dart';
import 'package:daftar_belanja/database_settings.dart';
import 'package:mysql1/mysql1.dart';

abstract class Daftar {
  String? _dateCreated;
  String? _dateUpdated;

  Daftar();
  Daftar.init(this._dateCreated, this._dateUpdated);

  Future<bool> tambahBarang(String nama, int harga, String deskripsi, String kategori, int kuantitas, [String? url]);
  // Future<bool> editBarang(Barang barang);
}

class DaftarBelanja extends Daftar {
  int? _idDaftarBelanja;
  String? _namaDaftarBelanja;
  // int? _totalHarga;

  String get namaDaftarBelanja => _namaDaftarBelanja!;

  DaftarBelanja();
  DaftarBelanja.init(this._idDaftarBelanja, this._namaDaftarBelanja, String dateCreated, String dateUpdated) : super.init(dateCreated, dateUpdated);

  List getAttributes() {
    return [_namaDaftarBelanja, _dateCreated, _dateUpdated];
  }

  Future<List<Barang>> getAllBarang() async {
    MySqlConnection koneksi = await MySqlConnection.connect(settingsDB);

    Results hasil = await koneksi.query("SELECT * FROM barang WHERE daftar_id = ?", [_idDaftarBelanja]);

    await koneksi.close();

    List<Barang> listBarang = [];

    for (var data in hasil) {
      Barang barang = Barang.init(data[0], data[1], data[2], data[3].toString(), data[4], data[5], data[6].toString());

      listBarang.add(barang);
    }

    return listBarang;
  }

  @override
  Future<bool> tambahBarang(String nama, int harga, String deskripsi, String kategori, int kuantitas, [String? url]) async {
    MySqlConnection koneksi = await MySqlConnection.connect(settingsDB);

    Results hasil = await koneksi.query("INSERT INTO barang (nama, harga, deskripsi, kategori, kuantitas, url, daftar_id) VALUES (?, ?, ?, ?, ?, ?, ?)",
      [nama, harga, deskripsi, kategori, kuantitas, url, _idDaftarBelanja]
    );

    await koneksi.close();

    if (hasil.insertId != null) {
      return true;
    } else {
      return false;
    }
  }

  Future<int> hitungTotalHarga() async {
    List<Barang> listBarang = await getAllBarang();

    int total = 0;

    for (Barang barang in listBarang) {
      total += barang.harga;
    }

    return total;
  }
}
