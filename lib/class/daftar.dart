import 'package:daftar_belanja/class/barang.dart';
import 'package:daftar_belanja/database_settings.dart';
import 'package:mysql1/mysql1.dart';

abstract class Daftar {
  int? _idDaftar;
  String? _namaDaftar;
  String? _dateCreated;
  String? _dateUpdated;

  String get namaDaftar => _namaDaftar!;

  Daftar();
  Daftar.init(this._idDaftar, this._namaDaftar, this._dateCreated, this._dateUpdated);

  Future<List<Barang>> getAllBarang();
  Future<bool> tambahBarang(String nama, int harga, String deskripsi, String kategori, int kuantitas, [String? url]);
  Future<bool> update( String nama);
  Future<bool> delete();

  List getAttributes() {
    return [_namaDaftar, _dateCreated, _dateUpdated];
  }
}

class DaftarBelanja extends Daftar {
  DaftarBelanja();
  DaftarBelanja.init(int? idDaftar, String? namaDaftar, String? dateCreated, String? dateUpdated) : super.init(idDaftar, namaDaftar, dateCreated, dateUpdated);

  @override
  Future<List<Barang>> getAllBarang() async {
    MySqlConnection koneksi = await MySqlConnection.connect(settingsDB);

    Results hasil = await koneksi.query("SELECT * FROM barang WHERE daftar_id = ?", [_idDaftar]);

    await koneksi.close();

    List<Barang> listBarang = [];

    for (var data in hasil) {
      Barang barang = Barang.init(data[0], data[1], data[2], data[3].toString(), data[4], data[5], data[6].toString());

      listBarang.add(barang);
    }

    return listBarang;
  }

  @override
  Future<bool> tambahBarang(String nama, int harga, String? deskripsi, String kategori, int kuantitas, [String? url]) async {
    MySqlConnection koneksi = await MySqlConnection.connect(settingsDB);

    Results hasil = await koneksi.query("INSERT INTO barang (nama, harga, deskripsi, kategori, kuantitas, url, daftar_id) VALUES (?, ?, ?, ?, ?, ?, ?)",
      [nama, harga, deskripsi, kategori, kuantitas, url, _idDaftar]
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
      total += barang.kuantitas * barang.harga;
    }

    return total;
  }

  @override
  Future<bool> update(String nama) async {
    if (_idDaftar == null && _namaDaftar == null && _dateCreated == null && _dateUpdated == null) {
        throw(Exception("Tidak Ada Daftar Barang !"));
    } else {
        MySqlConnection koneksi = await MySqlConnection.connect(settingsDB);

        Results hasil = await koneksi.query("UPDATE daftar_barang SET nama_daftar = ? WHERE id = ?",
            [nama, _idDaftar]
        );

        Results date = await koneksi.query("SELECT date_updated FROM daftar_barang WHERE id = ?", [_idDaftar]);

        await koneksi.close();

        if (hasil.affectedRows == 1) {
            _namaDaftar = nama;
            _dateUpdated = date.fields[0].toString();

            return true;
        } else if (hasil.affectedRows == 0) {
        throw(Exception("Tidak Menemukan Daftar Belanja yang Ingin Di-update !"));
      } else {
        throw(Exception("Ada Kesalahan!"));
      }
    }
  }

  @override
  Future<bool> delete() async {
    if (_idDaftar == null && _namaDaftar == null && _dateCreated == null && _dateUpdated == null) {
      throw(Exception("Tidak Ada Daftar Belanja !"));
    } else {
      MySqlConnection koneksi = await MySqlConnection.connect(settingsDB);

      Results hasil = await koneksi.query("DELETE FROM daftar_barang WHERE id = ?", [_idDaftar]);

      await koneksi.query("DELETE FROM barang WHERE daftar_id = ?", [_idDaftar]);

      await koneksi.close();

      if (hasil.affectedRows == 1) {
        _idDaftar = _namaDaftar = _dateCreated = _dateUpdated = null;

        return true;
      }  else if (hasil.affectedRows == 0) {
        throw(Exception("Tidak Menemukan Daftar Belanja yang Ingin Dihapus !"));
      } else {
        throw(Exception("Ada Kesalahan!"));
      }
    }
  }
}

class DaftarProduk extends Daftar {
  DaftarProduk();
  DaftarProduk.init(int? idDaftar, String? namaDaftar, String? dateCreated, String? dateUpdated) : super.init(idDaftar, namaDaftar, dateCreated, dateUpdated);

  @override
  Future<List<Barang>> getAllBarang() async {
    MySqlConnection koneksi = await MySqlConnection.connect(settingsDB);

    Results hasil = await koneksi.query("SELECT * FROM barang WHERE daftar_id = ?", [_idDaftar]);

    await koneksi.close();

    List<Barang> listBarang = [];

    for (var data in hasil) {
      Barang barang = Barang.init(data[0], data[1], data[2], data[3].toString(), data[4], data[5], data[6].toString());

      listBarang.add(barang);
    }

    return listBarang;
  }

  @override
  Future<bool> tambahBarang(String nama, int harga, String? deskripsi, String kategori, int kuantitas, [String? url]) async {
    MySqlConnection koneksi = await MySqlConnection.connect(settingsDB);

    Results hasil = await koneksi.query("INSERT INTO barang (nama, harga, deskripsi, kategori, kuantitas, url, daftar_id) VALUES (?, ?, ?, ?, ?, ?, ?)",
      [nama, harga, deskripsi, kategori, kuantitas, url, _idDaftar]
    );

    await koneksi.close();

    if (hasil.insertId != null) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Future<bool> update(String nama) async {
    if (_idDaftar == null && _namaDaftar == null && _dateCreated == null && _dateUpdated == null) {
        throw(Exception("Tidak Ada Daftar Barang !"));
    } else {
        MySqlConnection koneksi = await MySqlConnection.connect(settingsDB);

        Results hasil = await koneksi.query("UPDATE daftar_barang SET nama_daftar = ? WHERE id = ?",
            [nama, _idDaftar]
        );

        Results date = await koneksi.query("SELECT date_updated FROM daftar_barang WHERE id = ?", [_idDaftar]);

        await koneksi.close();

        if (hasil.affectedRows == 1) {
            _namaDaftar = nama;
            _dateUpdated = date.fields[0].toString();

            return true;
        } else if (hasil.affectedRows == 0) {
        throw(Exception("Tidak Menemukan Daftar Belanja yang Ingin Di-update !"));
      } else {
        throw(Exception("Ada Kesalahan!"));
      }
    }
  }

  @override
  Future<bool> delete() async {
    if (_idDaftar == null && _namaDaftar == null && _dateCreated == null && _dateUpdated == null) {
      throw(Exception("Tidak Ada Daftar Belanja !"));
    } else {
      MySqlConnection koneksi = await MySqlConnection.connect(settingsDB);

      Results hasil = await koneksi.query("DELETE FROM daftar_barang WHERE id = ?", [_idDaftar]);

      await koneksi.query("DELETE FROM barang WHERE daftar_id = ?", [_idDaftar]);

      await koneksi.close();

      if (hasil.affectedRows == 1) {
        _idDaftar = _namaDaftar = _dateCreated = _dateUpdated = null;

        return true;
      }  else if (hasil.affectedRows == 0) {
        throw(Exception("Tidak Menemukan Daftar Belanja yang Ingin Dihapus !"));
      } else {
        throw(Exception("Ada Kesalahan!"));
      }
    }
  }

}
