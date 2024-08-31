import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:pengeluaran/charts/pieChartTipePengeluaran.dart';
import 'package:pengeluaran/static/static.dart';
import 'package:pengeluaran/databasehelper/dbhelper_pengeluaran.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:sqflite/sqflite.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Daftarpengeluaran());
}

class Daftarpengeluaran extends StatefulWidget {
  const Daftarpengeluaran({super.key});

  @override
  State<Daftarpengeluaran> createState() => _DaftarpengeluaranState();
}

class _DaftarpengeluaranState extends State<Daftarpengeluaran> {
  final db = DatabaseHelper.instance;
  List<Map<String, dynamic>> _daftarpengeluaran = [];
  DateTime? selectedDate;
  final formKey = GlobalKey<FormState>();
  String? dropdownValue;

  final namaPengeluaranController = TextEditingController();
  final nominalPengeluaranController = TextEditingController();
  final waktuPengeluaranController = TextEditingController();
  final tipePengeluaranController = TextEditingController();
  final cariPengeluaranController = TextEditingController();
  final FocusNode myFocusNode = FocusNode();

  var filterPengeluaran = '';

  List<String> ddlItemTipePengeluaran = [
    'Belanja Pribadi',
    'Hiburan',
    'Kesehatan',
    'Lainnya',
    'Makanan',
    'Transportasi'
  ];

  final KeyboardVisibilityController _keyboardVisibilityController =
      KeyboardVisibilityController();

  var totalPengeluaran = 0;
  var PengeluaranBulanan = 0;

