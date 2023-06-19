import 'dart:convert';
import 'dart:io';
import 'package:doctro/constant/app_string.dart';
import 'package:doctro/constant/color_constant.dart';
import 'package:doctro/localization/localization_constant.dart';
import 'package:doctro/model/purchaseSubscription.dart';
import 'package:doctro/model/setting.dart';
import 'package:doctro/retrofit/api_header.dart';
import 'package:doctro/retrofit/base_model.dart';
import 'package:doctro/retrofit/server_error.dart';
import 'package:doctro/screens/StripePayment.dart';
import 'package:doctro/retrofit/network_api.dart';
import 'package:doctro/constant/prefConstatnt.dart';
import 'package:doctro/constant/preferences.dart';
import 'package:doctro/screens/paypal/paypal_payment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:flutterwave_standard/flutterwave.dart';

enum SingingCharacter { PayPal, RazorPay, Stripe, FlutterWave, PayStack, COD }

class PaymentGetway extends StatefulWidget {

  //Get Data
  final String? plan;
  final  int? value;
  final int? id;
  final String? name ;

  PaymentGetway( {
    this.plan ,
    this.value ,
    this.id,
    this.name
  });

  @override
  _PaymentGetwayState createState() => _PaymentGetwayState();
}

class _PaymentGetwayState extends State<PaymentGetway> {

  SingingCharacter? _character ;

  //All Payment Token Get
  String? aPaymentToken = "";

  //check payment status 0 or 1
  int? cod;
  int? stripe;
  int? payPal;
  int? razor;
  int? flutterWave;
  int? payStack;

  //payment type split
  late var str;
  var parts;
  var startPart;
  var paymenttype;

  //decode pass id
  String? plan;
  int? value;
  int? id;

  /// setttings parameter ///
  String? businessName;
  String? email;
  String? phone;
  String? stripePublicKey;
  String? stripeSecretKey;
  String? paypalSandboxKey;
  String? paypalProducationKey;
  String? razorKey;
  String? flutterwaveKey;
  String? paystackPublicKey = SharedPreferenceHelper.getString(Preferences.payStack_public_key);

  ///razorpay payment///
  late Razorpay _razorpay;

  ///PayStack Payment ///
  final plugin = PaystackPlugin();
  String? paymentToken;

  /// FlutterWave ///
  final String txref = "";
  final String amount = "";

  String totalAmount = '';

  /// Radio Button ///
  int? selectedRadio;

    @override
  void initState() {

    super.initState();

    id = widget.id ;
    plan = widget.plan;
    value = widget.value;

    var amountData = json.decode(plan!);

     totalAmount = amountData[value]['price'];

    settingrequest();

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    /// paystack payment ///
    plugin.initialize(publicKey: paystackPublicKey!);

  }

