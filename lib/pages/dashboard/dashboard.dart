import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_file.dart';
import 'package:pengeluaran/charts/lineChart_PengeluaranPerBulan.dart';
import 'package:pengeluaran/charts/pieChart_TipePengeluaran.dart';
import 'package:pengeluaran/function/functions.dart';
import 'package:pengeluaran/pages/daftarpengeluaran/daftarpengeluaran.dart';
import 'package:pengeluaran/databasehelper/dbhelper_pengeluaran.dart';
import 'package:pengeluaran/databasehelper/dbhelper_pendapatan.dart';
import 'package:pengeluaran/static/static.dart';
import 'package:pengeluaran/widgets/mywidget.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

var pendapatanBulanan = 0;
var pengeluaranBulanan = 0;
var totalPengeluaranBulanan = 0;
int totalPengeluaranBulananAkhir = 0;
var totalPendapatanBulananAkhir = 0;
var totalPendapatanBulanan = 0;
var bulanPengeluaran = dtFormatMMMMyyyy(DateTime.now());

void cleanPengeluaran() {
  pendapatanBulanan = 0;
  pengeluaranBulanan = 0;
  totalPengeluaranBulanan = 0;
  totalPengeluaranBulananAkhir = 0;
  totalPendapatanBulananAkhir = 0;
  totalPendapatanBulanan = 0;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id', '');
  runApp(const Dashboard());
}

final db = DatabaseHelper.instance;
final dbPendapatan = DatabaseHelperPendapatan.instance;
DateTime? selectedDate;
DateTime? selectedMonthPengeluaran = DateFormat('MMMM yyyy')
    .parse(DateFormat('MMMM yyyy').format(DateTime.now()));

List<Map<String, dynamic>> _daftarpendapatan = [];

final namaPendapatanController = TextEditingController();
final nominalPendapatanController = TextEditingController();
final waktuPendapatanController = TextEditingController();

final _formKey = GlobalKey<FormState>();

class _DashboardState extends State<Dashboard> {
  @override
  void initState() {
    getPengeluaran(
      selectedMonthPengeluaran,
    );
    getPendapatan(selectedMonthPengeluaran);
    super.initState();
  }

