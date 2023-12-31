import 'dart:core';
import 'package:doctro/chat/pages/chat_page.dart';
import 'package:doctro/chat/providers/auth_provider.dart';
import 'package:doctro/main.dart';
import 'package:doctro/model/login.dart';
import 'package:doctro/model/otpverify.dart';
import 'package:doctro/model/setting.dart';
import 'package:doctro/retrofit/api_header.dart';
import 'package:doctro/retrofit/base_model.dart';
import 'package:doctro/retrofit/network_api.dart';
import 'package:doctro/constant/app_string.dart';
import 'package:doctro/constant/color_constant.dart';
import 'package:doctro/constant/commn_function.dart';
import 'package:doctro/constant/prefConstatnt.dart';
import 'package:doctro/constant/preferences.dart';
import 'package:doctro/localization/localization_constant.dart';
import 'package:doctro/retrofit/server_error.dart';
import 'package:doctro/screens/phoneverification.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import'dart:io' show Platform;

class SignIn extends StatefulWidget {

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  //Set Height/Width Using MediaQuery
  late double width;
  late double height;

  //Set Open Drawer
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  // Sign In TextInput Controller //
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  // Set Password Visiblity //
  bool _isHidden = true;

  String? deviceToken;

  late AuthProvider authProvider;

  //set verify validation //
  int? verify;

  String messageImage = '';
  String messageName = '';
  String messageId = '';
  String token = '';
  String userToken = '';


