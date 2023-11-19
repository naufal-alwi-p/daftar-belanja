import 'package:daftar_belanja/class/barang.dart';
import 'package:daftar_belanja/class/daftar.dart';
import 'package:daftar_belanja/class/user.dart';
import 'package:dart_console/dart_console.dart';
import 'package:interact/interact.dart';
import 'package:string_validator/string_validator.dart' as validator;

Console console = Console();

/// Tampilan Header Aplikasi
void header(String pageName, {String? error, String? loggedUser}) {
  console.setForegroundColor(ConsoleColor.brightGreen);
  console.setTextStyle(bold: true);

  console.writeLine("APLIKASI DAFTAR BELANJA", TextAlignment.center);

  console.resetColorAttributes();
  console.setTextStyle(bold: false);

  console.writeLine(pageName, TextAlignment.center);

  if (loggedUser != null) {
    console.writeLine("Login as $loggedUser", TextAlignment.right);
  }

  if (error != null) {
    console.setForegroundColor(ConsoleColor.yellow);
    console.writeLine(error);
    console.writeLine("");
    console.resetColorAttributes();
  }
}

int home() {
  header("Main Menu");

  List<String> opsi = ["User", "Seller", "Exit"];

  int hasil = Select(prompt: "Ingin Login Sebagai ?", options: opsi).interact();

  return hasil;
}

int menuLogin({String? error}) {
  header("Login Menu", error: error);

  List<String> opsi = ["Login", "Buat Akun", "Kembali"];

  int hasil = Select(prompt: "Pilih Opsi", options: opsi).interact();

  console.clearScreen();

  return hasil;
}

List loginPage() {
  late String email, password;
  bool? confirmation;

  while (confirmation != true) {
    header("Login Form");

    email = Input(
        prompt: "Email:",
        validator: (email) {
          if (validator.isEmail(email)) {
            return true;
          } else {
            throw (ValidationError("Isi email dengan benar !"));
          }
        }).interact();
        
    password = Password(prompt: "Password:").interact();

    confirmation = Confirm(prompt: "Submit?", waitForNewLine: true).interact();

    if (confirmation != true) {
      console.clearScreen();
    }
  }

  console.clearScreen();

  return [email, password];
}

List createAccountPage(User user) {
  late String nama, nomorTelepon, alamat, email, password;
  String? namaToko;
  bool? confirmation;

  while (confirmation != true) {
    header("Create Account Form");

    console.setTextStyle(bold: true);
    console.writeLine("Masukkan Data Berikut");
    console.setTextStyle(bold: false);

    nama = Input(
        prompt: "Nama:",
        validator: (nama) {
          if (validator.isAlpha(validator.blacklist(nama, ' '))) {
            return true;
          } else {
            throw (ValidationError("Nama Harus Terdiri dari huruf saja"));
          }
        }).interact();

    if (user.runtimeType == Seller) {
      namaToko = Input(
          prompt: "Nama Toko:",
          validator: (namaToko) {
            if (namaToko == '') {
              throw (ValidationError("Nama Toko Wajib Diisi"));
            } else {
              return true;
            }
          }).interact();
    }

    nomorTelepon = Input(
        prompt: "Nomor Telepon:",
        validator: (nomorTelepon) {
          if (validator.isNumeric(nomorTelepon)) {
            return true;
          } else {
            throw (ValidationError("Isikan Nomor Telepon"));
          }
        }).interact();

    alamat = Input(
        prompt: "Alamat:",
        validator: (alamat) {
          if (validator.isAscii(alamat)) {
            return true;
          } else {
            throw (ValidationError("Isi Alamat Dengan Benar !"));
          }
        }).interact();

    email = Input(
        prompt: "Email:",
        validator: (email) {
          if (validator.isEmail(email)) {
            return true;
          } else {
            throw (ValidationError("Isi email dengan benar !"));
          }
        }).interact();

    password = Password(
      prompt: "Password:",
      confirmation: true,
      confirmPrompt: "Konfirmasi Password:",
    ).interact();

    confirmation = Confirm(prompt: "Submit?", waitForNewLine: true).interact();

    if (confirmation != true) {
      console.clearScreen();
    }
  }

  console.clearScreen();

  return (namaToko == null)
      ? [nama, password, nomorTelepon, alamat, email]
      : [nama, password, nomorTelepon, alamat, email, namaToko];
}

