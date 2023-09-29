import 'dart:io';
import 'package:cool_dropdown/cool_dropdown.dart';
import 'package:cool_dropdown/models/cool_dropdown_item.dart';
import 'package:fast_charts/fast_charts.dart';
import 'package:flutter/material.dart';
import 'package:mass_qr/pages/export.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:mass_qr/models/scans.dart';
import 'package:mass_qr/pages/help.dart';
import 'package:mass_qr/pages/settings.dart';
import 'package:mass_qr/pages/scan.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DropdownController chartTypeC = DropdownController();

  ChartType selectedChart = ChartType.pie;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final color = Theme.of(context).colorScheme;

    print(selectedChart);

    return Scaffold(
      appBar: AppBar(
        title: Text('MultiQR'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Help',
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HelpPage(),
                  ));
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
          Container(
            child: Consumer<ScansModel>(builder: (context, scans, child) {
              return Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ScanPage(),
                          ),
                        );
                      },
                      child: Text('Scan'),
                    ),
                  ),
                  Expanded(
                    child: IconButton(
                      icon: const Icon(Icons.settings),
                      tooltip: 'Settings',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SettingsPage(),
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: IconButton(
                      icon: const Icon(Icons.delete_rounded),
                      tooltip: "Delete All",
                      onPressed: scans.scans.isEmpty
                          ? null
                          : () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Are you sure?'),
                                  content:
                                      Text('This will delete all scans.\n\nTo save them first, use the Export button'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        scans.removeAll();
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Deleted'),
                                          ),
                                        );
                                      },
                                      child: Text('Delete'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Theme.of(context).colorScheme.error,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ExportPage(),
                          ),
                        );
                      },
                      child: Text('Export'),
                    ),
                  ),
                ],
              );
            }),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Consumer<ScansModel>(
                builder: (context, scans, child) {
                  Map<String, ({int count})> chartData = {};
                  for (final scan in scans.scans) {
                    int indexOfStar = scan.indexOf('*');
                    chartData.putIfAbsent(scan.substring(0, indexOfStar), () => (count: 1));
                    if (chartData.containsKey(scan.substring(0, indexOfStar))) {
                      chartData.update(scan.substring(0, indexOfStar), (value) => (count: value.count + 1));
                    }
                  }

                  return scans.scans.isEmpty
                      ? Center(heightFactor: 2, child: Image(image: AssetImage('assets/empty_state.png')))
                      : SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                                child: Container(
                                  decoration: BoxDecoration(color: color.surface),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          'Chart type',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Center(
                                          child: SizedBox(
                                            width: size.width * 0.75,
                                            child: CoolDropdown(
                                              dropdownItemOptions: const DropdownItemOptions(isMarquee: true),
                                              dropdownList: [
                                                CoolDropdownItem(label: 'Pie Chart', value: ChartType.pie),
                                                CoolDropdownItem(label: 'Column Chart', value: ChartType.column),
                                                CoolDropdownItem(label: 'Bar Chart', value: ChartType.bar),
                                              ],
                                              controller: chartTypeC,
                                              onChange: (value) async {
                                                if (chartTypeC.isError) {
                                                  await chartTypeC.resetError();
                                                }
                                                chartTypeC.close();

                                                setState(() => selectedChart = value);
                                              },
                                              defaultItem: CoolDropdownItem(label: 'Pie Chart', value: ChartType.pie),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Text(
                                'Count',
                                style: TextStyle(fontSize: 22, color: Colors.grey),
                              ),
                              if (selectedChart == ChartType.pie)
                                SizedBox(
                                  height: size.height / 2,
                                  child: PieChart(
                                    data: Series(
                                      data: chartData,
                                      colorAccessor: (domain, value) => Color(0xFF0E7AC7 * value.count),
                                      measureAccessor: (value) => value.count.toDouble(),
                                      labelAccessor: (domain, value, percent) => ChartLabel(
                                        '$domain (${value.count})',
                                        position: LabelPosition.outside,
                                        style: TextStyle(color: Theme.of(context).colorScheme.inverseSurface),
                                      ),
                                    ),
                                    strokes: StrokesConfig(
                                      inner: true,
                                      outer: true,
                                      width: 1,
                                      color: Theme.of(context).colorScheme.inverseSurface,
                                    ),
                                  ),
                                ),
                              if (selectedChart == ChartType.column)
                                SizedBox(
                                  height: size.height / 2,
                                  child: BarChart(
                                    valueAxis: Axis.vertical,
                                    data: [
                                      Series(
                                        data: chartData,
                                        colorAccessor: (domain, value) => Color(0xFF0E7AC7),
                                        measureAccessor: (value) => value.count.toDouble(),
                                      ),
                                    ],
                                    groupSpacing: 5,
                                  ),
                                ),
                              if (selectedChart == ChartType.bar)
                                SizedBox(
                                  height: size.height / 2,
                                  child: BarChart(
                                    valueAxis: Axis.horizontal,
                                    data: [
                                      Series(
                                        data: chartData,
                                        colorAccessor: (domain, value) => Color(0xFF0E7AC7),
                                        measureAccessor: (value) => value.count.toDouble(),
                                      ),
                                    ],
                                  ),
                                ),
                              Text(
                                scans.scans.join(', '),
                                style: TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                        );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String generateNowString() {
  String fillZeros(String string, int length) {
    while (string.length < length) string = '0' + string;
    return string;
  }

  DateTime now = DateTime.now();
  return now.year.toString() +
      '-' +
      fillZeros(now.month.toString(), 2) +
      '-' +
      fillZeros(now.day.toString(), 2) +
      '-' +
      fillZeros(now.hour.toString(), 2) +
      '-' +
      fillZeros(now.minute.toString(), 2) +
      '-' +
      fillZeros(now.second.toString(), 2) +
      '-' +
      fillZeros(now.millisecond.toString(), 3);
}

Future<void> exportData(List<String> scans) async {
  String fileName = 'MassQR-Export-${generateNowString()}.txt';
  final String path = '${(await getTemporaryDirectory()).path}/$fileName';
  final File file = File(path);
  await file.writeAsString(scans.join('\n'), flush: true);
  await Share.shareFiles([path], text: 'MassQR Export');
}

enum ChartType {
  pie,
  bar,
  column,
}
