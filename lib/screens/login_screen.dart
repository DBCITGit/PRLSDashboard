import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:prodwo_timesheet/main.dart';
import 'package:prodwo_timesheet/preferences/preferences.dart';
import 'package:prodwo_timesheet/services/local_authentication.dart';
import 'package:prodwo_timesheet/services/serivce_locator.dart';
import 'package:prodwo_timesheet/services/webservices/get_by_user.dart';
import 'package:prodwo_timesheet/services/webservices/login/mobile_get_user_id_ws.dart';
import 'package:prodwo_timesheet/services/webservices/login/mobile_login_ws.dart';
import 'package:prodwo_timesheet/services/webservices/login/mobile_password_reset_ws.dart';
import 'package:prodwo_timesheet/services/webservices/webservice.dart';
import 'package:prodwo_timesheet/tools/localizations.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key key}) : super(key: key);
  static void setLocale(BuildContext context, Locale newLocale) {
    _LoginScreenState state =
        context.findAncestorStateOfType<_LoginScreenState>();
    state.setLocale(newLocale);
  }

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Locale _locale;
  setLocale(Locale locale) => setState(() => _locale = locale);
  TextEditingController _emailController;
  TextEditingController _passwordController;
  bool confirmedCredentials = false;
  bool emailValidate = false, passwordValidate = false;

  final LocalAuthenticationService _localAuth =
      locator<LocalAuthenticationService>();

  Future<void> miscAlert(BuildContext context, String message) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "alert",
            textAlign: TextAlign.center,
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
          ),
          actions: [
            FlatButton(
              child: Text(
                'OK',
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                //confirmedCredentials = false;
              },
            ),
          ],
        );
      },
    );
  }

  Widget timeOutDialog(BuildContext context) => Theme(
        data: ThemeData.dark(),
        child: CupertinoAlertDialog(
            title:
                Text('Unable to Retreive Data', style: TextStyle(fontSize: 20)),
            actions: [
              CupertinoDialogAction(
                child: Text('OK'),
                onPressed: () {
                  HapticFeedback.mediumImpact();

                  //'tap ok ');
                  setState(() {
                    Navigator.pop(context);
                    confirmedCredentials = false;
                  });
                },
              )
            ],
            content: Text('There was a network error',
                style: TextStyle(fontSize: 16))),
      );

  // Login Futures
  // pass the map as a parameter to the MyApp screen from the login screen
  List<String> farmingGroups = [];
  Map<String, List<String>> farmingGroupsAndBlocksByUser = {};
  Future<Map<String, List<String>>> getFarmingGroupsAndBlocksByUser(
      String userID) async {
    return await GetByUserWS().getFarmingGroupsAndBlocksByUser(userID);
  }

  Future<void> getFarmingGroupsByUser(String userID) async {
    Map<String, List<String>> result =
        await getFarmingGroupsAndBlocksByUser(userID);
    farmingGroups = result.keys.toList();
    print(farmingGroups);
    return;
  }

  @override
  void initState() {
    super.initState();
    AppL10N().load();
    _emailController = new TextEditingController();
    _passwordController = new TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return MaterialApp(
        locale: _locale,
        supportedLocales: [const Locale("en", "US"), const Locale("es", "MX")],
        localeResolutionCallback: (locale, supportedLocales) {
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode &&
                supportedLocale.countryCode == locale.countryCode) {
              return supportedLocale;
            }
          }
          return supportedLocales.first;
        },
        routes: {
          '/login': (context) => LoginScreen(),
          '/home': (context) => MyApp(),
        },
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Theme.of(context).primaryColor,
          body: FutureBuilder(
              future: Preferences.getEmail(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return Container(
                    child: Center(),
                  );
                } else if (snapshot.hasError) {
                  return Container(
                    child: Center(
                      child:
                          Text("An error has occured. Please try again later."),
                    ),
                  );
                } else {
                  if (snapshot.data != "temp_id")
                    _emailController.text = snapshot.data;
                  return Column(
                    children: [
                      SizedBox(
                        height: 20.h,
                      ),
                      Image.asset(
                        'lib/assets/images/loading.png',
                        height: 5.h,
                        width: 40.w,
                      ),
                      Center(
                        child: SingleChildScrollView(
                          child: Container(
                            margin: EdgeInsets.only(left: 40, right: 40),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                Center(
                                  child: Text(
                                    AppL10N.localStr["signIn"] ?? 'Sign In',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        fontSize: 22),
                                  ),
                                ),
                                TextField(
                                  cursorColor:
                                      Theme.of(context).colorScheme.secondary,
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color:
                                              Theme.of(context).primaryColor),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary),
                                    ),
                                    labelStyle: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary),
                                    icon: Icon(Icons.account_circle,
                                        color: Theme.of(context).primaryColor),
                                    hintText: AppL10N.localStr["emailAddress"],
                                    hintStyle: TextStyle(
                                        color: Theme.of(context).primaryColor),
                                    focusColor: Theme.of(context).primaryColor,
                                    errorText: emailValidate
                                        ? 'Email field can\'t be empty'
                                        : null,
                                    suffixIcon: IconButton(
                                      onPressed: _emailController.clear,
                                      icon: Icon(Icons.clear),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      focusColor: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                  ),
                                ),
                                TextField(
                                  cursorColor:
                                      Theme.of(context).colorScheme.secondary,
                                  obscureText: true,
                                  controller: _passwordController,
                                  decoration: InputDecoration(
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color:
                                              Theme.of(context).primaryColor),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary),
                                    ),
                                    icon: Icon(Icons.lock,
                                        color: Theme.of(context).primaryColor),
                                    labelText: AppL10N.localStr["password"],
                                    labelStyle: TextStyle(
                                        color: Theme.of(context).primaryColor),
                                    errorText: passwordValidate
                                        ? 'Password field can\'t be empty'
                                        : null,
                                  ),
                                ),
                                Container(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    Flexible(
                                      child: DialogButton(
                                        color: Theme.of(context).primaryColor,
                                        onPressed: () async {
                                          if (_emailController.text.isNotEmpty &
                                              _passwordController
                                                  .text.isNotEmpty) {
                                            setState(() {
                                              confirmedCredentials = true;
                                            });
                                            if (_emailController.text
                                                .contains('@')) {
                                              var bytes = utf8.encode(
                                                  _passwordController.text
                                                      .toString());
                                              var digest =
                                                  sha256.convert(bytes);
                                              // start load
                                              String userEmail =
                                                  _emailController.text;
                                              var response;
                                              try {
                                                response = await MobileLoginWS()
                                                    .call(
                                                        userEmail,
                                                        digest.toString(),
                                                        false);

                                                // Navigator.pushNamedAndRemoveUntil(
                                                //     context, "/map", (r) => false);
                                              } catch (e) {
                                                showCupertinoDialog(
                                                    context: context,
                                                    builder: timeOutDialog);
                                              }
                                              // end load
                                              if (response == "1") {
                                                String userID =
                                                    await MobileGetUserIDWS()
                                                        .call(userEmail);
                                                if (userID.length == 0) {
                                                  // the length should never be 0. This check is only for precaution.
                                                  miscAlert(context,
                                                      "Unable to retrieve userID. Please contact the IT department if this issue reoccurs.");
                                                } else {
                                                  await Preferences
                                                      .getPreferences();
                                                  Preferences.savePreferences(
                                                      userEmail, userID);
                                                  //await UserCommoditiesService.call();
                                                  try {
                                                    int district =
                                                        await Webservice()
                                                            .fetchLocation(
                                                                _emailController
                                                                    .text
                                                                    .trim());
                                                    Preferences
                                                        .saveDefaultDistrict(
                                                            district);
                                                    // final info = await PackageInfo
                                                    //     .fromPlatform();
                                                    // await ServerSettingsPreferences
                                                    //     .getPreferences();

                                                    // _packageInfo = info;
                                                    // print(_packageInfo.version +
                                                    //     ' - ' +
                                                    //     _packageInfo.buildNumber);
                                                    // //await UserCommoditiesService.call();
                                                    // ServerSettingsPreferences
                                                    //     .savePreferences(
                                                    //         ServerSettingsPreferences
                                                    //             .currentEmail,
                                                    //         ServerSettingsPreferences
                                                    //             .currentUserID,
                                                    //         ServerSettingsPreferences
                                                    //             .language,
                                                    //         _packageInfo.version,
                                                    //         _packageInfo
                                                    //             .buildNumber);
                                                    // final prefs =
                                                    //     await SharedPreferences
                                                    //         .getInstance();
                                                    // prefs.setString("versionNumber",
                                                    //     _packageInfo.version);
                                                    // prefs.setString("buildNumber",
                                                    //     _packageInfo.buildNumber);
                                                    farmingGroupsAndBlocksByUser =
                                                        await getFarmingGroupsAndBlocksByUser(
                                                            Preferences
                                                                .currentUserID);
                                                    Navigator
                                                        .pushAndRemoveUntil(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        MyApp(
                                                                          farmingGroups:
                                                                              farmingGroupsAndBlocksByUser,
                                                                        )),
                                                            (route) => false);

                                                    // Navigator
                                                    //     .pushNamedAndRemoveUntil(
                                                    //         context,
                                                    //         "/home",
                                                    //         (r) => false);
                                                  } catch (e) {
                                                    showCupertinoDialog(
                                                        context: context,
                                                        builder: timeOutDialog);
                                                  }
                                                }
                                              } else {
                                                setState(() {
                                                  confirmedCredentials = false;
                                                });
                                                SharedPreferences prefs =
                                                    await SharedPreferences
                                                        .getInstance();
                                                prefs.setString(
                                                    'email', "temp_id");
                                                prefs.setString(
                                                    'userID', "temp_user");
                                                miscAlert(context,
                                                    "Invalid information.");
                                              }
                                            } else {
                                              miscAlert(context,
                                                  "Please enter a valid email address.");
                                            }
                                          } else if (_emailController
                                              .text.isEmpty) {
                                            setState(
                                              () {
                                                emailValidate = true;
                                              },
                                            );
                                          } else if (_passwordController
                                              .text.isEmpty) {
                                            setState(
                                              () {
                                                passwordValidate = true;
                                              },
                                            );
                                          } else {
                                            setState(
                                              () {
                                                //"fields empty");
                                                _emailController.clear();
                                                _passwordController.clear();
                                              },
                                            );
                                          }
                                        },
                                        child: confirmedCredentials
                                            ? Lottie.asset(
                                                'lib/assets/lottie/confirmLogin.json',
                                                fit: BoxFit.fill,
                                              )
                                            : Text(
                                                AppL10N.localStr["logIn"] ??
                                                    'Log In',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 19),
                                              ),
                                      ),
                                    ),
                                    Container(
                                      width: 10,
                                    ),
                                    Flexible(
                                      child: DialogButton(
                                        color: Colors.transparent,
                                        child: Text(
                                            AppL10N.localStr["forgotPW"] ??
                                                "Forgot Password",
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.blue)),
                                        onPressed: () async {
                                          String email = _emailController.text;
                                          if (email.isNotEmpty) {
                                            String result =
                                                await MobilePasswordResetWS()
                                                    .call(email);
                                            if (result == "1") {
                                              miscAlert(context,
                                                  "A new password has been sent to $email");
                                            } else {
                                              miscAlert(context,
                                                  "Password reset failed.");
                                            }
                                            _emailController.clear();
                                          } else {
                                            miscAlert(context,
                                                "Please enter an email or username.");
                                            setState(
                                              () {
                                                emailValidate = true;
                                              },
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                    Container(
                                      width: 10,
                                    ),
                                    Flexible(
                                      child: DialogButton(
                                        color: Colors.transparent,
                                        child: Text(
                                            AppL10N.localStr["biometrics"] ??
                                                'Touch or Face ID',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.blue)),
                                        onPressed: () async {
                                          setState(() {
                                            confirmedCredentials = true;
                                          });
                                          await Preferences.getPreferences();
                                          bool hasLogged =
                                              await Preferences.emailExists();
                                          if (Preferences.currentEmail ==
                                              _emailController.text) {
                                            if (hasLogged) {
                                              _localAuth.authenticate().then(
                                                (value) async {
                                                  if (value) {
                                                    await Preferences
                                                        .getPreferences();
                                                    try {
                                                      int district =
                                                          await Webservice()
                                                              .fetchLocation(
                                                                  _emailController
                                                                      .text
                                                                      .trim());
                                                      Preferences
                                                          .saveDefaultDistrict(
                                                              district);
                                                      // final info = await PackageInfo
                                                      //     .fromPlatform();
                                                      // await ServerSettingsPreferences
                                                      //     .getPreferences();
                                                      // _packageInfo = info;
                                                      // print(_packageInfo.version +
                                                      //     ' - ' +
                                                      //     _packageInfo.buildNumber);
                                                      // //await UserCommoditiesService.call();
                                                      // ServerSettingsPreferences
                                                      //     .savePreferences(
                                                      //         ServerSettingsPreferences
                                                      //             .currentEmail,
                                                      //         ServerSettingsPreferences
                                                      //             .currentUserID,
                                                      //         ServerSettingsPreferences
                                                      //             .language,
                                                      //         _packageInfo.version,
                                                      //         _packageInfo
                                                      //             .buildNumber);
                                                      // final prefs =
                                                      //     await SharedPreferences
                                                      //         .getInstance();
                                                      // prefs.setString(
                                                      //     "versionNumber",
                                                      //     _packageInfo.version);
                                                      // prefs.setString("buildNumber",
                                                      //     _packageInfo.buildNumber);
                                                      farmingGroupsAndBlocksByUser =
                                                          await getFarmingGroupsAndBlocksByUser(
                                                              Preferences
                                                                  .currentUserID);
                                                      Navigator
                                                          .pushAndRemoveUntil(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          MyApp(
                                                                            farmingGroups:
                                                                                farmingGroupsAndBlocksByUser,
                                                                          )),
                                                              (route) => false);
                                                      // Navigator
                                                      //     .pushNamedAndRemoveUntil(
                                                      //         context,
                                                      //         "/home",
                                                      //         (r) => false);
                                                    } catch (e) {
                                                      showCupertinoDialog(
                                                          context: context,
                                                          builder:
                                                              timeOutDialog);
                                                    }
                                                    var bytes = utf8.encode(
                                                        _passwordController.text
                                                            .toString());
                                                    String userEmail =
                                                        _emailController.text;
                                                    var response;
                                                    var digest =
                                                        sha256.convert(bytes);
                                                    try {
                                                      response =
                                                          await MobileLoginWS()
                                                              .call(
                                                                  userEmail,
                                                                  digest
                                                                      .toString(),
                                                                  true);

                                                      // Navigator.pushNamedAndRemoveUntil(
                                                      //     context, "/map", (r) => false);
                                                    } catch (e) {
                                                      showCupertinoDialog(
                                                          context: context,
                                                          builder:
                                                              timeOutDialog);
                                                    }
                                                  } else {
                                                    setState(() {
                                                      confirmedCredentials =
                                                          false;
                                                    });
                                                  }
                                                },
                                              );
                                            } else {
                                              miscAlert(context,
                                                  "Login with a valid user ID and password.");
                                            }
                                          } else {
                                            miscAlert(context,
                                                "Login with a valid user ID and password.");
                                            confirmedCredentials = false;
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }
              }),
        ),
      );
    });
  }
}