Future<int> homepage({CommonUser? user, Seller? seller, DaftarProduk? daftarProduk, String? error}) async {
  late String pageName, userName;
  late List<String> opsi;

  Table tabel = Table()
    ..borderStyle = BorderStyle.square
    ..borderType = BorderType.grid
    ..headerStyle = FontStyle.bold;

  if (user != null) {
    tabel
      ..title = "List Daftar Belanja"
      ..insertColumn(header: 'No.')
      ..insertColumn(header: 'Nama Daftar', alignment: TextAlignment.center)
      ..insertColumn(header: 'Date Created', alignment: TextAlignment.center)
      ..insertColumn(header: 'Date Update', alignment: TextAlignment.center);

    pageName = "User Homepage";
    opsi = ["Pilih Daftar Belanja", "Buat Daftar Belanja", "Show My Profile"];
    userName = user.nama;

    List<DaftarBelanja> daftarBelanja = await user.getAllDaftarBelanja();
    int index = 1;

    for (DaftarBelanja daftar in daftarBelanja) {
      List row = daftar.getAttributes();

      tabel.insertRow([index++, row[0], row[1], row[2]]);
    }
  } else if (seller != null && daftarProduk != null) {
    tabel
      ..title = "Daftar Produk"
      ..insertColumn(header: "No.")
      ..insertColumn(header: "Nama", alignment: TextAlignment.center)
      ..insertColumn(header: "Harga", alignment: TextAlignment.center)
      ..insertColumn(header: "Kategori", alignment: TextAlignment.center)
      ..insertColumn(header: "Stok", alignment: TextAlignment.center)
      ..insertColumn(header: "URL", alignment: TextAlignment.center);

    pageName = "Seller Homepage";
    opsi = ["Tambah Produk", "Tampilkan Detail Produk", "Show My Profile"];
    userName = seller.nama;

    List<Barang> listBarang = await daftarProduk.getAllBarang();
    int index = 1;

    for (Barang barang in listBarang) {
      Map data = barang.showDetail();

      List<Object> row = [
        index++,
        data['Nama'],
        data['Harga'],
        data['Kategori'],
        data['Kuantitas'],
        data['URL'].toString()
      ];

      tabel.insertRow(row);
    }
  }

  header(pageName, error: error, loggedUser: userName);

  print(tabel);

  int hasil = Select(prompt: "Opsi", options: opsi).interact();

  console.clearScreen();

  return hasil;
}

int showProfile(User user, {String? error}) {
  late String pageName;
  late int opsi;
  bool? confirmation;

  Table tabel = Table()
    ..borderStyle = BorderStyle.square
    ..borderType = BorderType.grid
    ..showHeader = false
    ..insertColumn()
    ..insertColumn();

  user.getAllAttributes().forEach((key, value) {
    tabel.insertRow([key, value]);
  });

  if (user.runtimeType == CommonUser) {
    pageName = tabel.title = "User Profile";
  } else {
    pageName = tabel.title = "Seller Profile";
  }

  while (confirmation != true) {
    header(pageName, error: error);

    print(tabel);

    opsi = Select(
            prompt: 'Opsi',
            options: ["Kembali", "Edit Profile", "Logout", "Hapus Akun"]).interact();

    if (opsi == 2 || opsi == 3) {
      confirmation = Confirm(prompt: "Apakah Kamu Yakin?", waitForNewLine: true)
          .interact();
    } else {
      confirmation = true;
    }

    console.clearScreen();
  }

  return opsi;
}

