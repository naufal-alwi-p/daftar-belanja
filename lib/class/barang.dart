import 'package:daftar_belanja/database_settings.dart';
import 'package:mysql1/mysql1.dart';

class Barang {
  int? _idBarang;
  String? _nama;
  int? _harga;
  String? _deskripsi;
  String? _kategori;
  int? _kuantitas;
  String? _url;

  int get harga => _harga!;

  int get kuantitas => _kuantitas!;

  Barang();
  Barang.init(this._idBarang, this._nama, this._harga, this._deskripsi, this._kategori, this._kuantitas, [this._url]);

  Future<bool> getById(int idBarang) async {
    MySqlConnection koneksi = await MySqlConnection.connect(settingsDB);

    Results hasil = await koneksi.query("SELECT * FROM barang WHERE id = ?", [idBarang]);

    await koneksi.close();

    if (hasil.length == 1) {
      Map<String, dynamic> barang = hasil.first.fields;

      _idBarang = barang['id'];
      _nama = barang['nama'];
      _harga = barang['harga'];
      _deskripsi = barang['deskripsi'].toString();
      _kategori = barang['kategori'];
      _kuantitas = barang['kuantitas'];
      _url = barang['url'];

      return true;
    } else if (hasil.isEmpty) {
      throw(Exception("Gagal Mendapatkan Barang !"));
    } else {
      throw(Exception("Ada Kesalahan !"));
    }
  }

  Future<bool> update(String nama, int harga, String? deskripsi, String kategori, int kuantitas, [String? url]) async {
    if (_idBarang == null && _nama == null && _harga == null && _deskripsi == null && _kategori == null && _kuantitas == null && _url == null) {
      throw(Exception("Tidak Ada Data Barang !"));
    } else {
      MySqlConnection koneksi = await MySqlConnection.connect(settingsDB);

      Results hasil = await koneksi.query("UPDATE barang SET nama = ?, harga = ?, deskripsi = ?, kategori = ?, kuantitas = ?, url = ? WHERE id = ?",
        [nama, harga, deskripsi, kategori, kuantitas, url, _idBarang]
      );

      await koneksi.close();

      if (hasil.affectedRows == 1) {
        _nama = nama;
        _harga = harga;
        _deskripsi = deskripsi;
        _kategori = kategori;
        _kuantitas = kuantitas;
        _url = url;

        return true;
      } else if (hasil.affectedRows == 0) {
        throw(Exception("Tidak Menemukan Barang yang Ingin Di-update !"));
      } else {
        throw(Exception("Ada Kesalahan!"));
      }
    }
  }

  Future<bool> delete() async {
    if (_idBarang == null && _nama == null && _harga == null && _deskripsi == null && _kategori == null && _kuantitas == null && _url == null) {
      throw(Exception("Tidak Ada Data Barang !"));
    } else {
      MySqlConnection koneksi = await MySqlConnection.connect(settingsDB);

      Results hasil = await koneksi.query("DELETE FROM barang WHERE id = ?", [_idBarang]);

      await koneksi.close();

      if (hasil.affectedRows == 1) {
        _idBarang = _nama = _harga = _deskripsi = _kategori = _kuantitas = _url = null;

        return true;
      } else if (hasil.affectedRows == 0) {
        throw(Exception("Tidak Menemukan Barang yang Ingin Dihapus !"));
      } else {
        throw(Exception("Ada Kesalahan!"));
      }
    }
  }

  Map<String, dynamic> showDetail() {
    Map<String, dynamic> detail = {
      "ID": _idBarang,
      "Nama": _nama,
      "Harga": _harga,
      "Deskripsi": _deskripsi,
      "Kategori": _kategori,
      "Kuantitas": _kuantitas
    };

    if (_url != null) {
      detail["URL"] = _url;
    }

    return detail;
  }

}