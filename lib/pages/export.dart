import 'package:flutter/material.dart';
import 'package:http/io_client.dart';
import 'package:mass_qr/pages/home.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:mass_qr/utils/custom_appbar.dart';
import 'package:mass_qr/models/scans.dart';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class ExportPage extends StatefulWidget {
  ExportPage({Key? key}) : super(key: key);

  @override
  State<ExportPage> createState() => _ExportPageState();

}

class _ExportPageState extends State<ExportPage> {
  String exportTitle = "Default Title";
  List<String> categories = ["Fruits", " Vegetables", "Meat"];
  String? selectedOption = "Fruits";
  Future<void> incrementCount() async {
    SharedPreferences prefStorage = await SharedPreferences.getInstance();
    String? counter = prefStorage.getString('sentCount');
    int currentCount;
    if(counter == null){
      currentCount = 1;
    }else{
      currentCount = int.parse(counter);
      currentCount++;
    }
    await prefStorage.setString('sentCount', currentCount.toString() );
  }
  Future<int> getCount() async {
    SharedPreferences prefStorage = await SharedPreferences.getInstance();
    String? counter = prefStorage.getString('sentCount');
    return int.parse(counter!);
  }



  Future<String> getSession() async {
    HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
      ((X509Certificate cert, String host, int port) => true);
    IOClient ioClient = IOClient(httpClient);
    http.Response session;
    try {
      http.Response session = await ioClient.get(
          Uri.parse(
              "https://massqr.pragathi.business/session/token"
          ));

      int sessionStatus = session.statusCode;

      if (sessionStatus == 200) {
        print(session.body);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: Duration(seconds: 1),
            backgroundColor: Color.fromRGBO(20, 200, 20, 0.5),
            content: Text(
                "Data Exported Successfully")));
        return "";
        return session.body;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: Duration(seconds: 1),
            backgroundColor: Color.fromRGBO(200, 20, 20, 0.5),
            content: Text(
                "Something went wrong, Couldn't connect to Servers")));
        return "";
      }
    } catch (e) {
      print("$e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: Duration(seconds: 1),
          backgroundColor: Color.fromRGBO(200, 20, 20, 0.5),
          content: Text(
              "Something went wrong, Couldn't connect to Servers")));
      return "";
    }
  }

  Future getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  parseScans() {
    ScansModel scans =
    Provider.of<ScansModel>(context, listen: false);
    List<dynamic> data = scans.scans.map((String text) =>

    {
      "id": scans.scans.indexOf(text).toString(),
      "text": text,
    }
    ).toList();

    return data;
  }


  @override
  Widget build(BuildContext context) {
    String sessionToken = "";
    int sentCount = 0;
    final scans = parseScans();
    List<String> categories = ["Fruits", " Vegetables", "Meat"];

    return
    Scaffold(
      appBar: customAppBar(
          "Mass QR | Export Scans",
          hvBack: true
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(6.0 , 2.0 , 0.0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
              Expanded(
                child: Container(
                margin: EdgeInsets.only(bottom:3.5),
                child: DropdownButton<String>(
                  hint: Text('Select option'),
                  value : selectedOption,
                  onChanged: (String? data) =>
                      setState(() => selectedOption = data.toString()),
                  items: categories.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item.toString()),
                    );
                  }).toList(),
                ),
              ),
            ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 3),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Title',
                      contentPadding: EdgeInsets.fromLTRB(5, 5, 0, 0),

                    ),
                    maxLines: 1,
                    maxLength: 50,

                    expands: false,
                    onChanged: (value) {
                      exportTitle = value;
                    },
                  ),
                ),
              ),
              ( scans.length > 0 ?
              Expanded(
                child: Container(
                margin:EdgeInsets.only(bottom: 7),
                  child: ElevatedButton(
                  onPressed: () async {


                    print(scans);
                    sessionToken = await getSession();
                    String authToken = await getAuthToken();
                    await incrementCount();
                    int counter = await getCount();

                    Map<String, String> headers = {
                      'SessionToken': sessionToken,
                      'Firebase-Id-Token': authToken,
                      "content-type":"Application/json",
                    };

                    // Add the payload with the selectedOption and title
                    Map<String, dynamic> payload = {
                      'selectedOption': selectedOption,
                      'title': exportTitle,
                      'count': scans.length.toString(),
                      'scanned': scans
                    };

                    try {

                        // Send the POST request with the payload and headers
                        http.Response response = await http.post(
                          Uri.parse(
                              'https://massqr.pragathi.business/api/v1/mass-qr/send'),
                          headers: headers,
                          body: utf8.decode(utf8.encode(jsonEncode(payload))),
                        );

                        int status = response.statusCode;
                        log("status code $status");
                        if (status == 200) {
                          ScansModel scans =
                          Provider.of<ScansModel>(context, listen: false);
                          scans.removeAll();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomePage(),
                              ));
                        } else {


                          log(response.body);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              duration: Duration(seconds: 1),
                              backgroundColor: Color.fromRGBO(200, 20, 20, 0.5),
                              content: Text(
                                  "Something went wrong, Couldn't connect to Servers")));
                        }


                    }catch(e){
                      print(e);
                      print(headers);
                      print(payload);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          duration: Duration(seconds: 1),
                          backgroundColor: Color.fromRGBO(200, 20, 20, 0.5),
                          content: Text(
                              "Something went wrong, Couldn't connect to Servers")));
                    }
                  },
                  child: Text('Send'),
                ),
                ),
              )
                  : SizedBox()
              ),
            ],
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Consumer<ScansModel>(
                  builder: (context, scans, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(scans.scans.length == 0
                            ? 'No scans yet. Use the Scan button to start.'
                            : '${scans.scans.length} Scan${scans.scans.length >
                            1 ? 's' : ''}:'),
                        (scans.scans.length > 0
                            ? Expanded(
                          child: ListView(
                            children: scans.scans
                                .map((e) =>
                                Container(
                                  child: Text(e),
                                  padding: EdgeInsets.fromLTRB(
                                      0, 10, 0, 10),
                                ))
                                .toList(),
                            shrinkWrap: true,
                          ),
                        )
                        // Replace the Text widget with an Image widget
                            : Image.asset('assets/empty_state.png'))
                      ],
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
        }
  }