List updateProfileForm(User user) {
  late String nama, nomorTelepon, alamat, email, oldPassword, newPassword;
  String? namaToko;
  bool? confirmationSubmit;
  late bool confirmationChangePassword;

  Map<String, dynamic> data = user.getAllAttributes();

  while (confirmationSubmit != true) {
    header("Update Account Profile");

    nama = Input(
            prompt: "Nama:",
            validator: (nama) {
              if (validator.isAlpha(validator.blacklist(nama, ' '))) {
                return true;
              } else {
                throw (ValidationError("Nama Harus Terdiri dari huruf saja"));
              }
            },
            initialText: data["Nama"]).interact();

    if (user.runtimeType == Seller) {
      namaToko = Input(
              prompt: "Nama Toko:",
              validator: (namaToko) {
                if (namaToko == '') {
                  throw (ValidationError("Nama Toko Wajib Diisi"));
                } else {
                  return true;
                }
              },
              initialText: data["Nama Toko"]).interact();
    }

    nomorTelepon = Input(
            prompt: "Nomor Telepon:",
            validator: (nomorTelepon) {
              if (validator.isNumeric(nomorTelepon)) {
                return true;
              } else {
                throw (ValidationError("Isikan Nomor Telepon"));
              }
            },
            initialText: data["Nomor Telepon"]).interact();

    alamat = Input(
            prompt: "Alamat:",
            validator: (alamat) {
              if (validator.isAscii(alamat)) {
                return true;
              } else {
                throw (ValidationError("Isi Alamat Dengan Benar !"));
              }
            },
            initialText: data["Alamat"]).interact();

    email = Input(
            prompt: "Email:",
            validator: (email) {
              if (validator.isEmail(email)) {
                return true;
              } else {
                throw (ValidationError("Isi email dengan benar !"));
              }
            },
            initialText: data["Email"]).interact();

    oldPassword = Password(prompt: "Password:").interact();

    confirmationChangePassword = Confirm(prompt: "Ubah Password ?", waitForNewLine: true).interact();

    if (confirmationChangePassword) {
      console.writeLine("");

      newPassword = Password(
              prompt: "Masukkan Password Baru:",
              confirmation: true,
              confirmPrompt: "Konfirmasi Password Baru:").interact();

      console.writeLine("");
    }

    confirmationSubmit = Confirm(prompt: "Submit?", waitForNewLine: true).interact();

    if (confirmationSubmit != true) {
      console.clearScreen();
    }
  }

  console.clearScreen();

  List<String?> result = [nama, oldPassword, nomorTelepon, alamat, email];

  result.add((confirmationChangePassword) ? newPassword : null);

  result.add((namaToko == null) ? null : namaToko);

  return result;
}

String buatDaftarBelanjaForm() {
  late String namaDaftar;
  bool? confirmation;

  while (confirmation != true) {
    header("Form Daftar Belanja");

    namaDaftar = Input(prompt: "Nama Daftar:").interact();

    confirmation = Confirm(prompt: "Submit?", waitForNewLine: true).interact();

    if (confirmation != true) {
      console.clearScreen();
    }
  }

  console.clearScreen();

  return namaDaftar;
}

Future<DaftarBelanja?> selectList(CommonUser user) async {
  Table tabel = Table()
    ..borderStyle = BorderStyle.square
    ..borderType = BorderType.grid
    ..headerStyle = FontStyle.bold
    ..title = "List Daftar Belanja"
    ..insertColumn(header: "No.")
    ..insertColumn(header: 'Nama Daftar', alignment: TextAlignment.center)
    ..insertColumn(header: 'Date Created', alignment: TextAlignment.center)
    ..insertColumn(header: 'Date Update', alignment: TextAlignment.center);

  List<DaftarBelanja> daftarBelanja = await user.getAllDaftarBelanja();
  List<String> opsi = [];
  int index = 1;

  for (var daftar in daftarBelanja) {
    List row = daftar.getAttributes();

    tabel.insertRow([index, row[0], row[1], row[2]]);

    opsi.add("${index++}. ${row[0]}");
  }

  opsi.add("Kembali");

  header("Pilih Daftar", loggedUser: user.nama);

  print(tabel);

  int hasil = Select(prompt: "Pilih Daftar Belanja", options: opsi).interact();

  console.clearScreen();

  return (hasil == (opsi.length - 1)) ? null : daftarBelanja[hasil];
}

