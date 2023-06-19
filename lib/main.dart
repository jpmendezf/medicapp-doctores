import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctro/localization/language_localization.dart';
import 'package:doctro/model/setting.dart';
import 'package:doctro/retrofit/api_header.dart';
import 'package:doctro/retrofit/server_error.dart';
import 'package:doctro/screens/ChangePassword.dart';
import 'package:doctro/screens/Setting.dart';
import 'package:doctro/screens/SignIn.dart';
import 'package:doctro/screens/ViewAllAppointment.dart';
import 'package:doctro/screens/ViewAllNotification.dart';
import 'package:doctro/screens/changeLanguage.dart';
import 'package:doctro/screens/forgotpassword.dart';
import 'package:doctro/screens/videocallhistory.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:doctro/retrofit/base_model.dart';
import 'package:doctro/retrofit/network_api.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'VideoCall/overlay_handler.dart';
import 'chat/pages/home_page.dart';
import 'chat/providers/auth_provider.dart';
import 'chat/providers/chat_provider.dart';
import 'chat/providers/home_provider.dart';
import 'constant/prefConstatnt.dart';
import 'localization/localization_constant.dart';
import 'screens/signup.dart';
import 'screens/phoneverification.dart';
import 'screens/loginhome.dart';
import 'screens/patient_information.dart';
import 'screens/cancelappointment.dart';
import 'screens/appointment_history.dart';
import 'screens/rate&review.dart';
import 'screens/notifications.dart';
import 'screens/profile.dart';
import 'screens/payment.dart';
import 'package:doctro/constant/preferences.dart';
import 'package:doctro/screens/SubScription.dart';
import 'package:doctro/screens/PaymentGetway.dart';
import 'package:doctro/screens/SubscriptionHistory.dart';
import 'package:doctro/screens/ScheduleTimings.dart';
import 'package:doctro/screens/StripePayment.dart';
import'dart:io' show Platform;

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();
  await Firebase.initializeApp();
  await SharedPreferenceHelper.init();

 if(Platform.isAndroid){
    SharedPreferenceHelper.setString(Preferences.device_platform, "Android");
  }

  runApp(MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {

}
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();
const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    importance: Importance.high,
    showBadge: true,
    playSound: true,
    enableVibration: true
);

class MyApp extends StatefulWidget {

  @override
  _MyAppState createState() => _MyAppState();

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>()!;
    state.setLocale(newLocale);
  }

}

class _MyAppState extends State<MyApp> {

  late SharedPreferences _prefs;

  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  get skip => null;

  Locale? _locale;
  String messageImage = '';
  String messageName = '';
  String messageId = '';
  String userToken = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
    settingrequest();
    getToken();
  }

  getToken() async {
   String token = (await FirebaseMessaging.instance.getToken())!;
    if (token.isNotEmpty) {
      SharedPreferenceHelper.setString(Preferences.messageToken, token);
    }
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
            SharedPreferenceHelper.setString(Preferences.paypal_client_key, response.data!.paypalClientId!);
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
            SharedPreferenceHelper.setString(Preferences.doctorAppId, response.data!.doctorAppId!);
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

          setState(() {
            getOneSingleToken(SharedPreferenceHelper.getString(Preferences.doctorAppId));
          });

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
    await OneSignal.shared.promptUserForPushNotificationPermission(fallbackToSettings: true);
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

  Future<SharedPreferences?> init() async {
    _prefs = await SharedPreferences.getInstance();
    return _prefs;
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() {
    getLocale().then((local) => {
      setState(() {
        this._locale = local;
      })
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {

    if (_locale == null) {
      return Container(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    else {

      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);

      return ChangeNotifierProvider<OverlayHandlerProvider>(
        create: (_) => OverlayHandlerProvider(),
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>(
              create: (_) => AuthProvider(
                firebaseAuth: FirebaseAuth.instance,
                prefs: _prefs,
                firebaseFirestore: this.firebaseFirestore,
              ),
            ),
            Provider<HomeProvider>(
              create: (_) => HomeProvider(
                firebaseFirestore: this.firebaseFirestore,
              ),
            ),
            Provider<ChatProvider>(
              create: (_) => ChatProvider(
                prefs: _prefs,
                firebaseFirestore: this.firebaseFirestore,
                firebaseStorage: this.firebaseStorage,
              ),
            ),
          ],
          child: MaterialApp(
            navigatorKey: navigatorKey,
            title: "Doctor",
            debugShowCheckedModeBanner: false,
            home: LoginHome(chat: ""),
            locale: _locale,
            supportedLocales: [
              Locale(ENGLISH, 'US'),
              Locale(ARABIC, 'AE'),
            ],
            localizationsDelegates: [
              LanguageLocalization.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            localeResolutionCallback: (deviceLocal, supportedLocales) {
              for (var local in supportedLocales) {
                if (local.languageCode == deviceLocal!.languageCode &&
                    local.countryCode == deviceLocal.countryCode) {
                  return deviceLocal;
                }
              }
              return supportedLocales.first;
            },

            initialRoute: SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true
                ? 'loginhome'
                : 'SignIn',

            routes: {
              'SignIn': (context) => SignIn(),
              'signup': (context) => CreateAccount(),
              'ForgotPasswordScreen': (context) => ForgotPasswordScreen(),
              'phoneverification': (context) => PhoneVerificationScreen(),
              'ViewAllAppointment': (context) => ViewAllAppointment(),
              'loginhome': (context) => LoginHome(chat: ""),
              'patientinformation': (context) => PatientInformationScreen(),
              'cancelappoitment': (context) => CancelAppointmentScreen(),
              'AppointmentHistoryScreen': (context) => AppointmentHistoryScreen(),
              'rateandreview': (context) => RateAndReviewScreen(),
              'notifications': (context) => NotificationsScreen(),
              'profile': (context) => ProfileScreen(),
              'payment': (context) => PaymentScreen(),
              'subscription': (context) => SubScription(),
              'paymentgetway': (context) => PaymentGetway(),
              'Subscription History': (context) => SubscriptionHistory(),
              'Schedule Timings': (context) => ScheduleTimings(),
              'Change Password': (context) => ChangePassword(),
              'Change Language': (context) => ChangeLanguage(),
              'ViewAllNotification': (context) => ViewAllNotification(),
              'Stripe' :(context) => Stripe(),
              'VideoCallHistory' :(context) => VideoCallHistory(),
              'Settings' : (context) => Seting(),
              'ChatHome' : (context) => HomePage(),
            },
          ),
        ),
      );
    }
  }
}