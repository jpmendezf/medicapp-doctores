import 'package:doctro/constant/app_string.dart';
import 'package:doctro/constant/color_constant.dart';
import 'package:doctro/constant/prefConstatnt.dart';
import 'package:doctro/constant/preferences.dart';
import 'package:doctro/localization/localization_constant.dart';
import 'package:doctro/screens/changeLanguage.dart';
import 'package:flutter/material.dart';
import 'ChangePassword.dart';
import 'SubscriptionHistory.dart';

class Seting extends StatefulWidget {
  @override
  _SetingState createState() => _SetingState();
}

class _SetingState extends State<Seting> {
  @override
  Widget build(BuildContext context) {
    double width;
    double height;
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size(20, 65),
          child: SafeArea(
              top: true,
              child: Column(children: [
                Container(
                  margin: EdgeInsets.only(
                      left: width * 0.06, right: width * 0.06, top: height * 0.02),
                  child: Row(
                    children: [
                      Container(
                          child: GestureDetector(
                            child: Icon(Icons.arrow_back_ios),
                            onTap: () {
                              Navigator.pop(context);
                            },
                          )),
                      Container(
                          margin: EdgeInsets.only(left: width /3.5),
                          child: Text(
                            getTranslated(context, drawer_setting).toString(),
                            style: TextStyle(fontSize: 20,color: hintColor),
                            textAlign: TextAlign.center,
                          )),
                    ],
                  ),
                ),
              ]))) ,
      body: Container(
        height: height,
        width: width,
        color: back,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: height * 0.03,
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChangeLanguage()),
                      );
                    },
                    minLeadingWidth: 20,
                    title: Text(
                      getTranslated(context,drawer_change_language).toString(),
                      style: TextStyle(
                          color: colorButton,
                          fontSize: 16,
                          ),
                    ),
                    trailing: Icon(
                      Icons.keyboard_arrow_right_sharp,
                      color: colorButton,
                      size: 30,
                    ),
                  ),

                  ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChangePassword()),
                      );
                    },
                    minLeadingWidth: 20,

                    title: Text(
                      getTranslated(context,drawer_change_password).toString(),
                      style: TextStyle(
                        color: colorButton,
                        fontSize: 16,
                      ),
                    ),
                    trailing: Icon(
                      Icons.keyboard_arrow_right_sharp,
                      color: colorButton,
                      size: 30,
                    ),
                  ),
              SharedPreferenceHelper.getInt(Preferences.subscription_status)  == 1 ?  ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SubscriptionHistory()),
                      );
                    },
                    minLeadingWidth: 20,

                    title: Text(
                      getTranslated(context,drawer_subscription_history).toString(),
                      style: TextStyle(
                        color: colorButton,
                        fontSize: 16,
                      ),
                    ),
                    trailing: Icon(
                      Icons.keyboard_arrow_right_sharp,
                      color: colorButton,
                      size: 30,
                    ),
                  ) : Container()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