Future<int> spesificList(CommonUser user, DaftarBelanja daftarBelanja, String? err) async {
  Table tabel = Table()
    ..borderStyle = BorderStyle.square
    ..borderType = BorderType.grid
    ..headerStyle = FontStyle.bold
    ..title = daftarBelanja.namaDaftar
    ..insertColumn(header: "No.")
    ..insertColumn(header: "Nama", alignment: TextAlignment.center)
    ..insertColumn(header: "Harga", alignment: TextAlignment.center)
    ..insertColumn(header: "Kategori", alignment: TextAlignment.center)
    ..insertColumn(header: "Kuantitas", alignment: TextAlignment.center)
    ..insertColumn(header: "URL", alignment: TextAlignment.center);

  List<Barang> listBarang = await daftarBelanja.getAllBarang();
  int index = 1;
  int totalHarga = await daftarBelanja.hitungTotalHarga();
  bool? confirmation;
  late int hasil;

  for (Barang barang in listBarang) {
    Map data = barang.showDetail();

    List<Object> row = [
      index++,
      data['Nama'],
      data['Harga'],
      data['Kategori'],
      data['Kuantitas'],
      data['URL'].toString()
    ];

    tabel.insertRow(row);
  }

  while (confirmation != true) {
    header("Daftar Belanja", loggedUser: user.nama, error: err);

    print(tabel);

    console.setTextStyle(bold: true);
    console.setForegroundColor(ConsoleColor.blue);
    console.write("Total Harga: Rp ");
    console.setTextStyle(bold: false);
    console.resetColorAttributes();
    console.writeLine(totalHarga);

    List<String> opsi = [
      "Tambah Barang",
      "Lihat Detail Barang",
      "Edit Tabel",
      "Hapus Tabel",
      "Kembali"
    ];

    hasil = Select(prompt: "Opsi", options: opsi).interact();

    if (hasil == 0) {
      confirmation = Confirm(
              prompt: "Cari Barang dari Seller atau Input Sendiri?",
              waitForNewLine: true).interact();

      if (confirmation) {
        hasil = 5;
      }
      confirmation = true;
    } else if (hasil == 3) {
      confirmation = Confirm(
              prompt: "Apakah Kamu Yakin? Semua List Barang Kamu Akan Terhapus",
              waitForNewLine: true).interact();
    } else {
      confirmation = true;
    }

    if (confirmation == false) {
      console.clearScreen();
    }
  }

  console.clearScreen();

  return hasil;
}