  @override
  void initState() {
    super.initState();
    if(Platform.isAndroid){
      SharedPreferenceHelper.setString(Preferences.device_platform, "Android");
    }
    settingrequest();

    var initialzationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings = InitializationSettings(android: initialzationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,onSelectNotification: onSelectNotification);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      Map<String,dynamic> dataValue=message.data;
      String screen=dataValue['screen'].toString();
      messageImage=dataValue['userImage'].toString();
      messageName=dataValue['userName'].toString();
      messageId = dataValue['userId'].toString();
      userToken = dataValue['userToken'].toString();

      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                icon: "@mipmap/ic_launcher",
              ),
            ),
            payload: screen
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        Navigator.of(navigatorKey.currentContext!).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ChatPage(
              peerId: messageId,
              peerAvatar: messageImage,
              peerNickname: messageName,
              token: userToken,
              isNavigate: '',
            ),
          ),
        );

      }
    });
  }

  onSelectNotification(payload) {
    if (payload == "screen") {
      if (messageId.isNotEmpty && messageName.isNotEmpty && messageImage.isNotEmpty) {
        if(SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true){
          Navigator.of(navigatorKey.currentContext!).pushReplacement(
            MaterialPageRoute(
              builder: (context) => ChatPage(
                peerId: messageId,
                peerAvatar: messageImage,
                peerNickname: messageName,
                token: userToken,
                isNavigate: '',
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    authProvider = Provider.of<AuthProvider>(context);

    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: SingleChildScrollView(
          child: Form(
            key: _formkey,
            child: Column(
              children: [
                Container(
                  height: height * 1,
                  width: width * 1,
                  child: Stack(
                    children: [
                      Image.asset(
                        "assets/images/confident-doctor-half.png",
                        height: height * 0.5,
                        width: width * 1,
                        fit: BoxFit.fill,
                      ),
                      Positioned(
                        top: height * 0.36,
                        child: Container(
                          width: width * 1,
                          height: height * 1,
                          decoration: BoxDecoration(
                              color: colorWhite,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(width * 0.1),
                                topRight: Radius.circular(width * 0.1),
                              )),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Container(
                              height: height * 0.6,
                              width: width * 1.0,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    getTranslated(context,login_heading).toString(),
                                    style: TextStyle(
                                        fontSize: width * 0.1,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0XFF333333)),
                                  ),
                                  Text(
                                      getTranslated(context,login_to_your_account).toString(),
                                    style: TextStyle(
                                        fontSize: width * 0.04, color: subheading),
                                  ),
                                  Card(
                                    color: cardColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Container(
                                      height: height * 0.07,
                                      width: width * 0.85,
                                      child: Container(
                                        margin: EdgeInsets.symmetric(horizontal: 10),
                                        child: TextFormField(
                                          controller: email,
                                          textAlign: TextAlign.start,
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: getTranslated(context,login_email_hint).toString(),
                                            hintStyle: TextStyle(
                                                fontSize: width * 0.038,
                                                color: hintColor),
                                          ),
                                            validator: (String? value) {
                                            String emailValidator =value!.trim();
                                              Pattern pattern = r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
                                              RegExp regex = new RegExp(pattern as String);

                                              if (emailValidator.length == 0) {
                                              return getTranslated(context,please_enter_email).toString();
                                            }
                                            if (!regex.hasMatch(emailValidator)) {
                                              return getTranslated(context,please_enter_valid_email).toString();
                                            }
                                            return null;
                                          },
                                          keyboardType: TextInputType.emailAddress,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Card(
                                    color: cardColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Container(
                                      height: height * 0.07,
                                      width: width * 0.85,
                                      child: Container(
                                        margin: EdgeInsets.symmetric(horizontal: 10),
                                        child: TextFormField(
                                          controller: password,
                                          keyboardType: TextInputType.name,
                                            inputFormatters:[FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]'))],
                                          style: TextStyle(fontSize: 16, color:hintColor),
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: getTranslated(context,login_password_hint).toString(),
                                            hintStyle: TextStyle(
                                                fontSize: width * 0.035, color:hintColor),
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _isHidden
                                                    ? Icons.visibility
                                                    : Icons.visibility_off,
                                                color: passwordVisibility,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _isHidden = !_isHidden;
                                                });
                                              },
                                            ),
                                          ),
                                          obscureText: _isHidden,
                                          validator: (String? value) {
                                            if (value!.isEmpty) {
                                              return getTranslated(context,please_enter_password).toString();
                                            }
                                            else if (value.length < 6) {
                                              return getTranslated(context,please_enter_valid_password).toString();
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.symmetric(horizontal: 30),
                                    width: width * 1.0,
                                    height: height * 0.07,
                                    child: ElevatedButton(
                                      child: Text(
                                          getTranslated(context,login_button).toString(),
                                        style: TextStyle(fontSize: width * 0.045),
                                        textAlign: TextAlign.center,
                                      ),
                                      onPressed: () {
                                        if (_formkey.currentState!.validate()) {
                                          CommonFunction.checkNetwork().then((value) {
                                            if(value == true){
                                              callApiForLogin();
                                            }
                                          });
                                        } else {
                                        }
                                      },
                                    ),
                                  ),
                                  TextButton(
                                    child: Text(
                                      getTranslated(context,login_forgot_password).toString(),
                                      style: TextStyle(fontSize: width * 0.042,color: ForgotPasswordScreen),
                                      textAlign: TextAlign.center,
                                    ),
                                    onPressed: () {
                                      Navigator.pushNamed(context, 'ForgotPasswordScreen');
                                    },
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        child: Text(
                                          getTranslated(context,login_dont_have_account).toString(),
                                          style: TextStyle(
                                              fontSize: width * 0.04, color: subheading),
                                        ),
                                      ),
                                      TextButton(
                                        child: Text(
                                          getTranslated(context,login_sign_up).toString(),
                                          style: TextStyle(
                                              fontSize: width * 0.04,
                                              color: loginButton,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        onPressed: () {
                                          Navigator.pushNamed(context, 'signup');
                                          },
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<BaseModel<Login>> callApiForLogin() async {

    Map<String, dynamic> body = {
      "email": email.text,
      "password": password.text,
      "device_token" : SharedPreferenceHelper.getString(Preferences.device_token)
    };

    SharedPreferenceHelper.setString(Preferences.user_email , email.text);
    SharedPreferenceHelper.setString(Preferences.password , password.text);

    Login response;

    try {

      CommonFunction.onLoading(context);
      response = await RestClient(RetroApi().dioData()).loginRequest(body);
      CommonFunction.hideDialog(context);

      if(response.success == true ) {

        SharedPreferenceHelper.setString(Preferences.auth_token, response.data!.token!);
        SharedPreferenceHelper.setString(Preferences.name, response.data!.name!);
        SharedPreferenceHelper.setString(Preferences.phone_no, response.data!.phone!);
        SharedPreferenceHelper.setString(Preferences.email, response.data!.email!);
        SharedPreferenceHelper.setString(Preferences.image, response.data!.image!);
        SharedPreferenceHelper.setInt(Preferences.is_filled, response.data!.isFilled!);
        SharedPreferenceHelper.setBoolean(Preferences.is_logged_in, true);

        if(response.data!.subscriptionStatus == null){
          SharedPreferenceHelper.setInt(Preferences.subscription_status, -1);

        } else {
          SharedPreferenceHelper.setInt(Preferences.subscription_status, response.data!.subscriptionStatus!);
        }
        Navigator.pushReplacementNamed(context, 'loginhome');
        Fluttertoast.showToast(
          msg: response.msg!,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );

        SharedPreferenceHelper.setString(Preferences.chat_profile,response.data!.fullImage!);
        SharedPreferenceHelper.setString(Preferences.user_name,response.data!.name!);
        SharedPreferenceHelper.setString(Preferences.doctorId,response.data!.id.toString());
        authProvider.handleSignIn();

      } else {

        if(response.data != null  && response.data!.verify == 0){
          final data = OtpData(otp: response.data!.otp, id: response.data!.id);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PhoneVerificationScreen(data: data)),);
        } else {
          Fluttertoast.showToast(
            msg: response.msg!,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        }

      }
    } catch (error, stacktrace) {
      CommonFunction.hideDialog(context);
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<Setting>> settingrequest() async {

    Setting response;

    try {

      response = await RestClient(RetroApi().dioData()).settingrequest();

        if( SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true){

            if(response.data!.stripeSecretKey != null){
              SharedPreferenceHelper.setString(Preferences.stripeSecretKey, response.data!.stripeSecretKey!);
            }

            if(response.data!.stripePublicKey != null){
              SharedPreferenceHelper.setString(Preferences.stripPublicKey, response.data!.stripePublicKey!);
            }

            if(response.data!.flutterwaveEncryptionKey != null){
              SharedPreferenceHelper.setString(Preferences.flutterWave_encryption_key, response.data!.flutterwaveEncryptionKey!);
            }

            if(response.data!.flutterwaveKey != null){
              SharedPreferenceHelper.setString(Preferences.flutterWave_key, response.data!.flutterwaveKey!);
            }

            if(response.data!.paystackPublicKey != null){
              SharedPreferenceHelper.setString(Preferences.payStack_public_key, response.data!.paystackPublicKey!);
            }

            if(response.data!.razorKey != null){
              SharedPreferenceHelper.setString(Preferences.razor_key, response.data!.razorKey!);
            }

            if(response.data!.paypalProducationKey != null){
              SharedPreferenceHelper.setString(Preferences.payPal_production_key,response.data!.paypalProducationKey!);
            }

            if(response.data!.paypalSandboxKey != null){
              SharedPreferenceHelper.setString(Preferences.payPal_sandbox_key, response.data!.paypalSandboxKey!);
            }
            
            if(response.data!.paypalClientId != null){
              SharedPreferenceHelper.setString(Preferences.paypal_client_key,response.data!.paypalClientId!);
            }
            
            if(response.data!.paypalSecretKey != null){
              SharedPreferenceHelper.setString(Preferences.paypal_secret_key, response.data!.paypalSecretKey!);
            }

            if(response.data!.currencySymbol != null){
              SharedPreferenceHelper.setString(Preferences.currency_symbol, response.data!.currencySymbol!);
            }

            if(response.data!.currencyCode != null){
              SharedPreferenceHelper.setString(Preferences.currency_code, response.data!.currencyCode!);
            }

            if(response.data!.doctorAppId != null){
              setState(() {
                SharedPreferenceHelper.setString(Preferences.doctorAppId, response.data!.doctorAppId!);
              });

            }

        } else {

          if(response.data!.currencySymbol != null){
            SharedPreferenceHelper.setString(Preferences.currency_symbol, response.data!.currencySymbol!);
          }

          if(response.data!.currencyCode != null){
            SharedPreferenceHelper.setString(Preferences.currency_code, response.data!.currencyCode!);
          }

          if(response.data!.doctorAppId != null){
            setState(() {
              SharedPreferenceHelper.setString(Preferences.doctorAppId, response.data!.doctorAppId!);
            });

          }

          if(response.data!.doctorAppId != null){
               getOneSingleToken(SharedPreferenceHelper.getString(Preferences.doctorAppId));
          }

        }
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

    getOneSingleToken(appId) async {
      OneSignal.shared.consentGranted(true);
      await OneSignal.shared.setAppId(appId);
      OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
      await OneSignal.shared
          .promptUserForPushNotificationPermission(fallbackToSettings: true);
      OneSignal.shared.promptLocationPermission();

        OneSignal.shared.getDeviceState().then((value) {
          if(value!.userId != null){
            SharedPreferenceHelper.setString(Preferences.device_token, value.userId!);
          }
        });

      if (SharedPreferenceHelper.getString(Preferences.device_token) != 'N/A') {
       SharedPreferenceHelper.getString(Preferences.device_token);
      } else {
        getOneSingleToken(appId);
      }
    }
}