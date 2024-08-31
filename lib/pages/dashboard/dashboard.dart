// import 'dart:math';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_file.dart';
import 'package:pengeluaran/charts/LineChartPengeluaranPerBulan.dart';
// import 'package:pengeluaran/charts/lineChartPengeluaran.dart';
import 'package:pengeluaran/charts/pieChartTipePengeluaran.dart';
import 'package:pengeluaran/model/pendapatan_m.dart';
import 'package:pengeluaran/pages/daftarpengeluaran/daftarpengeluaran.dart';
import 'package:pengeluaran/databasehelper/dbhelper_pengeluaran.dart';
import 'package:pengeluaran/databasehelper/dbhelper_pendapatan.dart';
import 'package:pengeluaran/static/static.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id', '');
  runApp(Dashboard());
}

class _DashboardState extends State<Dashboard> {
  final db = DatabaseHelper.instance;
  final dbPendapatan = DatabaseHelperPendapatan.instance;
  DateTime? selectedDate;

  List<Map<String, dynamic>> _daftarpengeluaran = [];
  List<Map<String, dynamic>> _daftarpendapatan = [];

  var totalPengeluaranBulanan = 0;
  var totalPendapatanBulanan = 0;

  final namaPendapatanController = TextEditingController();
  final nominalPendapatanController = TextEditingController();
  final waktuPendapatanController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    setState(() {
      getPengeluaran();
      getPendapatan();
    });
    super.initState();
  }

  void loadulang() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const Dashboard(),
    ));
  }

  NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
    name: 'IDR',
  );

  Future<void> getPendapatan() async {
    totalPendapatanBulanan = 0;
    List<Map<String, dynamic>> dataPendapatan = await dbPendapatan.queryAll();
    _daftarpendapatan = dataPendapatan;
    if (dataPendapatan.isEmpty) {
      totalPendapatanBulanan = 0;
    } else {
      for (var i = 0; i < dataPendapatan.length; i++) {
        var cekRpPendapatan = dataPendapatan[i]['nominal']
                    .toString()
                    .contains('Rp ') ==
                true
            ? dataPendapatan[i]['nominal'].toString().replaceAll('Rp ', '')
            : dataPendapatan[i]['nominal'].toString().contains('Rp') == true
                ? dataPendapatan[i]['nominal'].toString().replaceAll('Rp', '')
                : dataPendapatan[i]['nominal'];

        var Pendapatannya = int.parse(cekRpPendapatan);
        // totalPendapatanBulanan = totalPendapatanBulanan + Pendapatannya;

        DateTime waktuPendapatan =
            DateFormat('EEEE dd MMMM yyyy').parse(dataPendapatan[i]['waktu']);

        var bulanIni = DateFormat('MMMM').format(DateTime.now());
        var waktuPendapatannya = DateFormat('MMMM').format(waktuPendapatan);

        if (waktuPendapatannya == bulanIni) {
          setState(() {
            totalPendapatanBulanan = totalPendapatanBulanan + Pendapatannya;
          });
        }
      }
    }
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
        waktuPendapatanController.text =
            DateFormat('EEEE dd MMMM yyyy').format(picked);
      });
    } else {
      waktuPendapatanController.text =
          DateFormat('EEEE dd MMMM yyyy').format(DateTime.now());
    }
  }

  Future<void> tambahPendapatan(nama, nominal, waktu) async {
    final Map<String, dynamic> row = {
      DatabaseHelperPendapatan.columnPendapatan: nama,
      DatabaseHelperPendapatan.columnNominal: nominal,
      DatabaseHelperPendapatan.columnWaktu: waktu,
    };

    try {
      await DatabaseHelperPendapatan.instance.insert(row);
    } catch (e) {
      print('ada error ini bang $e');
    }
    setState(() {
      getPendapatan();
    });
  }

  Future<void> getPengeluaran() async {
    List<Map<String, dynamic>> dataPengeluaran = await db.queryAll();

    for (var i = 0; i < dataPengeluaran.length; i++) {
      var cekRp = dataPengeluaran[i]['nominal'].toString().contains('Rp ') ==
              true
          ? dataPengeluaran[i]['nominal'].toString().replaceAll('Rp ', '')
          : dataPengeluaran[i]['nominal'].toString().contains('Rp') == true
              ? dataPengeluaran[i]['nominal'].toString().replaceAll('Rp', '')
              : dataPengeluaran[i]['nominal'];

      var Pengeluarannya = int.parse(cekRp);

      totalPengeluaranBulanan = totalPengeluaranBulanan + Pengeluarannya;
    }

    setState(() {
      _daftarpengeluaran = dataPengeluaran;
    });
  }

  Widget containerChart() {
    return Column(
      children: [
        Container(
          color: Colors.transparent,
          child: Center(child: PieChartTipePengeluaran()),
        ),
        Container(
          color: Colors.transparent,
          child: Center(child: LineChartPengeluaranPerBulan()),
        ),
      ],
    );
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

  Widget ModalBottomPendapatan() {
    return Container(
      width: MediaQuery.of(context).size.width - defaultPadding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        color: Colors.grey[850],
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: defaultPadding,
          right: defaultPadding,
          // bottom: defaultPadding * 2
        ),
        child: Column(
          children: [
            SizedBox(
              height: defaultPadding,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daftar Pendapatan',
                  style: TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                TextButton.icon(
                  label: Text(
                    'Tambah',
                    style: TextStyle(color: Colors.grey),
                  ),
                  icon: Icon(
                    Icons.add_circle,
                    color: Colors.amber,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    ShowDialogTambahPendapatan();
                  },
                ),
              ],
            ),
            SizedBox(
              height: defaultPadding,
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _daftarpendapatan.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Card(
                        color: Colors.grey[800],
                        child: ListTile(
                          leading: Text(
                            '${index + 1}',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  _daftarpendapatan[index]['pendapatan']
                                      .toString(),
                                  style: TextStyle(
                                      color: Colors.grey[300],
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                              Text(
                                currencyFormatter.format(
                                  int.parse(
                                    _daftarpendapatan[index]['nominal']
                                        .toString()
                                        .replaceAll('Rp ', ''),
                                  ),
                                ),
                                style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _daftarpendapatan[index]['waktu'].toString(),
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              // delete pendapatan
                              deletePendapatan(
                                _daftarpendapatan[index]['id'],
                                _daftarpendapatan[index]['pendapatan'],
                                _daftarpendapatan[index]['nominal'],
                              );
                            },
                          ),
                        ),
                      ),
                      index == _daftarpendapatan.length - 1
                          ? const SizedBox(
                              height: defaultPadding,
                            )
                          : const SizedBox()
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void ShowDialogTambahPendapatan() {
    nominalPendapatanController.clear();
    namaPendapatanController.clear();
    waktuPendapatanController.clear();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(defaultPadding / 2),
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          icon: Icon(
            Icons.add_circle,
            color: Colors.amber,
            size: 50,
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: defaultPadding / 2,
              ),
              Text(
                'Tambah Pendapatan',
              ),
            ],
          ),
          titleTextStyle: const TextStyle(
            color: Colors.amber,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: defaultPadding / 2,
                    right: defaultPadding / 2,
                    bottom: defaultPadding / 2),
                child: Form(
                  key: _formKey,
                  child: Column(
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
                        controller: namaPendapatanController,
                        decoration: InputDecoration(
                          labelText: 'Pendapatan',
                          hintText: 'Isikan Nama Pendapatan',
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
                          controller: nominalPendapatanController,
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
                                if (nominalPendapatanController.text != 'Rp ') {
                                  nominalPendapatanController.text =
                                      currencyFormatter
                                          .format(int.parse(value));
                                } else {
                                  nominalPendapatanController.clear();
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
                        controller: waktuPendapatanController,
                        decoration: const InputDecoration(
                          labelText: 'Waktu',
                          hintText: 'Isikan Waktu Pengeluaran',
                          hintStyle: TextStyle(color: Colors.grey),
                          labelStyle: TextStyle(color: Colors.white),
                          errorStyle: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                    if (_formKey.currentState!.validate()) {
                      tambahPendapatan(
                        namaPendapatanController.text,
                        nominalPendapatanController.text,
                        waktuPendapatanController.text,
                      );
                      // setState(() {
                      // });

                      Navigator.of(context).pop();
                      if (mounted) {
                        showAndCloseDialog(
                            'Berhasil', 'Pendapatan Berhasil Tersimpan!');
                      }
                    }
                  },
                  child: const Text(
                    'Simpan',
                    style: TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> deletePendapatan(
      int idnya, String pendapatan, String nominal) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
              ),
              backgroundColor: Colors.grey[850],
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$pendapatan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                      '${currencyFormatter.format(int.parse(nominal.replaceAll('Rp ', '')))}',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 20,
                      )),
                  const SizedBox(height: defaultPadding),
                  const Text('Hapus pengeluaran ini ?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      )),
                  const SizedBox(height: defaultPadding / 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(
                          style: TextButton.styleFrom(
                              padding: EdgeInsets.only(
                                  left: defaultPadding * 2,
                                  right: defaultPadding * 2),
                              backgroundColor: Colors.grey[900]),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Tidak',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ))),
                      TextButton(
                          style: TextButton.styleFrom(
                              padding: EdgeInsets.only(
                                  left: defaultPadding * 2,
                                  right: defaultPadding * 2),
                              backgroundColor: Colors.red),
                          onPressed: () async {
                            Navigator.of(context).pop();
                            await dbPendapatan.delete(idnya).then((value) {
                              loadulang();
                            });
                            showAndCloseDialog(
                                'Berhasil', 'Pendapatan Berhasil Terhapus!');
                          },
                          child: const Text('Ya',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              )))
                    ],
                  )
                ],
              ));
        });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.grey[900],
          body: SingleChildScrollView(
            child: Expanded(
              child: Column(
                children: [
                  SizedBox(
                    height: defaultPadding,
                  ),
                  Container(
                      padding: const EdgeInsets.all(defaultPadding),
                      width: MediaQuery.of(context).size.width -
                          defaultPadding * 2,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[850],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        setState(() {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const Dashboard(),
                                            ),
                                          );
                                        });
                                      },
                                      icon: Icon(
                                        Icons.refresh,
                                        color: Colors.white,
                                      )),
                                  Text(
                                    'Pengeluaran ',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                  Text(
                                    '${(DateFormat('MMMM yyyy').format(DateTime.now()))}',
                                    style: TextStyle(
                                        color: Colors.amber,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              IconButton(
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          contentPadding: EdgeInsets.all(
                                              defaultPadding / 2),
                                          backgroundColor: Colors.grey[900],
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          icon: Icon(
                                            Icons.menu_rounded,
                                            color: Colors.amber,
                                            size: 50,
                                          ),
                                          title: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                width: defaultPadding / 2,
                                              ),
                                              Text(
                                                'Daftar Menu',
                                              ),
                                            ],
                                          ),
                                          titleTextStyle: const TextStyle(
                                            color: Colors.amber,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                          content: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              TextButton.icon(
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            const Dashboard(),
                                                      ),
                                                    );
                                                  },
                                                  label: Text(
                                                    'Beranda',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  icon: Icon(Icons.home_rounded,
                                                      color: Colors.white)),
                                              TextButton.icon(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            const Daftarpengeluaran(),
                                                      ),
                                                    ).then((value) {
                                                      if (mounted) {
                                                        loadulang();
                                                      }
                                                    });
                                                  },
                                                  label: Text(
                                                    'Daftar Pengeluaran',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  icon: Icon(
                                                      Icons.menu_book_rounded,
                                                      color: Colors.white)),
                                              TextButton.icon(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  label: Text(
                                                    'Menu Mendatang',
                                                    style: TextStyle(
                                                        color:
                                                            Colors.grey[700]),
                                                  ),
                                                  icon: Icon(
                                                      Icons.commit_rounded,
                                                      color: Colors.grey[700])),
                                            ],
                                          ),
                                        );
                                      });
                                },
                                icon: Icon(
                                  Icons.menu,
                                  size: 32,
                                  color: Colors.amber,
                                ),
                              )
                            ],
                          ),
                          Divider(
                            color: Colors.grey[800],
                            thickness: 1,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Pendapatan',
                                      style: TextStyle(color: Colors.grey)),
                                  Row(
                                    children: [
                                      totalPendapatanBulanan == 0
                                          ? Row(
                                              children: [
                                                IconButton(
                                                  splashRadius: null,
                                                  icon: Icon(
                                                    Icons.add_circle,
                                                    color: Colors.amber,
                                                  ),
                                                  onPressed: () {
                                                    ShowDialogTambahPendapatan();
                                                  },
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Tambah',
                                                      style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 12),
                                                    ),
                                                    Text(
                                                      'Pendapatan',
                                                      style: TextStyle(
                                                          color: Colors.green,
                                                          fontSize: 12),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            )
                                          : Row(
                                              children: [
                                                TextButton.icon(
                                                  style: TextButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.grey[800],
                                                  ),
                                                  onPressed: () {
                                                    // wkwkwk
                                                    showModalBottomSheet(
                                                        useSafeArea: true,
                                                        context: context,
                                                        builder: (context) {
                                                          return ModalBottomPendapatan();
                                                        });
                                                  },
                                                  label: Text(
                                                    '${totalPendapatanBulanan == 0 ? IconButton(
                                                        hoverColor:
                                                            Colors.amber,
                                                        splashRadius: 20,
                                                        icon: Icon(
                                                          Icons.add_circle,
                                                          color: Colors.amber,
                                                        ),
                                                        onPressed: () {
                                                          ShowDialogTambahPendapatan();
                                                        },
                                                      ) : currencyFormatter.format(totalPendapatanBulanan)}',
                                                    style: TextStyle(
                                                        color: Colors.green,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16),
                                                  ),
                                                  icon: Icon(
                                                    Icons.arrow_downward,
                                                    color: Colors.green,
                                                    size: 16,
                                                  ),
                                                ),
                                              ],
                                            )
                                    ],
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Pengeluaran',
                                      style: TextStyle(color: Colors.grey)),
                                  totalPengeluaranBulanan == 0
                                      ? Row(
                                          children: [
                                            IconButton(
                                              splashRadius: null,
                                              icon: Icon(
                                                Icons.add_circle,
                                                color: Colors.amber,
                                              ),
                                              onPressed: () {
                                                nominalPendapatanController
                                                    .clear();
                                                namaPendapatanController
                                                    .clear();
                                                waktuPendapatanController
                                                    .clear();
                                                ShowDialogTambahPendapatan();
                                              },
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Tambah',
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 12),
                                                ),
                                                Text(
                                                  'Pengeluaran',
                                                  style: TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 12),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )
                                      : Row(
                                          children: [
                                            Icon(
                                              Icons.arrow_upward,
                                              color: Colors.red,
                                              size: 16,
                                            ),
                                            SizedBox(
                                              width: defaultPadding / 2,
                                            ),
                                            Text(
                                              '${currencyFormatter.format(totalPengeluaranBulanan)}',
                                              style: TextStyle(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            ),
                                          ],
                                        ),
                                ],
                              ),
                            ],
                          )
                        ],
                      )),
                  Container(
                    width:
                        MediaQuery.of(context).size.width - defaultPadding * 2,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.green[900],
                    ),
                  ),
                  totalPengeluaranBulanan != 0
                      ? containerChart()
                      : Center(
                          child: Column(
                            children: [
                              SizedBox(
                                height: defaultPadding * 5,
                              ),
                              Icon(
                                Icons.thumb_up_alt_rounded,
                                size: 100,
                                color: Colors.grey[850],
                              ),
                              Text(
                                'Belum ada data pengeluaran',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
