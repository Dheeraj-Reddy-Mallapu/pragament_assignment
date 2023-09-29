import 'package:flutter/material.dart';
import 'package:mass_qr/models/settings.dart';
import 'package:mass_qr/pages/login.dart';
import 'package:provider/provider.dart';
import 'package:mass_qr/utils/custom_appbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();

}

class _SettingsPageState extends State<SettingsPage> {

  @override
  Widget build(BuildContext context) {
    SettingsModel settings = Provider.of<SettingsModel>(context, listen: false);
    return Scaffold(
      appBar: customAppBar(
        "Multi QR | Settings",
        hvBack: true
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children:[
            Expanded(
              child: ElevatedButton(
                  onPressed: () async{
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    print(prefs.getKeys());

                    print(prefs.getString("authToken"));
                    await prefs.remove('authToken');
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginPage(),
                        ));
                  },
                  child: Text('Logout')),
            ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}