  void loadulang() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const Dashboard(),
      ),
    );
  }

  NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
    name: 'IDR',
  );

  Future<void> getPendapatan(waktuPendapatan) async {
    List<Map<String, dynamic>> dataPendapatan =
        await dbPendapatan.queryAllBulanan(waktuPendapatan);

    // cleanPengeluaran();

    waktuPendapatan =
        (dtFormatMMMMyyyy(waktuPendapatan) ?? dtFormatMMMMyyyy(DateTime.now()));

    // List<Map<String, dynamic>> dataPendapatan = await dbPendapatan.queryAll();

    for (var i = 0; i < dataPendapatan.length; i++) {
      var cekRp = cekContainRp(dataPendapatan[i]['nominal']);
      var pendapatannya = int.parse(removedot(cekRp));

      dtFormatMMMMyyyy(parsingDateFormat(dataPendapatan[i]['waktu'])) ==
              waktuPendapatan
          ? {pendapatanBulanan = pendapatanBulanan + pendapatannya}
          : {};
    }

    setState(() {
      totalPendapatanBulananAkhir = pendapatanBulanan;
    });

    _daftarpendapatan = dataPendapatan;
    if (dataPendapatan.isEmpty) {
      totalPendapatanBulanan = 0;
    } else {
      for (var i = 0; i < dataPendapatan.length; i++) {
        var cekRpPendapatan = cekContainRp(dataPendapatan[i]['nominal']);

        var pendapatannya = int.parse(cekRpPendapatan);

        DateTime waktuPendapatan =
            parsingDateFormat(dataPendapatan[i]['waktu']);

        var bulanIni = bulanSekarang();
        var waktuPendapatannya = dtFormatMMMM(waktuPendapatan);

        if (waktuPendapatannya == bulanIni) {
          setState(() {
            totalPendapatanBulanan = totalPendapatanBulanan + pendapatannya;
          });
        }
      }
    }
  }

  Future<void> getPengeluaran(waktuPengeluaran) async {
    waktuPengeluaran = (dtFormatMMMMyyyy(waktuPengeluaran) ??
        dtFormatMMMMyyyy(DateTime.now()));

    // cleanPengeluaran();
    List<Map<String, dynamic>> dataPengeluaran = await db.queryAll('', '');

    if (waktuPengeluaran == dtFormatMMMMyyyy(DateTime.now())) {
      // Kalau waktuPengeluaran (yang dipilih user) == Bulan saat ini, maka ini dijalankan bang
      for (var i = 0; i < dataPengeluaran.length; i++) {
        var cekRp = cekContainRp(dataPengeluaran[i]['nominal']);
        var pengeluarannya = int.parse(removedot(cekRp));

        dtFormatMMMMyyyy(parsingDateFormat(dataPengeluaran[i]['waktu'])) ==
                bulanTahunSekarang()
            ? {pengeluaranBulanan = pengeluaranBulanan + pengeluarannya}
            : {};
      }
      setState(() {
        totalPengeluaranBulananAkhir = pengeluaranBulanan;
      });
    } else {
      // Kalau waktuPengeluaran != Bulan saat ini, maka ini dijalankan bang

      for (var i = 0; i < dataPengeluaran.length; i++) {
        var cekRp = cekContainRp(dataPengeluaran[i]['nominal']);
        var pengeluarannya = int.parse(removedot(cekRp));

        dtFormatMMMMyyyy(parsingDateFormat(dataPengeluaran[i]['waktu'])) ==
                waktuPengeluaran
            ? {pengeluaranBulanan = pengeluaranBulanan + pengeluarannya}
            : {};
      }
      setState(() {
        totalPengeluaranBulananAkhir = pengeluaranBulanan;
      });
    }
  }

  Future selectMonth(BuildContext context) async {
    final DateTime? picked = await showMonthPickerCustom(context);
    if (picked != null && picked != selectedDate) {
      setState(
        () {
          selectedMonthPengeluaran =
              parsingDateFormatMY(dtFormatMMMMyyyy(picked));
          refreshPage();
        },
      );

      return DateFormat('MMMM yyyy').format(selectedMonthPengeluaran!);
    }
  }

  Future selectDatePendapatan(BuildContext context) async {
    final DateTime? picked = await showDatePickerCustom(context, 'Pendapatan');
    if (picked != null && picked != selectedDate) {
      setState(() {
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
      getPendapatan(selectedMonthPengeluaran);
    });
  }

  Widget containerChart(
      double? totalPengeluaranBulananAkhir, DateTime? waktuPengeluarannya) {
    // Gunakan bulan saat ini jika waktuPengeluarannya null
    waktuPengeluarannya ??= DateTime.now();

    if (totalPengeluaranBulananAkhir != null &&
        totalPengeluaranBulananAkhir > 0) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 220,
            margin: EdgeInsets.only(
                top: defaultPadding / 2,
                left: defaultPadding / 2,
                right: defaultPadding / 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.black38,
            ),
            child: Center(
              child: PieChartTipePengeluaran(waktuPengeluarannya),
            ),
          ),
          totalPengeluaranBulananAkhir != 0
              ? Container(
                  padding: const EdgeInsets.only(
                    top: defaultPadding / 2,
                  ),
                  margin: EdgeInsets.only(
                      left: defaultPadding / 2,
                      right: defaultPadding / 2,
                      top: defaultPadding / 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.black38,
                  ),
                  child: Center(
                    child: LineChartPengeluaranPerBulan(waktuPengeluarannya),
                  ),
                )
              : const SizedBox(),
        ],
      );
    } else {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
      );
    }
  }

  showAndCloseDialog(title, content) async {
    showDialog(
      context: context,
      builder: (context) {
        return showAndCloseAlertDialog(title, content);
      },
    ).then((value) {
      refreshPage();
    });

    if (mounted) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          Navigator.of(context).pop();
        });
      }
    }
  }

  Widget modalBottomPendapatan() {
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
        ),
        child: Column(
          children: [
            const SizedBox(
              height: defaultPadding,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Daftar Pendapatan',
                  style: TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                TextButton.icon(
                  label: const Text(
                    'Tambah',
                    style: TextStyle(color: Colors.grey),
                  ),
                  icon: const Icon(
                    Icons.add_circle,
                    color: Colors.amber,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    showDialogTambahPendapatan();
                  },
                ),
              ],
            ),
            const SizedBox(
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
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () {
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

  showDialogTambahPendapatan() {
    nominalPendapatanController.clear();
    namaPendapatanController.clear();
    waktuPendapatanController.clear();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(defaultPadding / 2),
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          icon: const Icon(
            Icons.add_circle,
            color: Colors.amber,
            size: 50,
          ),
          title: const Row(
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
                          style: const TextStyle(color: Colors.amber),
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
                        style: const TextStyle(color: Colors.amber),
                        validator: (valueWaktu) {
                          if (valueWaktu!.isEmpty) {
                            return 'Waktu Tidak Boleh Kosong';
                          }
                          return null;
                        },
                        onTap: () async {
                          final value = await selectDatePendapatan(context);

                          if (value != null) {}
                        },
                        // onTap: () =>
                        //     selectDatePendapatan(context),
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
                      Navigator.of(context).pop();
                      if (mounted) {
                        showAndCloseDialog(
                            'Berhasil', 'Pendapatan Berhasil Disimpan!');
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
                        await dbPendapatan.delete(idnya);
                        getPendapatan(selectedMonthPengeluaran);
                        Navigator.of(context).pop();
                        showAndCloseDialog(
                            'Berhasil', 'Pendapatan Berhasil Terhapus!');
                      },
                      child: const Text(
                        'Ya',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }

  void refreshPage() {
    cleanPengeluaran();
    getPendapatan(selectedMonthPengeluaran);
    getPengeluaran(selectedMonthPengeluaran);
  }

  @override
  Widget build(BuildContext context) {
    int sisaPendapatan =
        totalPendapatanBulananAkhir - totalPengeluaranBulananAkhir;

    Color sisaPendapatanColor;
    if (sisaPendapatan < 0) {
      sisaPendapatanColor = Colors.red;
    } else if (sisaPendapatan > (totalPendapatanBulananAkhir / 2)) {
      sisaPendapatanColor = Colors.green;
    } else {
      sisaPendapatanColor = Colors.amber[800]!;
    }

    return PopScope(
      canPop: false,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.grey[900],
          body: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: defaultPadding,
                ),
                Container(
                  padding: const EdgeInsets.all(defaultPadding),
                  width: MediaQuery.of(context).size.width - defaultPadding,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.black38,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                  onPressed: () {
                                    selectMonth(context).then((value) {});
                                  },
                                  icon: const Icon(
                                    Icons.edit_calendar_rounded,
                                    color: Colors.white,
                                  )),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Pengeluaran ',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12)),
                                  Row(
                                    children: [
                                      Text(
                                        '${dtFormatMMMMyyyy(selectedMonthPengeluaran!)}',
                                        style: const TextStyle(
                                            color: Colors.amber,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                  onPressed: () {
                                    refreshPage();
                                  },
                                  icon: const Icon(
                                    Icons.replay_circle_filled_outlined,
                                    color: Colors.white,
                                  )),
                              IconButton(
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          contentPadding: const EdgeInsets.all(
                                              defaultPadding / 2),
                                          backgroundColor: Colors.grey[900],
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          icon: const Icon(
                                            Icons.menu_rounded,
                                            color: Colors.amber,
                                            size: 50,
                                          ),
                                          title: const Row(
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
                                                  Navigator.of(context).pop();
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          Daftarpengeluaran(
                                                        waktuPengeluarannya:
                                                            selectedMonthPengeluaran,
                                                      ),
                                                    ),
                                                  ).then(
                                                    (_) {
                                                      refreshPage();
                                                    },
                                                  );
                                                },
                                                label: const Text(
                                                  'Daftar Pengeluaran',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                icon: const Icon(
                                                    Icons.menu_book_rounded,
                                                    color: Colors.white),
                                              ),
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
                                icon: const Icon(
                                  Icons.menu,
                                  size: 32,
                                  color: Colors.amber,
                                ),
                              ),
                            ],
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
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Pendapatan',
                                  style: TextStyle(color: Colors.grey)),
                              Row(
                                children: [
                                  totalPendapatanBulananAkhir == 0
                                      ? Row(
                                          children: [
                                            IconButton(
                                              splashRadius: null,
                                              icon: const Icon(
                                                Icons.add_circle,
                                                color: Colors.amber,
                                              ),
                                              onPressed: () {
                                                showDialogTambahPendapatan();
                                              },
                                            ),
                                            const Column(
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
                                                showModalBottomSheet(
                                                    useSafeArea: true,
                                                    context: context,
                                                    builder: (context) {
                                                      return modalBottomPendapatan();
                                                    });
                                              },
                                              label: Text(
                                                '${totalPendapatanBulananAkhir == 0 ? IconButton(
                                                    hoverColor: Colors.amber,
                                                    splashRadius: 20,
                                                    icon: const Icon(
                                                      Icons.add_circle,
                                                      color: Colors.amber,
                                                    ),
                                                    onPressed: () {
                                                      showDialogTambahPendapatan();
                                                    },
                                                  ) : currencyFormatter.format(totalPendapatanBulananAkhir)}',
                                                style: const TextStyle(
                                                    color: Colors.green,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16),
                                              ),
                                              icon: const Icon(
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
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Pengeluaran ',
                                  style: TextStyle(color: Colors.grey)),
                              totalPengeluaranBulananAkhir == 0
                                  ? Row(
                                      children: [
                                        IconButton(
                                          splashRadius: null,
                                          icon: const Icon(
                                            Icons.add_circle,
                                            color: Colors.amber,
                                          ),
                                          onPressed: () {
                                            nominalPendapatanController.clear();
                                            namaPendapatanController.clear();
                                            waktuPendapatanController.clear();
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    Daftarpengeluaran(
                                                        waktuPengeluarannya:
                                                            selectedMonthPengeluaran),
                                              ),
                                            ).then(
                                              (value) {
                                                refreshPage();
                                              },
                                            );
                                          },
                                        ),
                                        const Column(
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
                                        const Icon(
                                          Icons.arrow_upward,
                                          color: Colors.red,
                                          size: 16,
                                        ),
                                        const SizedBox(
                                          width: defaultPadding / 2,
                                        ),
                                        Text(
                                          currencyFormatter.format(
                                              totalPengeluaranBulananAkhir),
                                          style: const TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                      ],
                                    ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: defaultPadding / 2),
                      totalPendapatanBulananAkhir == 0
                          ? Container()
                          : Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: defaultPadding, vertical: 10),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: sisaPendapatanColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    sisaPendapatan < 0
                                        ? Icons.money_off
                                        : Icons.verified,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: defaultPadding / 2),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Text(
                                            'Sisa Pendapatan ',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12),
                                            textAlign: TextAlign.center,
                                          ),
                                          Text(
                                            ' ${currencyFormatter.format(sisaPendapatan)}.',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            sisaPendapatan < 0
                                                ? 'Anda boros '
                                                : 'Anda hemat ',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12),
                                            textAlign: TextAlign.center,
                                          ),
                                          Text(
                                            ' ${((sisaPendapatan / totalPendapatanBulananAkhir) * 100).toStringAsFixed(2).replaceAll('-', '')} %',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          Text(
                                            ' bulan ${DateFormat('MMMM').format(selectedMonthPengeluaran!)} ini.',
                                            overflow: TextOverflow.visible,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )

                      // Container(
                      //     padding: const EdgeInsets.only(
                      //         left: defaultPadding,
                      //         right: defaultPadding,
                      //         top: 10,
                      //         bottom: 10),
                      //     width: double.infinity,
                      //     decoration: BoxDecoration(
                      //       color: sisaPendapatanColor,
                      //       borderRadius: BorderRadius.circular(10),
                      //     ),
                      //     child: Row(
                      //       mainAxisAlignment: MainAxisAlignment.start,
                      //       children: [
                      //         if (sisaPendapatan < 0) ...[
                      //           Icon(Icons.money_off, color: Colors.white),
                      //         ] else ...[
                      //           Icon(Icons.verified, color: Colors.white),
                      //         ],
                      //         const SizedBox(width: defaultPadding / 2),
                      //         Column(
                      //           crossAxisAlignment:
                      //               CrossAxisAlignment.start,
                      //           children: [
                      //             Row(
                      //               children: [
                      //                 Text(
                      //                   'Sisa Pendapatan ',
                      //                   style: TextStyle(
                      //                       color: Colors.white,
                      //                       fontSize: 12),
                      //                   textAlign: TextAlign.center,
                      //                 ),
                      //                 Text(
                      //                   ' ${currencyFormatter.format(sisaPendapatan)}.',
                      //                   style: TextStyle(
                      //                       color: Colors.white,
                      //                       fontWeight: FontWeight.bold,
                      //                       fontSize: 16),
                      //                   textAlign: TextAlign.center,
                      //                 ),
                      //               ],
                      //             ),
                      //             Row(
                      //               children: [
                      //                 if (sisaPendapatan < 0) ...[
                      //                   Text(
                      //                     'Anda boros ',
                      //                     style: TextStyle(
                      //                       color: Colors.white,
                      //                     ),
                      //                     textAlign: TextAlign.center,
                      //                   ),
                      //                 ] else ...[
                      //                   Text(
                      //                     'Anda hemat ',
                      //                     style: TextStyle(
                      //                         color: Colors.white,
                      //                         fontSize: 12),
                      //                     textAlign: TextAlign.center,
                      //                   ),
                      //                 ],
                      //                 Text(
                      //                   ' ${((sisaPendapatan / totalPendapatanBulananAkhir) * 100).toStringAsFixed(2).replaceAll('-', '')} %',
                      //                   style: TextStyle(
                      //                       color: Colors.white,
                      //                       fontWeight: FontWeight.bold,
                      //                       fontSize: 16),
                      //                   textAlign: TextAlign.center,
                      //                 ),
                      //                 Text(
                      //                   '  bulan ${DateFormat('MMMM').format(selectedMonthPengeluaran!)} ini.',
                      //                   style: TextStyle(
                      //                       color: Colors.white,
                      //                       fontSize: 12),
                      //                   textAlign: TextAlign.center,
                      //                 ),
                      //               ],
                      //             ),
                      //           ],
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                    ],
                  ),
                ),
                containerChart(totalPengeluaranBulananAkhir.toDouble(),
                    selectedMonthPengeluaran),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


//------------------------------------------------------------------------------