List tambahBarangForm({CommonUser? user, Seller? seller}) {
  late String nama, harga, kategori, kuantitas;
  String? deskripsi, url;
  late int angkaHarga, angkaKuantitas;
  bool? confirmationUrl, confirmationSubmit;

  if (user != null) {
    while (confirmationSubmit != true) {
      header("Tambah Barang Form", loggedUser: user.nama);

      nama = Input(prompt: "Nama Barang:").interact();

      harga = Input(
          prompt: "Harga Barang:",
          validator: (harga) {
            if (validator.isNumeric(harga)) {
              return true;
            } else {
              throw (ValidationError("Isi dengan angka"));
            }
          }).interact();

      angkaHarga = int.parse(harga);

      deskripsi = Input(prompt: "Deskripsi Barang").interact();
      if (deskripsi == "") {
        deskripsi = null;
      }

      kategori = Input(prompt: "Kategori Barang").interact();

      kuantitas = Input(
          prompt: "Kuantitas Barang",
          validator: (kuantitas) {
            if (validator.isNumeric(kuantitas)) {
              return true;
            } else {
              throw (ValidationError("Isi dengan angka"));
            }
          }).interact();

      angkaKuantitas = int.parse(kuantitas);

      confirmationUrl =
          Confirm(prompt: "Apakah ini barang online?", waitForNewLine: true)
              .interact();

      if (confirmationUrl) {
        url = Input(prompt: "URL Barang").interact();
      }

      confirmationSubmit = Confirm(prompt: "Submit", waitForNewLine: true).interact();

      if (confirmationSubmit != true) {
        console.clearScreen();
      }
    }
  }
  if (seller != null) {
    while (confirmationSubmit != true) {
      header("Tambah Produk Form", loggedUser: seller.nama);

      nama = Input(prompt: "Nama Produk:").interact();

      harga = Input(
          prompt: "Harga Produk:",
          validator: (harga) {
            if (validator.isNumeric(harga)) {
              return true;
            } else {
              throw (ValidationError("Isi dengan angka"));
            }
          }).interact();

      angkaHarga = int.parse(harga);

      deskripsi = Input(prompt: "Deskripsi Produk").interact();
      if (deskripsi == "") {
        deskripsi = null;
      }

      kategori = Input(prompt: "Kategori Produk").interact();

      kuantitas = Input(
          prompt: "Stok Produk",
          validator: (kuantitas) {
            if (validator.isNumeric(kuantitas)) {
              return true;
            } else {
              throw (ValidationError("Isi dengan angka"));
            }
          }).interact();

      angkaKuantitas = int.parse(kuantitas);

      confirmationUrl = Confirm(
              prompt: "Apakah produk anda tersedia secara online?",
              waitForNewLine: true).interact();

      if (confirmationUrl) {
        url = Input(prompt: "URL Produk").interact();
      }

      confirmationSubmit = Confirm(prompt: "Submit", waitForNewLine: true).interact();

      if (confirmationSubmit != true) {
        console.clearScreen();
      }
    }
  }

  console.clearScreen();

  return [nama, angkaHarga, deskripsi, kategori, angkaKuantitas, url];
}

String editTabelForm({required CommonUser user, required DaftarBelanja daftarBelanja}) {
  header("Edit Daftar Belanja Form", loggedUser: user.nama);

  late String namaDaftar;
  bool? confirmation;

  List data = daftarBelanja.getAttributes();

  while (confirmation != true) {
    namaDaftar = Input(prompt: "Nama Daftar:", initialText: data[0]).interact();

    confirmation = Confirm(prompt: "Submit?", waitForNewLine: true).interact();

    if (confirmation != true) {
      console.clearScreen();
    }
  }

  console.clearScreen();

  return namaDaftar;
}

