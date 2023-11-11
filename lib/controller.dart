import 'package:daftar_belanja/class/barang.dart';
import 'package:daftar_belanja/class/daftar.dart';
import 'package:daftar_belanja/class/user.dart';
import 'package:daftar_belanja/display.dart';

/// Mulai Jalankan Aplikasi
Future<void> start() async {
  console.clearScreen();
  int? opsi;

  while (opsi != 2) {
    opsi = home();

    if (opsi != 2) {
      console.clearScreen();
    } else {
      console.writeLine("Good Bye");
      return;
    }

    switch (opsi) {
      case 0:
        await commonUserRoutine();
        break;
      case 1:
        await sellerRoutine();
        break;
    }
  }
}

/// Rute Untuk Common User
Future<void> commonUserRoutine() async {
  String? err;
  CommonUser user = CommonUser();

  while (true) {
    int opsi = menuLogin(error: err);

    if (opsi == 0) {
      late bool hasil;
      List data = loginPage();

      try {
        hasil = await user.login(data[0], data[1]);
      } catch (e) {
        err = e.toString();
        continue;
      }

      if (hasil) {
        break;
      }
    } else if (opsi == 1) {
      late bool hasil;
      List data = createAccountPage(user);

      try {
        hasil = await user.createAccount(
            data[0], data[1], data[2], data[3], data[4]);
      } catch (e) {
        err = e.toString();
        continue;
      }

      if (hasil) {
        break;
      }
    } else if (opsi == 2) {
      return;
    }
  }

  await homepageRoutine(user: user);
}

/// Rute Untuk Seller
Future<void> sellerRoutine() async {
  String? err;
  Seller user = Seller();
  late DaftarProduk daftarProduk;

  while (true) {
    int opsi = menuLogin(error: err);

    if (opsi == 0) {
      List data = loginPage();

      try {
        daftarProduk = await user.login(data[0], data[1]);
      } catch (e) {
        err = e.toString();
        continue;
      }

      break;
    } else if (opsi == 1) {
      List data = createAccountPage(user);

      try {
        daftarProduk = await user.createAccount(
            data[0], data[1], data[2], data[3], data[4], data[5]);
      } catch (e) {
        err = e.toString();
        continue;
      }

      break;
    } else if (opsi == 2) {
      return;
    }
  }

  await homepageRoutine(seller: user, daftarProduk: daftarProduk);
}

Future<void> homepageRoutine({CommonUser? user, Seller? seller, DaftarProduk? daftarProduk}) async {
  if (user != null) {
    while (true) {
      String? err;

      int opsi = await homepage(user: user, error: err);

      if (opsi == 0) {
        await selectListRoutine(user);
      } else if (opsi == 1) {
        String namaDaftar = buatDaftarBelanjaForm();

        try {
          await user.buatDaftar(namaDaftar);
        } catch (e) {
          err = e.toString();
          continue;
        }
      } else if (opsi == 2) {
        if (await showMyProfileRoutine(user)) {
          return;
        }
      }
    }
  } else if (seller != null && daftarProduk != null) {
    while (true) {
      String? err;
      int opsi = await homepage(seller: seller, daftarProduk: daftarProduk, error: err);

      if (opsi == 0) {
        List data = tambahBarangForm(seller: seller);

        try {
          bool hasil = await daftarProduk.tambahBarang(data[0], data[1], data[2], data[3], data[4], data[5]);

          if (!hasil) {
            err = "Produk gagal ditambahkan";
          }
        } catch (e) {
          err = e.toString();
          continue;
        }

      } else if (opsi == 1) {
        Barang? barang = await selectDetailBarang(seller: seller, daftarProduk: daftarProduk);

        if (barang != null) {
          await showSpesificBarangRoutine(barang: barang, seller: seller);
        }
      } else if (opsi == 2) {
        if (await showMyProfileRoutine(seller)) {
          return;
        }
      }
    }
  }
}

Future<bool> showMyProfileRoutine(User user) async {
  while (true) {
    String? err;
    int opsi = showProfile(user, error: err);

    if (opsi == 0) {
      return false;
    } else if (opsi == 1) {
      try {
        if (user.logOut()) {
          return true;
        }
      } catch (e) {
        err = e.toString();
        continue;
      }
    } else if (opsi == 2) {
      try {
        if (await user.deleteAccount()) {
          return true;
        }
      } catch (e) {
        err = e.toString();
        continue;
      }
    }
  }
}