  @override
  void initState() {
    super.initState();
    getPengeluaran();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> tambahPengeluaran(nama, nominal, waktu, tipe) async {
    final Map<String, dynamic> row = {
      DatabaseHelper.columnPengeluaran: nama,
      DatabaseHelper.columnNominal: nominal,
      DatabaseHelper.columnWaktu: waktu,
      DatabaseHelper.columnTipe: tipe,
    };

    try {
      await DatabaseHelper.instance.insert(row);

      _daftarpengeluaran;
      setState(() {});
    } catch (e) {
      print('ada error ini bang $e');
    }
  }

  Future<void> updatePengeluaran(id, nama, nominal, waktu, tipe) async {
    Map<String, dynamic> row = {
      DatabaseHelper.columnId: id,
      DatabaseHelper.columnPengeluaran: nama,
      DatabaseHelper.columnNominal: nominal,
      DatabaseHelper.columnWaktu: waktu,
      DatabaseHelper.columnTipe: tipe,
    };

    print('ini idnya $id');

    try {
      await DatabaseHelper.instance.update(id, row);
    } catch (e) {
      print('ada ini bang $e');
    }
    setState(() {
      _daftarpengeluaran;
    });
  }

  void hideKeyboard() {
    KeyboardVisibilityController().isVisible;
  }

  void unfocusText() {
    myFocusNode.unfocus();
  }

  Future<void> getPengeluaran() async {
    List<Map<String, dynamic>> dataPengeluaran = await db.queryAll();

    totalPengeluaran = 0;
    PengeluaranBulanan = 0;

    for (var i = 0; i < dataPengeluaran.length; i++) {
      var cekRp = dataPengeluaran[i]['nominal'].toString().contains('Rp ') ==
              true
          ? dataPengeluaran[i]['nominal'].toString().replaceAll('Rp ', '')
          : dataPengeluaran[i]['nominal'].toString().contains('Rp') == true
              ? dataPengeluaran[i]['nominal'].toString().replaceAll('Rp', '')
              : dataPengeluaran[i]['nominal'];

      var Pengeluarannya = int.parse(cekRp);

      totalPengeluaran = totalPengeluaran + Pengeluarannya;

      DateTime waktuPengeluaran =
          DateFormat('EEEE dd MMMM yyyy').parse(dataPengeluaran[i]['waktu']);

      var bulanIni = DateFormat('MMMM').format(DateTime.now());
      var waktuPengeluarannya = DateFormat('MMMM').format(waktuPengeluaran);

      if (waktuPengeluarannya == bulanIni) {
        PengeluaranBulanan = PengeluaranBulanan + Pengeluarannya;
      } else {
        PengeluaranBulanan = PengeluaranBulanan;
      }
    }

    setState(() {
      _daftarpengeluaran = dataPengeluaran;
    });
  }

  Future<void> getPengeluaranByName(namaPengeluaran) async {
    List<Map<String, dynamic>> dataPengeluaran =
        await db.queryAllByPengeluaran(namaPengeluaran);
    setState(() {
      _daftarpengeluaran = dataPengeluaran;
    });
  }

  Future<void> deletePengeluaran(int id) async {
    await db.delete(id);
    getPengeluaran();
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.amber,
              onPrimary: Colors.black,
              onSurface: Colors.grey,
              surface: Colors.grey[900]!,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
      cancelText: 'Batal',
      confirmText: 'Pilih',
      helpText: 'Pilih tanggal pengeluaran.',
      fieldLabelText: 'Pilih Tanggal',
      fieldHintText: 'Pilih Tanggal',
      errorFormatText: 'Format Tanggal Tidak Sesuai.',
      errorInvalidText: 'Pilih Tanggal Yang Valid.',
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        // selectedDate = picked;
        waktuPengeluaranController.text =
            DateFormat('EEEE dd MMMM yyyy').format(picked);
      });
    } else {
      waktuPengeluaranController.text =
          DateFormat('EEEE dd MMMM yyyy').format(DateTime.now());
    }
  }

  NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
    name: 'IDR',
  );

  void _requestFocus() {
    FocusScope.of(context).requestFocus(myFocusNode);
  }

  void showAndCloseDialog(title, content) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.green[500],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(content),
            ],
          ),
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          contentTextStyle: const TextStyle(
            color: Colors.white,
          ),
          icon: const Icon(
            Icons.check_circle,
            color: Colors.white,
          ),
        );
      },
    );

    if (mounted) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          Navigator.of(context).pop();
        });
      }
    }
  }

  Widget popupTambahPengeluaran() {
    Set<String> ddlItemTipePengeluaranSet = ddlItemTipePengeluaran.toSet();
    return AlertDialog(
      backgroundColor: Colors.grey[900],
      icon: Icon(
        Icons.add_circle,
        size: 50,
        color: Colors.amber,
      ),
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: Colors.amber,
      ),
      title: Text(
        'Tambah Pengeluaran',
      ),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              style: TextStyle(color: Colors.amber),
              validator: (valueNama) {
                if (valueNama!.isEmpty) {
                  return 'Nama Tidak Boleh Kosong';
                }
                return null;
              },
              keyboardType: TextInputType.name,
              controller: namaPengeluaranController,
              decoration: InputDecoration(
                labelText: 'Pengeluaran',
                hintText: 'Isikan Nama Pengeluaran',
                labelStyle: TextStyle(color: Colors.white),
                hintStyle: TextStyle(color: Colors.grey),
                errorStyle: TextStyle(color: Colors.red),
              ),
            ),
            TextFormField(
                style: TextStyle(color: Colors.amber),
                validator: (valueNominal) {
                  if (valueNominal!.isEmpty) {
                    return 'Nominal Tidak Boleh Kosong';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
                controller: nominalPengeluaranController,
                decoration: const InputDecoration(
                  labelText: 'Nominal',
                  hintText: 'Isikan Nominal Pengeluaran',
                  hintStyle: TextStyle(color: Colors.grey),
                  labelStyle: TextStyle(color: Colors.white),
                  errorStyle: TextStyle(color: Colors.red),
                ),
                onChanged: (value) {
                  try {
                    setState(() {
                      if (nominalPengeluaranController.text != 'Rp ') {
                        nominalPengeluaranController.text =
                            currencyFormatter.format(int.parse(value));
                      } else {
                        nominalPengeluaranController.clear();
                      }
                    });
                  } catch (e) {
                    print('ada error ini $e');
                  }
                }),
            TextFormField(
              style: TextStyle(color: Colors.amber),
              validator: (valueWaktu) {
                if (valueWaktu!.isEmpty) {
                  return 'Waktu Tidak Boleh Kosong';
                }
                return null;
              },
              onTap: () => selectDate(context),
              keyboardType: TextInputType.none,
              controller: waktuPengeluaranController,
              decoration: const InputDecoration(
                labelText: 'Waktu',
                hintText: 'Isikan Waktu Pengeluaran',
                hintStyle: TextStyle(color: Colors.grey),
                labelStyle: TextStyle(color: Colors.white),
                errorStyle: TextStyle(color: Colors.red),
              ),
            ),
            // Dropdown disini
            DropdownButtonFormField<String>(
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
              dropdownColor: Colors.grey[850],
              style: TextStyle(
                color: Colors.amber,
                fontSize: 16,
              ),
              items: ddlItemTipePengeluaranSet.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Row(
                    children: [
                      Icon(Icons.arrow_right, color: Colors.amber),
                      Text(item),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  tipePengeluaranController.text = newValue.toString();
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Tipe Tidak Boleh Kosong';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Tipe Pengeluaran',
                hintStyle: TextStyle(color: Colors.grey),
                labelStyle: TextStyle(color: Colors.white),
                errorStyle: TextStyle(color: Colors.red),
              ),
            )
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Batal',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              )),
        ),
        TextButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              setState(() {
                tambahPengeluaran(
                  namaPengeluaranController.text,
                  nominalPengeluaranController.text,
                  waktuPengeluaranController.text,
                  tipePengeluaranController.text,
                );

                getPengeluaran();
              });

              Navigator.of(context).pop();
              if (mounted) {
                showAndCloseDialog(
                    'Berhasil', 'Pengeluaran Berhasil Tersimpan!');
              }
            }
          },
          child: const Text(
            'Simpan',
            style: TextStyle(
                color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget popupEditPengeluaran(id, pengeluaran, nominal, waktu, tipe) {
    Set<String> ddlItemTipePengeluaranSet = ddlItemTipePengeluaran.toSet();
    dropdownValue = tipe;
    int idPengeluaran = id;
    namaPengeluaranController.text = pengeluaran;
    nominalPengeluaranController.text = nominal;
    waktuPengeluaranController.text = waktu;
    tipePengeluaranController.text = tipe;
    print('ini ddlvaluenya $dropdownValue');
    return AlertDialog(
      backgroundColor: Colors.grey[900],
      icon: Icon(
        Icons.add_circle,
        size: 50,
        color: Colors.amber,
      ),
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: Colors.amber,
      ),
      title: const Text('Edit Pengeluaran'),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              style: TextStyle(color: Colors.amber),
              validator: (valueNama) {
                if (valueNama!.isEmpty) {
                  return 'Nama Tidak Boleh Kosong';
                }
                return null;
              },
              keyboardType: TextInputType.name,
              controller: namaPengeluaranController,
              decoration: const InputDecoration(
                labelText: 'Pengeluaran',
                hintText: 'Isikan Nama Pengeluaran',
                labelStyle: TextStyle(color: Colors.white),
                hintStyle: TextStyle(color: Colors.grey),
                errorStyle: TextStyle(color: Colors.red),
              ),
            ),
            TextFormField(
                style: TextStyle(color: Colors.amber),
                validator: (valueNominal) {
                  if (valueNominal!.isEmpty) {
                    return 'Nominal Tidak Boleh Kosong';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
                controller: nominalPengeluaranController,
                decoration: const InputDecoration(
                  labelText: 'Nominal',
                  hintText: 'Isikan Nominal Pengeluaran',
                  labelStyle: TextStyle(color: Colors.white),
                  hintStyle: TextStyle(color: Colors.grey),
                  errorStyle: TextStyle(color: Colors.red),
                ),
                onChanged: (value) {
                  try {
                    setState(() {
                      nominalPengeluaranController.text =
                          currencyFormatter.format(int.parse(value));
                    });
                  } catch (e) {
                    print('ada error ini $e');
                  }
                }),
            TextFormField(
              style: TextStyle(color: Colors.amber),
              validator: (valueWaktu) {
                if (valueWaktu!.isEmpty) {
                  return 'Waktu Tidak Boleh Kosong';
                }
                return null;
              },
              onTap: () => selectDate(context),
              keyboardType: TextInputType.none,
              controller: waktuPengeluaranController,
              decoration: const InputDecoration(
                labelText: 'Waktu',
                hintText: 'Isikan Waktu Pengeluaran',
                labelStyle: TextStyle(color: Colors.white),
                hintStyle: TextStyle(color: Colors.grey),
                errorStyle: TextStyle(color: Colors.red),
              ),
            ),
            DropdownButtonFormField<String>(
              borderRadius: BorderRadius.all(
                Radius.circular(20.0),
              ),
              dropdownColor: Colors.grey[850],
              style: TextStyle(
                color: Colors.amber,
                fontSize: 16,
              ),
              value: dropdownValue,
              items: ddlItemTipePengeluaranSet.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Row(
                    children: [
                      Icon(Icons.arrow_right, color: Colors.amber),
                      Text(item),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  tipePengeluaranController.text = newValue.toString();
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Tipe Tidak Boleh Kosong';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Tipe Pengeluaran',
                hintStyle: TextStyle(color: Colors.grey),
                labelStyle: TextStyle(color: Colors.white),
                errorStyle: TextStyle(color: Colors.red),
              ),
            )
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Batal',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              )),
        ),
        TextButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              setState(() {
                // simpan edit disini
                updatePengeluaran(
                  idPengeluaran,
                  namaPengeluaranController.text,
                  nominalPengeluaranController.text,
                  waktuPengeluaranController.text,
                  tipePengeluaranController.text,
                );
                getPengeluaran();
              });

              Navigator.of(context).pop();
              if (mounted) {
                showAndCloseDialog(
                    'Berhasil', 'Pengeluaran Berhasil Diperbarui!');
              }
            }
          },
          child: const Text(
            'Perbarui',
            style: TextStyle(
                color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: Column(
          children: [
            Container(
              child: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.amber,
                          ),
                          onPressed: () {
                            Navigator.pop(context, true);
                          },
                        ),
                        IconButton(
                            icon: const Icon(
                              Icons.menu_book_rounded,
                              color: Colors.white,
                            ),
                            onPressed: () {}),
                        const Text(
                          'Daftar Pengeluaran',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: defaultPadding * 2, right: defaultPadding * 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Pengeluaran ${DateFormat('MMMM yyyy').format(DateTime.now().toLocal())}',
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        currencyFormatter.format(PengeluaranBulanan),
                        style: TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.add_circle,
                      size: 32,
                      color: Colors.amber,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                    ),
                    tooltip: 'Tambah Pengeluaran',
                    onPressed: () {
                      namaPengeluaranController.clear();
                      nominalPengeluaranController.clear();
                      waktuPengeluaranController.clear();

                      tipePengeluaranController.text = 'Pengeluaran';

                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return popupTambahPengeluaran();
                          });
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              height: defaultPadding,
            ),
            Container(
              padding: const EdgeInsets.only(
                top: defaultPadding / 2,
                left: defaultPadding,
                right: defaultPadding,
                bottom: defaultPadding / 2,
              ),
              child: TextFormField(
                style: TextStyle(color: Colors.white),
                focusNode: myFocusNode,
                keyboardType: TextInputType.text,
                controller: cariPengeluaranController,
                decoration: InputDecoration(
                  hintText: 'Cari Pengeluaran Dengan Nama',
                  hintStyle: TextStyle(color: Colors.white54),
                  prefixIcon: Icon(Icons.search_rounded, color: Colors.white54),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      cariPengeluaranController.clear();
                      setState(() {
                        unfocusText();

                        getPengeluaran();
                      });
                    },
                  ),
                ),
                onChanged: (value) {
                  // print('ini carinya bang ${value}');
                  setState(() {
                    if (value == '') {
                      getPengeluaran();
                    } else {
                      getPengeluaranByName(value);
                    }
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: defaultPadding,
                  right: defaultPadding,
                  bottom: defaultPadding / 2),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    filterPengeluaran == ''
                        ? Text(
                            'Total ' +
                                _daftarpengeluaran.length.toString() +
                                ' Pengeluaran',
                            // 'Semua Pengeluaran',
                            style: TextStyle(color: Colors.amber),
                          )
                        : Text(
                            filterPengeluaran,
                            style: TextStyle(color: Colors.amber),
                          ),
                    Row(
                      children: [
                        Text(
                          'Filter Data',
                          style: TextStyle(color: Colors.white),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.filter_list,
                            color: Colors.white,
                          ),
                          onPressed: () {},
                        ),
                      ],
                    )
                  ]),
            ),
            Expanded(
              child: Container(
                child: _daftarpengeluaran.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.thumb_up,
                              color: Colors.grey[800],
                              size: defaultPadding * 5,
                            ),
                            SizedBox(height: defaultPadding),
                            Text(
                              'Belum ada Pengeluaran.  Keren!',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: _daftarpengeluaran.length,
                        itemBuilder: (context, index) {
                          var nominalSaja = _daftarpengeluaran[index]['nominal']
                                      .toString()
                                      .contains('Rp ') ==
                                  true
                              ? _daftarpengeluaran[index]['nominal']
                                  .toString()
                                  .replaceAll('Rp ', '')
                              : _daftarpengeluaran[index]['nominal']
                                          .toString()
                                          .contains('Rp') ==
                                      true
                                  ? _daftarpengeluaran[index]['nominal']
                                      .toString()
                                      .replaceAll('Rp', '')
                                  : _daftarpengeluaran[index]['nominal'];
                          // _daftarpengeluaran[index]['nominal']
                          //     .toString()
                          //     .replaceAll('Rp ', '');

                          Color colorValue;

                          if (int.parse(nominalSaja) < 100000) {
                            colorValue = Color.fromRGBO(231, 70, 70, 1);
                          } else {
                            colorValue = Color.fromRGBO(149, 1, 1, 1);
                          }

                          // print(
                          //     'ini isi daftarnya${_daftarpengeluaran[index]}');

                          return Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                scale: 0.1,
                                alignment: Alignment.centerRight,
                                opacity: 15 / 100,
                                image: _daftarpengeluaran[index]['tipe'] ==
                                        'Belanja Pribadi'
                                    ? AssetImage(
                                        'assets/images/belanjapribadi.png')
                                    : _daftarpengeluaran[index]['tipe'] ==
                                            'Hiburan'
                                        ? AssetImage(
                                            'assets/images/hiburan.png')
                                        : _daftarpengeluaran[index]['tipe'] ==
                                                'Kesehatan'
                                            ? AssetImage(
                                                'assets/images/kesehatan.png')
                                            : _daftarpengeluaran[index]
                                                        ['tipe'] ==
                                                    'Lainnya'
                                                ? AssetImage(
                                                    'assets/images/lainnya.png')
                                                : _daftarpengeluaran[index]
                                                            ['tipe'] ==
                                                        'Makanan'
                                                    ? AssetImage(
                                                        'assets/images/makanan.png')
                                                    : _daftarpengeluaran[index]
                                                                ['tipe'] ==
                                                            'Transportasi'
                                                        ? AssetImage(
                                                            'assets/images/transportasi.png')
                                                        : AssetImage(
                                                            'assets/images/irlogonobg.png'),
                              ),
                              color: colorValue,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            height: 100,
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.only(
                                left: defaultPadding,
                                right: defaultPadding,
                                bottom: defaultPadding),
                            alignment: Alignment.center,
                            child: ListTile(
                              leading: Text('${index + 1}.',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                              title: Text(
                                _daftarpengeluaran[index]['pengeluaran'],
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              subtitle: Text(
                                _daftarpengeluaran[index]['waktu'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                              trailing: Text(
                                '- ${currencyFormatter.format(int.parse(nominalSaja))}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.white),
                              ),
                              onTap: () {
                                showDialog(
                                  barrierDismissible: true,
                                  context: context,
                                  builder: (BuildContext context) {
                                    return PopScope(
                                      canPop: true,
                                      child: AlertDialog(
                                        backgroundColor: Colors.grey[900],
                                        title: const Center(
                                          child: Text(
                                            'Rincian Pengeluaran',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.amber),
                                          ),
                                        ),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text(
                                                  'Pengeluaran : ',
                                                  style: TextStyle(
                                                      color: Colors.grey),
                                                ),
                                                Text(
                                                  '${_daftarpengeluaran[index]['pengeluaran']}',
                                                  style: TextStyle(
                                                      color: Colors.amber),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text(
                                                  'Nominal : ',
                                                  style: TextStyle(
                                                      color: Colors.grey),
                                                ),
                                                Text(
                                                  currencyFormatter.format(
                                                    int.parse(nominalSaja),
                                                  ),
                                                  style: TextStyle(
                                                      color: Colors.amber),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text(
                                                  'Waktu : ',
                                                  style: TextStyle(
                                                      color: Colors.grey),
                                                ),
                                                Text(
                                                  '${_daftarpengeluaran[index]['waktu']}',
                                                  style: TextStyle(
                                                      color: Colors.amber),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text(
                                                  'Tipe : ',
                                                  style: TextStyle(
                                                      color: Colors.grey),
                                                ),
                                                Text(
                                                  '${_daftarpengeluaran[index]['tipe']}',
                                                  style: TextStyle(
                                                      color: Colors.amber),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        actions: <Widget>[
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                TextButton(
                                                  style: TextButton.styleFrom(
                                                    foregroundColor:
                                                        Colors.white,
                                                    backgroundColor:
                                                        Colors.grey,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                  ),
                                                  child: Icon(Icons.edit),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                    showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return popupEditPengeluaran(
                                                              _daftarpengeluaran[
                                                                  index]['id'],
                                                              _daftarpengeluaran[
                                                                      index][
                                                                  'pengeluaran'],
                                                              _daftarpengeluaran[
                                                                      index]
                                                                  ['nominal'],
                                                              _daftarpengeluaran[
                                                                      index]
                                                                  ['waktu'],
                                                              _daftarpengeluaran[
                                                                      index]
                                                                  ['tipe']);
                                                        });
                                                    print(
                                                        'ini isinya $index ${_daftarpengeluaran[index]['id']} ');
                                                  },
                                                ),
                                                TextButton(
                                                  style: TextButton.styleFrom(
                                                    foregroundColor:
                                                        Colors.white,
                                                    backgroundColor: Colors.red,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                  ),
                                                  child: Icon(
                                                      Icons.delete_forever),
                                                  // const Text('Hapus'),
                                                  onPressed: () {
                                                    setState(() {
                                                      deletePengeluaran(
                                                          _daftarpengeluaran[
                                                              index]['id']);
                                                    });
                                                    Navigator.of(context).pop();
                                                    showAndCloseDialog(
                                                        'Dihapus',
                                                        'Pengeluaran Berhasil Dihapus!');
                                                  },
                                                ),
                                              ]),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          );
                        }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