Future<Barang?> selectDetailBarang({CommonUser? user, Seller? seller, DaftarBelanja? daftarBelanja, DaftarProduk? daftarProduk}) async {
  Table tabel = Table()
    ..borderStyle = BorderStyle.square
    ..borderType = BorderType.grid
    ..headerStyle = FontStyle.bold
    ..insertColumn(header: "No.")
    ..insertColumn(header: "Nama", alignment: TextAlignment.center)
    ..insertColumn(header: "Harga", alignment: TextAlignment.center)
    ..insertColumn(header: "Kategori", alignment: TextAlignment.center)
    ..insertColumn(header: "Kuantitas", alignment: TextAlignment.center)
    ..insertColumn(header: "URL", alignment: TextAlignment.center);

  late String pageName, userName;
  late List<Barang> listBarang;
  List<String> opsi = [];
  int index = 1;

  if (user != null && daftarBelanja != null) {
    tabel.title = daftarBelanja.namaDaftar;

    pageName = "Detail Barang";
    userName = user.nama;

    listBarang = await daftarBelanja.getAllBarang();

    for (Barang barang in listBarang) {
      Map data = barang.showDetail();

      opsi.add("$index. ${data['Nama']}");

      List<Object> row = [
        index++,
        data['Nama'],
        data['Harga'],
        data['Kategori'],
        data['Kuantitas'],
        data['URL'].toString()
      ];

      tabel.insertRow(row);
    }

    opsi.add("Kembali");
  } else if (seller != null && daftarProduk != null) {
    tabel.title = "Daftar Produk";

    pageName = "Detail Produk";
    userName = seller.nama;

    listBarang = await daftarProduk.getAllBarang();

    for (Barang barang in listBarang) {
      Map data = barang.showDetail();

      opsi.add("$index. ${data['Nama']}");

      List<Object> row = [
        index++,
        data['Nama'],
        data['Harga'],
        data['Kategori'],
        data['Kuantitas'],
        data['URL'].toString()
      ];

      tabel.insertRow(row);
    }

    opsi.add("Kembali");
  }

  header(pageName, loggedUser: userName);

  print(tabel);

  int hasil = Select(prompt: "Pilih Barang", options: opsi).interact();

  console.clearScreen();

  return (hasil == (opsi.length - 1)) ? null : listBarang[hasil];
}

int spesificBarang(User user, Barang barang, String? err) {
  Table tabel = Table()
    ..borderStyle = BorderStyle.square
    ..borderType = BorderType.grid
    ..showHeader = false
    ..insertColumn()
    ..insertColumn();

  late String pageName, userName;
  late int hasil;
  bool? confirmation;
  late List<String> opsi;

  if (user.runtimeType == CommonUser) {
    tabel.title = "Detail Barang";

    pageName = "Detail Barang";
    userName = user.nama;

    opsi = ["Edit Barang", "Hapus Barang", "Kembali"];
  } else if (user.runtimeType == Seller) {
    tabel.title = "Detail Produk";

    pageName = "Detail Produk";
    userName = user.nama;

    opsi = ["Edit Produk", "Hapus Produk", "Kembali"];
  }

  Map<String, dynamic> data = barang.showDetail();

  data.forEach((key, value) {
    tabel.insertRow([key, value.toString()]);
  });

  while (confirmation != true) {
    header(pageName, loggedUser: userName, error: err);

    print(tabel);

    hasil = Select(prompt: "Opsi", options: opsi).interact();

    if (hasil == 1) {
      confirmation = Confirm(prompt: "Apakah Kamu Yakin?", waitForNewLine: true).interact();
    } else {
      confirmation = true;
    }

    if (confirmation == false) {
      console.clearScreen();
    }
  }

  console.clearScreen();

  return hasil;
}