Future<void> selectListRoutine(CommonUser user) async {
  DaftarBelanja? daftarBelanja = await selectList(user);

  if (daftarBelanja != null) {
    await showSpesificListRoutine(user, daftarBelanja);
  }
}

Future<void> showSpesificListRoutine(CommonUser user, DaftarBelanja daftarBelanja) async {
  while (true) {
    String? err;
    int opsi = await spesificList(user, daftarBelanja, err);

    if (opsi == 0) {
      List data = tambahBarangForm(user: user);

      try {
        bool hasil = await daftarBelanja.tambahBarang(data[0], data[1], data[2], data[3], data[4], data[5]);

        if (!hasil) {
          throw(Exception("Gagal Menambahkan Barang"));
        }
      } catch (e) {
        err = e.toString();
        continue;
      }
    } else if (opsi == 1) {
      Barang? barang = await selectDetailBarang(user: user, daftarBelanja: daftarBelanja);

      if (barang != null) {
        await showSpesificBarangRoutine(user: user, barang: barang);
      }
    } else if (opsi == 2) {
      String namaDaftar = editTabelForm(user: user, daftarBelanja: daftarBelanja);

      try {
        await daftarBelanja.update(namaDaftar);
      } catch (e) {
        err = e.toString();
        continue;
      }
    } else if (opsi == 3) {
      try {
        await daftarBelanja.delete();
        return;
      } catch (e) {
        err = e.toString();
        continue;
      }
      
    } else if (opsi == 4) {
      return;
    } else if (opsi == 5) {
      while (true) {
        List<Map<String, dynamic>> daftarSeller = await Seller.getAllSeller();

        List? data = await selectSeller(user, daftarSeller);

        if (data != null) {
          try {
            bool hasil = await selectBarangFromSellerRoutine(user, daftarBelanja, data[0], data[1]);
            if (hasil) {
              break;
            }
          } catch (e) {
            err = e.toString();
          }
        } else {
          break;
        }
      }
    }
  }
}

Future<bool> selectBarangFromSellerRoutine(CommonUser user, DaftarBelanja daftarBelanja, Seller seller, DaftarProduk daftarProduk) async {
  while (true) {
    Barang? barang = await selectBarangFromSeller(user, seller, daftarProduk);

    if (barang != null) {
      List? dataBarang = detailBarangFromSeller(user, barang);

      if (dataBarang != null) {
        bool hasil = await daftarBelanja.tambahBarang(dataBarang[0], dataBarang[1], dataBarang[2], dataBarang[3], dataBarang[4], dataBarang[5]);
        if (!hasil) {
          throw(Exception("Gagal Menambahkan Barang"));
        }
        return true;
      }
    } else {
      return false;
    }
  }
}

Future<void> showSpesificBarangRoutine({CommonUser? user, Seller? seller, required Barang barang}) async {
    if (user != null) {
      while (true) {
        String? err;
        int opsi = spesificBarang(user, barang, err);

        if (opsi == 0) {
          List data = updateDataBarangForm(user, barang);

          try {
            await barang.update(data[0], data[1], data[2], data[3], data[4], data[5]);
          } catch (e) {
            err = e.toString();
            continue;
          }

        } else if (opsi == 1) {
          try {
            if (await barang.delete()) {
              return;
            }
          } catch (e) {
            err = e.toString();
            continue;
          }
        } else if (opsi == 2) {
          return;
        }
      }
    } else if (seller != null) {
      while (true) {
        String? err;
        int opsi = spesificBarang(seller, barang, err);


        if (opsi == 0) {
          List data = updateDataBarangForm(seller, barang);

          try {
            await barang.update(data[0], data[1], data[2], data[3], data[4], data[5]);
          } catch (e) {
            err = e.toString();
            continue;
          }

        } else if (opsi == 1) {
          try {
            if (await barang.delete()) {
              return;
            }
          } catch (e) {
            err = e.toString();
            continue;
          }
        } else if (opsi == 2) {
          return;
        }
      }
    }
}
