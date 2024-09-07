import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
// import 'package:pengeluaran/charts/pieChart_TipePengeluaran.dart';
import 'package:pengeluaran/function/functions.dart';
import 'package:pengeluaran/static/static.dart';
import 'package:pengeluaran/databasehelper/dbhelper_pengeluaran.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:pengeluaran/widgets/mywidget.dart';

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
  final urutPengeluaranController = TextEditingController();
  final cariPengeluaranController = TextEditingController();
  final FocusNode myFocusNode = FocusNode();
  String filterData = '';

  var filterPengeluaran = '';

  List<String> ddlItemTipePengeluaran = [
    'Belanja Pribadi',
    'Hiburan',
    'Kesehatan',
    'Lainnya',
    'Makanan',
    'Transportasi'
  ];
  List<String> ddlUrutPengeluaran = [
    'A - Z',
    'Z - A',
  ];

  var totalPengeluaran = 0;
  var pengeluaranBulanan = 0;

  @override
  void initState() {
    super.initState();
    getPengeluaran('', '');
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

  Future<void> getPengeluaran(tipenya, sortnya) async {
    if (tipenya == '' && sortnya == '') {
      filterData = 'Filter Data : Semua';
    } else if (tipenya == '' && sortnya != '') {
      filterData = sortnya;
    } else if (tipenya != '' && sortnya == '') {
      filterData = tipenya;
    } else {
      filterData = tipenya + ' - ' + sortnya;
    }

    final tipe = tipenya ?? '';
    final sort = sortnya ?? '';
    List<Map<String, dynamic>> dataPengeluaran = await db.queryAll(tipe, sort);

    totalPengeluaran = 0;
    pengeluaranBulanan = 0;

    for (var i = 0; i < dataPengeluaran.length; i++) {
      var cekRp = cekContainRp(dataPengeluaran[i]['nominal']);

      var pengeluarannya = int.parse(
        removedot(cekRp),
      );

      totalPengeluaran = totalPengeluaran + pengeluarannya;

      DateTime waktuPengeluaran =
          parsingDateFormat(dataPengeluaran[i]['waktu']);

      var bulanIni = bulanSekarang();
      var waktuPengeluarannya = dtFormatMMMM(waktuPengeluaran.toString());

      if (waktuPengeluarannya == bulanIni) {
        pengeluaranBulanan = pengeluaranBulanan + pengeluarannya;
      } else {
        pengeluaranBulanan = pengeluaranBulanan;
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
    getPengeluaran('', '');
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
        waktuPengeluaranController.text =
            DateFormat('EEEE dd MMMM yyyy').format(picked);
      });
    } else {
      waktuPengeluaranController.text =
          DateFormat('EEEE dd MMMM yyyy').format(DateTime.now());
    }
  }

  void showAndCloseDialog(title, content) async {
    showDialog(
      context: context,
      builder: (context) {
        return showAndCloseAlertDialog(title, content);
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
      icon: const Icon(
        Icons.add_circle,
        size: 50,
        color: Colors.amber,
      ),
      titleTextStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: Colors.amber,
      ),
      title: const Text(
        'Tambah Pengeluaran',
      ),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              style: const TextStyle(color: Colors.amber),
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
                style: const TextStyle(color: Colors.amber),
                validator: (valueNominal) {
                  if (valueNominal!.isEmpty) {
                    return 'Nominal Tidak Boleh Kosong';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                            currencyFormatterRp.format(int.parse(value));
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
            DropdownButtonFormField<String>(
              borderRadius: const BorderRadius.all(
                Radius.circular(20),
              ),
              dropdownColor: Colors.grey[850],
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 16,
              ),
              items: ddlItemTipePengeluaranSet.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_right, color: Colors.amber),
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
              decoration: const InputDecoration(
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
          child: const Text('Batal',
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

                getPengeluaran('', '');
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

  Widget popupFilterPengeluaran() {
    Set<String> ddlItemTipePengeluaranSet = ddlItemTipePengeluaran.toSet();
    Set<String> ddlUrutPengeluaranSet = ddlUrutPengeluaran.toSet();
    return AlertDialog(
      backgroundColor: Colors.grey[900],
      icon: const Icon(
        Icons.filter_list,
        size: 50,
        color: Colors.amber,
      ),
      titleTextStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: Colors.amber,
      ),
      title: const Text(
        'Filter Pengeluaran',
      ),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dropdown tipe pengeluaran
            DropdownButtonFormField<String>(
              borderRadius: const BorderRadius.all(
                Radius.circular(20),
              ),
              dropdownColor: Colors.grey[850],
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 16,
              ),
              items: ddlItemTipePengeluaranSet.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_right, color: Colors.amber),
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
              decoration: const InputDecoration(
                labelText: 'Tipe Pengeluaran',
                hintStyle: TextStyle(color: Colors.grey),
                labelStyle: TextStyle(color: Colors.white),
                errorStyle: TextStyle(color: Colors.red),
              ),
            ),

            DropdownButtonFormField<String>(
              borderRadius: const BorderRadius.all(
                Radius.circular(20),
              ),
              dropdownColor: Colors.grey[850],
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 16,
              ),
              items: ddlUrutPengeluaranSet.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_right, color: Colors.amber),
                      Text(item),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  urutPengeluaranController.text = newValue.toString();
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Urutan Tidak Boleh Kosong';
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Urutkan Pengeluaran',
                hintStyle: TextStyle(color: Colors.grey),
                labelStyle: TextStyle(color: Colors.white),
                errorStyle: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Batal',
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
                getPengeluaran(tipePengeluaranController.text,
                    urutPengeluaranController.text);
              });

              Navigator.of(context).pop();
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
    return AlertDialog(
      backgroundColor: Colors.grey[900],
      icon: const Icon(
        Icons.add_circle,
        size: 50,
        color: Colors.amber,
      ),
      titleTextStyle: const TextStyle(
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
              style: const TextStyle(color: Colors.amber),
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
                style: const TextStyle(color: Colors.amber),
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
                          currencyFormatterRp.format(int.parse(value));
                    });
                  } catch (e) {
                    print('ada error ini $e');
                  }
                }),
            TextFormField(
              style: const TextStyle(color: Colors.amber),
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
              borderRadius: const BorderRadius.all(
                Radius.circular(20.0),
              ),
              dropdownColor: Colors.grey[850],
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 16,
              ),
              value: dropdownValue,
              items: ddlItemTipePengeluaranSet.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_right, color: Colors.amber),
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
              decoration: const InputDecoration(
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
          child: const Text('Batal',
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
                updatePengeluaran(
                  idPengeluaran,
                  namaPengeluaranController.text,
                  nominalPengeluaranController.text,
                  waktuPengeluaranController.text,
                  tipePengeluaranController.text,
                );
                getPengeluaran('', '');
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
            Padding(
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
                          if (mounted) {
                            // Navigator.pop(context, true);
                            Navigator.pop(context);
                          }
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
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text(
                        currencyFormatterRp.format(pengeluaranBulanan),
                        style: const TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(
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
            const SizedBox(
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
                style: const TextStyle(color: Colors.white),
                focusNode: myFocusNode,
                keyboardType: TextInputType.text,
                controller: cariPengeluaranController,
                decoration: InputDecoration(
                  hintText: 'Cari Pengeluaran Dengan Nama',
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon:
                      const Icon(Icons.search_rounded, color: Colors.white54),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      cariPengeluaranController.clear();
                      setState(() {
                        unfocusText();
                        getPengeluaran('', '');
                      });
                    },
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    if (value == '') {
                      getPengeluaran('', '');
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
                    Text(
                      filterPengeluaran.isEmpty
                          ? 'Total ${_daftarpengeluaran.length} Pengeluaran'
                          : filterPengeluaran,
                      style: const TextStyle(color: Colors.amber),
                    ),
                    Row(
                      children: [
                        TextButton.icon(
                            iconAlignment: IconAlignment.end,
                            onPressed: () {
                              if (filterData == 'Filter Data : Semua') {
                                showDialog(
                                    context: context,
                                    builder: (_) {
                                      return popupFilterPengeluaran();
                                    });
                              } else {
                                getPengeluaran('', '');
                              }
                            },
                            label: Text(
                              filterData,
                              style: const TextStyle(color: Colors.amber),
                            ),
                            icon: filterData == 'Filter Data : Semua'
                                ? const Icon(
                                    Icons.filter_list,
                                    color: Colors.white,
                                  )
                                : const Icon(
                                    Icons.clear_rounded,
                                    color: Colors.red,
                                  )),
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
                            const SizedBox(height: defaultPadding),
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
                              ? removerp(_daftarpengeluaran[index]['nominal'])
                              : _daftarpengeluaran[index]['nominal']
                                          .toString()
                                          .contains('Rp') ==
                                      true
                                  ? removerpNospacing(
                                      _daftarpengeluaran[index]['nominal'])
                                  : _daftarpengeluaran[index]['nominal'];

                          Color colorValue;

                          if (int.parse(removedot(nominalSaja)) < 100000) {
                            colorValue = const Color.fromRGBO(231, 70, 70, 1);
                          } else {
                            colorValue = const Color.fromRGBO(149, 1, 1, 1);
                          }

                          return Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                scale: 0.1,
                                alignment: Alignment.centerRight,
                                opacity: 15 / 100,
                                image: _daftarpengeluaran[index]['tipe'] ==
                                        'Belanja Pribadi'
                                    ? const AssetImage(
                                        'assets/images/belanjapribadi.png')
                                    : _daftarpengeluaran[index]['tipe'] ==
                                            'Hiburan'
                                        ? const AssetImage(
                                            'assets/images/hiburan.png')
                                        : _daftarpengeluaran[index]['tipe'] ==
                                                'Kesehatan'
                                            ? const AssetImage(
                                                'assets/images/kesehatan.png')
                                            : _daftarpengeluaran[index]
                                                        ['tipe'] ==
                                                    'Lainnya'
                                                ? const AssetImage(
                                                    'assets/images/lainnya.png')
                                                : _daftarpengeluaran[index]
                                                            ['tipe'] ==
                                                        'Makanan'
                                                    ? const AssetImage(
                                                        'assets/images/makanan.png')
                                                    : _daftarpengeluaran[index]
                                                                ['tipe'] ==
                                                            'Transportasi'
                                                        ? const AssetImage(
                                                            'assets/images/transportasi.png')
                                                        : const AssetImage(
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
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                              title: Text(
                                _daftarpengeluaran[index]['pengeluaran'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              subtitle: Text(
                                _daftarpengeluaran[index]['waktu'],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                              trailing: Text(
                                '- ${currencyFormatterRp.format(int.parse(removedot(nominalSaja)))}',
                                style: const TextStyle(
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
                                                Expanded(
                                                  child: Text(
                                                    '${_daftarpengeluaran[index]['pengeluaran']}',
                                                    textAlign: TextAlign.right,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      color: Colors.amber,
                                                    ),
                                                  ),
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
                                                  currencyFormatterRp.format(
                                                    int.parse(
                                                        removedot(nominalSaja)),
                                                  ),
                                                  style: const TextStyle(
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
                                                  style: const TextStyle(
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
                                                  style: const TextStyle(
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
                                                  child: const Icon(Icons.edit),
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
                                                  child: const Icon(
                                                      Icons.delete_forever),
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