List updateDataBarangForm(User user, Barang barang) {
  Map<String, dynamic> dataBarang = barang.showDetail();

  late String nama, harga, kategori, kuantitas;
  String? deskripsi, url;
  late int angkaHarga, angkaKuantitas;
  bool? confirmationUrl, confirmationSubmit;

  if (user.runtimeType == CommonUser) {
    while (confirmationSubmit != true) {
      header("Update Data Barang", loggedUser: user.nama);

      nama = Input(prompt: "Nama Barang:", initialText: dataBarang['Nama']).interact();

      harga = Input(
              prompt: "Harga Barang:",
              validator: (harga) {
                if (validator.isNumeric(harga)) {
                  return true;
                } else {
                  throw (ValidationError("Isikan Angka"));
                }
              },
              initialText: dataBarang['Harga'].toString()).interact();

      angkaHarga = int.parse(harga);

      deskripsi = Input(
              prompt: "Deskripsi Barang",
              initialText: (dataBarang['Deskripsi'] == 'null') ? '' : dataBarang['Deskripsi']).interact();

      if (deskripsi == "") {
        deskripsi = null;
      }

      kategori = Input(prompt: "Kategori Barang", initialText: dataBarang['Kategori']).interact();

      kuantitas = Input(
              prompt: "Kuantitas Barang",
              validator: (kuantitas) {
                if (validator.isNumeric(kuantitas)) {
                  return true;
                } else {
                  throw (ValidationError("Isikan Angka"));
                }
              },
              initialText: dataBarang['Kuantitas'].toString()).interact();

      angkaKuantitas = int.parse(kuantitas);

      if (dataBarang['URL'] == 'null') {
        confirmationUrl = Confirm(prompt: "Apakah ini barang online?", waitForNewLine: true).interact();

        if (confirmationUrl) {
          url = Input(prompt: "URL Barang").interact();

          url = (url == '') ? null : url;
        }
      } else {
        url = Input(prompt: "URL Barang", initialText: dataBarang['URL']).interact();

        url = (url == '') ? null : url;
      }

      confirmationSubmit = Confirm(prompt: "Submit", waitForNewLine: true).interact();

      if (confirmationSubmit != true) {
        console.clearScreen();
      }
    }
  } else if (user.runtimeType == Seller) {
    while (confirmationSubmit != true) {
      header("Update Data Produk", loggedUser: user.nama);

      nama = Input(prompt: "Nama Produk:", initialText: dataBarang['Nama']).interact();

      harga = Input(
              prompt: "Harga Produk:",
              validator: (harga) {
                if (validator.isNumeric(harga)) {
                  return true;
                } else {
                  throw (ValidationError("Isikan Angka"));
                }
              },
              initialText: dataBarang['Harga'].toString()).interact();

      angkaHarga = int.parse(harga);

      deskripsi = Input(
              prompt: "Deskripsi Produk",
              initialText: (dataBarang['Deskripsi'] == 'null') ? '' : dataBarang['Deskripsi']).interact();

      if (deskripsi == "") {
        deskripsi = null;
      }

      kategori = Input(prompt: "Kategori Produk", initialText: dataBarang['Kategori']).interact();

      kuantitas = Input(
              prompt: "Stok Produk",
              validator: (kuantitas) {
                if (validator.isNumeric(kuantitas)) {
                  return true;
                } else {
                  throw (ValidationError("Isikan Angka"));
                }
              },
              initialText: dataBarang['Kuantitas'].toString()).interact();

      angkaKuantitas = int.parse(kuantitas);

      if (dataBarang['URL'] == 'null') {
        confirmationUrl = Confirm(
                prompt: "Apakah produk anda tersedia secara online?",
                waitForNewLine: true).interact();

        if (confirmationUrl) {
          url = Input(prompt: "URL Produk").interact();

          url = (url == '') ? null : url;
        }
      } else {
        url = Input(prompt: "URL Produk", initialText: dataBarang['URL']).interact();

        url = (url == '') ? null : url;
      }

      confirmationSubmit = Confirm(prompt: "Submit", waitForNewLine: true).interact();

      if (confirmationSubmit != true) {
        console.clearScreen();
      }
    }
  }

  console.clearScreen();

  return [nama, angkaHarga, deskripsi, kategori, angkaKuantitas, url];
}

Future<List?> selectSeller(CommonUser user, List<Map<String, dynamic>> daftarSeller) async {
  Table tabel = Table()
    ..borderStyle = BorderStyle.square
    ..borderType = BorderType.grid
    ..headerStyle = FontStyle.bold
    ..title = "Daftar Toko"
    ..insertColumn(header: "No.")
    ..insertColumn(header: "Nama Toko", alignment: TextAlignment.center)
    ..insertColumn(header: "No. Telepon", alignment: TextAlignment.center)
    ..insertColumn(header: "Alamat", alignment: TextAlignment.center);

  List<String> opsi = [];
  int index = 1;

  for (Map<String, dynamic> seller in daftarSeller) {
    opsi.add("$index. ${seller['nama_toko']}");

    tabel.insertRow([
      index++,
      seller['nama_toko'],
      seller['nomor_telepon'],
      seller['alamat']
    ]);
  }

  opsi.add("Kembali");

  header("Pilih Toko", loggedUser: user.nama);

  print(tabel);

  int hasil = Select(prompt: "Pilih Toko", options: opsi).interact();

  console.clearScreen();

  if (hasil == opsi.length - 1) {
    console.clearScreen();
    return null;
  } else {
    Seller seller = Seller();
    Map<String, dynamic> dataSeller = daftarSeller[hasil];

    DaftarProduk daftarProduk = await seller.login(dataSeller['email'], dataSeller['password']);

    console.clearScreen();

    return [seller, daftarProduk];
  }
}