  ///RazorPay Payment///
  void openCheckout() async {

    String? mobileno = SharedPreferenceHelper.getString(Preferences.phone_no);
    String? email = SharedPreferenceHelper.getString(Preferences.email);

    var parsedata = json.decode(plan!);

    var options = {
      'key': SharedPreferenceHelper.getString(Preferences.razor_key),
      'amount': num.parse("${parsedata[value]['price']}") * 100,
      'name': 'Doctro',
      'description': '',
      'currency' : SharedPreferenceHelper.getString(Preferences.currency_code),
      'prefill': {'contact': mobileno, 'email': email},
      'external': {
        'wallets': ['paytm']
      }
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: e');
    }
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  @override
  Widget build(BuildContext context) {

    cod = SharedPreferenceHelper.getInt(Preferences.COD);
    payPal = SharedPreferenceHelper.getInt(Preferences.PayPal);
    razor = SharedPreferenceHelper.getInt(Preferences.RazorPay);
    stripe = SharedPreferenceHelper.getInt(Preferences.Stripe);
    payStack = SharedPreferenceHelper.getInt(Preferences.PayStack);
    flutterWave = SharedPreferenceHelper.getInt(Preferences.FlutterWave);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
            getTranslated(context, payment_method_heading).toString(),
          style: TextStyle(color: hintColor),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.keyboard_backspace_outlined,
            color: hintColor,
            size: 35.0,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: ListView(
          children: [
            Column(
              children: [

                payPal == 1 && SharedPreferenceHelper.getString(Preferences.device_platform) == "Android"
                    ? Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: Container(
                      decoration: BoxDecoration(boxShadow: [
                        BoxShadow(
                          color: grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 7,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ], borderRadius: BorderRadius.circular(20), color: colorWhite),
                      height: MediaQuery.of(context).size.height * 0.1,
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                        child: Center(
                          child: RadioListTile<SingingCharacter>(
                            controlAffinity: ListTileControlAffinity.trailing,
                            title: Row(
                              children: [
                                Image.asset(
                                  "assets/images/paypal.png",
                                  height: 30,
                                  width: 30,
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.03,
                                ),
                                Text(getTranslated(context, payment_gateway_paypal).toString(), style: TextStyle(fontSize: 16, color: colorBlack)),
                              ],
                            ),
                            value: SingingCharacter.PayPal,
                            activeColor: colorBlack,
                            groupValue: _character,
                            onChanged: (SingingCharacter? value) {
                              setState(() {
                                _character = value;
                              });
                            },
                          ),
                        ),
                      )),
                )
                    : Container(),

                razor == 1
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                        child: Container(
                            decoration: BoxDecoration(boxShadow: [
                              BoxShadow(
                                color: grey.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 7,
                                offset: Offset(0, 3), // changes position of shadow
                              ),
                            ], borderRadius: BorderRadius.circular(20), color: colorWhite),
                            height: MediaQuery.of(context).size.height * 0.1,
                            width: MediaQuery.of(context).size.width,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(05, 0, 0, 0),
                              child: Center(
                                child: RadioListTile<SingingCharacter>(
                                  controlAffinity: ListTileControlAffinity.trailing,
                                  title: Row(
                                    children: [
                                      Image.asset(
                                        "assets/images/razorpay.png",
                                        height: 40,
                                        width: 40,
                                      ),
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width * 0.02,
                                      ),
                                      Text(getTranslated(context, payment_gateway_razorpay).toString(), style: TextStyle(fontSize: 16, color: colorBlack)),
                                    ],
                                  ),
                                  value: SingingCharacter.RazorPay,
                                  activeColor: colorBlack,
                                  groupValue: _character,
                                  onChanged: (SingingCharacter? value) {
                                    setState(() {
                                      _character = value;
                                    });
                                  },
                                ),
                              ),
                            )),
                      )
                    : Container(),

                stripe == 1
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                        child: Container(
                            decoration: BoxDecoration(boxShadow: [
                              BoxShadow(
                                color: grey.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 7,
                                offset: Offset(0, 3), // changes position of shadow
                              ),
                            ], borderRadius: BorderRadius.circular(20), color: colorWhite),
                            height: MediaQuery.of(context).size.height * 0.1,
                            width: MediaQuery.of(context).size.width,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(05, 0, 0, 0),
                              child: Center(
                                child: RadioListTile<SingingCharacter>(
                                  controlAffinity: ListTileControlAffinity.trailing,
                                  title: Row(
                                    children: [
                                      Image.asset(
                                        "assets/images/stripe.png",
                                        height: 40,
                                        width: 40,
                                      ),
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width * 0.02,
                                      ),
                                      Text(getTranslated(context, payment_gateway_stripe).toString(), style: TextStyle(fontSize: 16, color: colorBlack)),
                                    ],
                                  ),
                                  value: SingingCharacter.Stripe,
                                  activeColor: colorBlack,
                                  groupValue: _character,
                                  onChanged: (SingingCharacter? value) {
                                    setState(() {
                                      _character = value;
                                    });
                                  },
                                ),
                              ),
                            )),
                      )
                    : Container(),

                flutterWave == 1
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                        child: Container(
                            decoration: BoxDecoration(boxShadow: [
                              BoxShadow(
                                color: grey.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 7,
                                offset: Offset(0, 3)
                              ),
                            ], borderRadius: BorderRadius.circular(20), color: colorWhite),
                            height: MediaQuery.of(context).size.height * 0.1,
                            width: MediaQuery.of(context).size.width,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(05, 0, 0, 0),
                              child: Center(
                                child: RadioListTile<SingingCharacter>(
                                  controlAffinity: ListTileControlAffinity.trailing,
                                  title: Row(
                                    children: [
                                      Image.asset(
                                        "assets/images/flutterwave.png",
                                        height: 40,
                                        width: 40,
                                      ),
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width * 0.02,
                                      ),
                                      Text(getTranslated(context, payment_gateway_flutter_wave).toString(), style: TextStyle(fontSize: 16, color: colorBlack)),
                                    ],
                                  ),
                                  value: SingingCharacter.FlutterWave,
                                  activeColor: colorBlack,
                                  groupValue: _character,
                                  onChanged: (SingingCharacter? value) {
                                    setState(() {
                                      _character = value;
                                    });
                                  },
                                ),
                              ),
                            )),
                      )
                    : Container(),

                payStack == 1
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                        child: Container(
                            decoration: BoxDecoration(boxShadow: [
                              BoxShadow(
                                color: grey.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 7,
                                offset: Offset(0, 3),
                              ),
                            ], borderRadius: BorderRadius.circular(20), color: colorWhite),
                            height: MediaQuery.of(context).size.height * 0.1,
                            width: MediaQuery.of(context).size.width,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(05, 0, 0, 0),
                              child: Center(
                                child: RadioListTile<SingingCharacter>(
                                  controlAffinity: ListTileControlAffinity.trailing,
                                  title: Row(
                                    children: [
                                      Image.asset(
                                        "assets/images/paystack.png",
                                        height: 40,
                                        width: 40,
                                      ),
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width * 0.02,
                                      ),
                                      Text(getTranslated(context, payment_gateway_pay_stack).toString(), style: TextStyle(fontSize: 16, color: colorBlack)),
                                    ],
                                  ),
                                  value: SingingCharacter.PayStack,
                                  activeColor: colorBlack,
                                  groupValue: _character,
                                  onChanged: (SingingCharacter? value) {
                                    setState(() {
                                      _character = value;
                                    });
                                  },
                                ),
                              ),
                            )),
                      )
                    : Container(),

                cod == 1
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                        child: Container(
                            decoration: BoxDecoration(boxShadow: [
                              BoxShadow(
                                color: grey.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 7,
                                offset: Offset(0, 3),
                              ),
                            ], borderRadius: BorderRadius.circular(20), color: colorWhite),
                            height: MediaQuery.of(context).size.height * 0.1,
                            width: MediaQuery.of(context).size.width,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(05, 0, 0, 0),
                              child: Center(
                                child: RadioListTile<SingingCharacter>(
                                  controlAffinity: ListTileControlAffinity.trailing,
                                  title: Row(
                                    children: [
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width * 0.02,
                                      ),
                                      Text(getTranslated(context, payment_gateway_cod).toString(), style: TextStyle(fontSize: 16, color: colorBlack)),
                                    ],
                                  ),
                                  value: SingingCharacter.COD,
                                  activeColor: colorBlack,
                                  groupValue: _character,
                                  onChanged: (SingingCharacter? value) {
                                    setState(() {
                                      _character = value;
                                    });
                                  },
                                ),
                              ),
                            )),
                      )
                    : Container(),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
          child: GestureDetector(

            onTap: () {

              str = "$_character";
              parts = str.split(".");
              startPart = parts[0].trim();
              paymenttype = parts.sublist(1).join('.').trim();

              if(_character!.index == 0){
                var passData = json.decode(plan!);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) => PaypalPayment(
                      total: totalAmount,
                      duration: passData[value]['month'],
                      name: widget.name!,

                      onFinish: (number) async {
                        if (number != null && number.toString() != '') {
                          aPaymentToken = number.toString();
                          purchasesubscriptions();

                        }
                      },
                    ),
                  ),
                );
              } else if (_character!.index == 1) {
                openCheckout();
              } else if (_character!.index == 2) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Stripe(
                        id: id,
                        plan: plan,
                        value: value,
                       ),
                  ),
                );
              } else if (_character!.index == 3) {
                _handlePaymentInitialization();
              } else if (_character!.index == 4) {
                payStackFunction();
              } else if (_character!.index == 5) {
                purchasesubscriptions();
                Navigator.pushNamed(context, "loginhome");
              }
            },
            child: Container(
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                  color: grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 7,
                  offset: Offset(0, 3)
                ),
              ], borderRadius: BorderRadius.circular(20), color: loginButton),
              height: MediaQuery.of(context).size.height * 0.07,
              width: MediaQuery.of(context).size.width,
              child: Center(
                child: Text(
                  getTranslated(context, payment_gateway_pay).toString(),
                    style: TextStyle(color: colorWhite, fontSize: 20),
                ),
              ),
            ),
          ),
        ),
      ),
    );

  }

  Future<BaseModel<Setting>> settingrequest() async {

    Setting response;
    try {
      response = await RestClient(RetroApi().dioData()).settingrequest();
      if (response.success == true) {
        if (response.data!.cod != null) {
          SharedPreferenceHelper.setInt(Preferences.COD, response.data!.cod!);
        } else {
          SharedPreferenceHelper.setInt(Preferences.COD, 0);
        }

        if (response.data!.paypal != null) {
          SharedPreferenceHelper.setInt(Preferences.PayPal, response.data!.paypal!);
        } else {
          SharedPreferenceHelper.setInt(Preferences.PayPal, 0);
        }

        if (response.data!.paystack != null) {
          SharedPreferenceHelper.setInt(Preferences.PayStack, response.data!.paystack!);
        } else {
          SharedPreferenceHelper.setInt(Preferences.PayStack, 0);
        }

        if (response.data!.razor != null) {
          SharedPreferenceHelper.setInt(Preferences.RazorPay, response.data!.razor!);
        } else {
          SharedPreferenceHelper.setInt(Preferences.RazorPay, 0);
        }

        if (response.data!.flutterwave != null) {
          SharedPreferenceHelper.setInt(Preferences.FlutterWave, response.data!.flutterwave!);
        } else {
          SharedPreferenceHelper.setInt(Preferences.FlutterWave, 0);
        }

        if (response.data!.stripe != null) {
          SharedPreferenceHelper.setInt(Preferences.Stripe, response.data!.stripe!);
        } else {
          SharedPreferenceHelper.setInt(Preferences.Stripe, 0);
        }

        setState(() {
          businessName = response.data!.businessName;
          email = response.data!.email;
          phone = response.data!.phone;
          paypalSandboxKey = response.data!.paypalSandboxKey;
          paypalProducationKey = response.data!.paypalProducationKey;
          paystackPublicKey = response.data!.paystackPublicKey;
          paystackPublicKey = response.data!.paystackPublicKey;
          razorKey = response.data!.razorKey;
          stripePublicKey = response.data!.stripePublicKey;
          stripeSecretKey = response.data!.stripeSecretKey;
          flutterwaveKey = response.data!.flutterwaveKey;

        });
      }
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<PurchaseSubscription>> purchasesubscriptions() async {

    var parsedata = json.decode(plan!);

    Map<String, dynamic> body = {
      "subscription_id": id,
      "payment_token":  _character!.index == 5 ? '' : aPaymentToken,
      "payment_status": _character!.index == 5 ? 0 : 1,
      "payment_type": paymenttype,
      "duration": ("${parsedata[value]['month']}"),
      "amount": ("${parsedata[value]['price']}"),
    };

    PurchaseSubscription response;

    try {
      response = await RestClient(RetroApi().dioData()).purchasesubscriptionrequest(body);
      setState(() {
        SharedPreferenceHelper.setInt(Preferences.subscription_status,1);
        Navigator.pushNamed(context, "loginhome") ;
        Fluttertoast.showToast(
            gravity: ToastGravity.BOTTOM,
            msg: getTranslated(context, payment_success).toString());

      });
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

 ///FlutterWave Payment ///
  _handlePaymentInitialization() async {
        var parsedata = json.decode(plan!);
        var amountToFlutterwave = num.parse("${parsedata[value]['price']}");
        final Customer customer = Customer(
        name: SharedPreferenceHelper.getString(Preferences.name),
        phoneNumber: SharedPreferenceHelper.getString(Preferences.phone_no),
        email: SharedPreferenceHelper.getString(Preferences.email));
        final Flutterwave flutterwave = Flutterwave(
        context: context,
        publicKey: SharedPreferenceHelper.getString(Preferences.flutterWave_key),
        currency: SharedPreferenceHelper.getString(Preferences.currency_code),
        txRef: Uuid().v1(),
        amount:amountToFlutterwave.toString(),
        customer: customer,
        paymentOptions: "card",
        customization: Customization(title: "Doctro"),
        isTestMode: false,
        );
        final ChargeResponse response = await flutterwave.charge();
        if (response != null) {
        aPaymentToken = response.txRef;
        aPaymentToken != ""
          ? purchasesubscriptions()
          : Fluttertoast.showToast(
          gravity: ToastGravity.BOTTOM,
          msg: getTranslated(context, payment_not_complete).toString(), toastLength: Toast.LENGTH_SHORT);
    } else {

    }
  }

  /// paystack payment ///
  payStackFunction() async {

    String? pemail = SharedPreferenceHelper.getString(Preferences.email);
    var parsedata = json.decode(plan!);

    var amountToPaystack = num.parse("${parsedata[value]['price']}") * 100;
    Charge charge = Charge()
      ..amount = amountToPaystack as int
      ..reference = _getReference()
      ..currency = SharedPreferenceHelper.getString(Preferences.currency_code)
      ..email = pemail;
    CheckoutResponse response = await plugin.checkout(
      context,
      method: CheckoutMethod.card,
      charge: charge,
    );
    if (response.status == true) {
      aPaymentToken = response.reference;
      aPaymentToken != ""
          ? purchasesubscriptions()
          : Fluttertoast.showToast(
          gravity: ToastGravity.BOTTOM,
          msg: getTranslated(context, payment_not_complete).toString(), toastLength: Toast.LENGTH_SHORT);
      setState(() {
        paymentToken = response.reference;
      });
    } else {

    }
  }

  String _getReference() {
    String platform;
    if (Platform.isIOS) {
      platform = 'iOS';
    } else {
      platform = 'Android';
    }
    return 'ChargedFrom${platform}_${DateTime.now().millisecondsSinceEpoch}';
  }

  // RazorPay Success Method //

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    aPaymentToken = response.paymentId;
    aPaymentToken != ""
        ? purchasesubscriptions()
        : Fluttertoast.showToast(
        msg: getTranslated(context, payment_not_complete).toString(),
        toastLength: Toast.LENGTH_SHORT);
  }

  void _handlePaymentError(PaymentFailureResponse response) {

  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
        gravity: ToastGravity.BOTTOM,
        msg: "EXTERNAL_WALLET: " + response.walletName!, toastLength: Toast.LENGTH_SHORT);
  }
}