Future<Barang?> selectBarangFromSeller(CommonUser user, Seller seller, DaftarProduk daftarProduk) async {
  Table tabel = Table()
    ..borderStyle = BorderStyle.square
    ..borderType = BorderType.grid
    ..headerStyle = FontStyle.bold
    ..title = "Produk Toko ${seller.nama}"
    ..insertColumn(header: "No.")
    ..insertColumn(header: "Nama", alignment: TextAlignment.center)
    ..insertColumn(header: "Harga", alignment: TextAlignment.center)
    ..insertColumn(header: "Kategori", alignment: TextAlignment.center)
    ..insertColumn(header: "Kuantitas", alignment: TextAlignment.center)
    ..insertColumn(header: "URL", alignment: TextAlignment.center);

  List<Barang> listBarang = await daftarProduk.getAllBarang();
  List<String> opsi = [];
  int index = 1;

  for (Barang barang in listBarang) {
    Map data = barang.showDetail();

    opsi.add("$index. ${data['Nama']}");

    List<Object> row = [
      index++,
      data['Nama'],
      data['Harga'],
      data['Kategori'],
      data['Kuantitas'],
      data['URL'].toString()
    ];

    tabel.insertRow(row);
  }

  opsi.add("Kembali");

  header("Pilih Produk", loggedUser: user.nama);

  print(tabel);

  int hasil = Select(prompt: "Pilih Produk", options: opsi).interact();

  console.clearScreen();

  return (hasil == (opsi.length - 1)) ? null : listBarang[hasil];
}

List? detailBarangFromSeller(CommonUser user, Barang barang) {
  Table tabel = Table()
    ..borderStyle = BorderStyle.square
    ..borderType = BorderType.grid
    ..showHeader = false
    ..title = "Detail Produk"
    ..insertColumn()
    ..insertColumn();

  Map<String, dynamic> data = barang.showDetail();

  bool? confirmation;
  late int hasil;
  late String kuantitas;

  data.forEach((key, value) {
    tabel.insertRow([key, value.toString()]);
  });

  while (confirmation != true) {
    header("Detail Barang", loggedUser: user.nama);

    print(tabel);

    hasil = Select(prompt: "Opsi", options: ["Pilih Produk Ini", "Kembali"]).interact();

    if (hasil == 0) {
      kuantitas = Input(
          prompt: "Jumlah yang ingin dibeli:",
          validator: (kuantitas) {
            if (validator.isNumeric(kuantitas)) {
              int angka = int.parse(kuantitas);

              if (angka < 1) {
                throw (ValidationError("Input minimal satu !"));
              }

              if (angka > data["Kuantitas"]) {
                throw (ValidationError("Stok barang tidak mencukupi"));
              }

              return true;
            } else {
              throw (ValidationError("Input jumlah harus angka !"));
            }
          }).interact();

      confirmation =
          Confirm(prompt: "Submit?", waitForNewLine: true).interact();
    } else {
      console.clearScreen();

      return null;
    }

    if (confirmation == false) {
      console.clearScreen();
    }
  }

  console.clearScreen();

  return [data['Nama'], data['Harga'], data['Deskripsi'], data['Kategori'], int.parse(kuantitas), data["URL"]];
}
