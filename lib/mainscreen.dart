import 'dart:convert';

// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String mtoken = "";
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  TextEditingController username = TextEditingController();
  TextEditingController title = TextEditingController();
  TextEditingController body = TextEditingController();

  @override
  void initState() {
    super.initState();
    requestPermission();
    getToken();
    initInfo();
  }

  void senPushMessage(String token, String body, String title) async {
    try {
      await http.post(
        Uri.parse("https://fcm.googleapis.com/fcm/send"),
        headers: <String, String>{
          'content-type': 'application/json',
          'Authorization':
              "key=AAAAJ57zVOQ:APA91bEmuNWQMyCH3WrkS1S9Yerk7Gt6FB9hoev8BLLUcxBpA0jLmZuOY9BHDPczNOP6DSMHi3DlYr80M-M38J0ZIKPp-YfrGZQwdiXm-BJoR28_JYKDB7l1Arv_y3v4neLe4wmtRUTm"
        },
        body: jsonEncode(<String, dynamic>{
          'priority': 'high',
          //this section work for navigation
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'status': 'done',
            'body': body,
            'title': title,
          },
          "notification": <String, dynamic>{
            "title": title,
            "body": body,
            "android_channel_id": "dbfood"
          },
          "to": token,
        }),
      );
    } catch (e) {
      print("error push notification");
    }
  }

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("User Grated Permission");
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print("User Grated Provisonal Permission ");
    } else {
      print("UserDeclined Permission ");
    }
  }

  void getToken() async {
    await FirebaseMessaging.instance.getToken().then((token) {
      setState(() {
        mtoken = token!;
        print("my token $mtoken");
      });
      // saveToken(mtoken);
    });
  }

  // void saveToken(String token) async {
  //   await FirebaseFirestore.instance.collection("UserTokens").doc("User1").set({
  //     'token': token,
  //   });
  // }
  Future onSelectNotification(String payload) async {
    showDialog(
      context: context,
      builder: (_) {
        return new AlertDialog(
          title: Text("PayLoad"),
          content: Text("Payload : $payload"),
        );
      },
    );
  }

  initInfo() {
    var androidInitialize =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializatonsSettings =
        InitializationSettings(android: androidInitialize);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("....................on Meesage...............");
      print(
          "onMessage :${message.notification?.title}/${message.notification?.body}");
      BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
        message.notification!.body.toString(),
        htmlFormatBigText: true,
        contentTitle: message.notification!.title.toString(),
        htmlFormatContentTitle: true,
      );
      AndroidNotificationDetails androidPlatformChannelSpecific =
          AndroidNotificationDetails("dbfood", "dbfood",
              importance: Importance.high,
              styleInformation: bigTextStyleInformation,
              priority: Priority.high,
              playSound: true,
            sound: RawResourceAndroidNotificationSound('notification'),
          );
      NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecific);
      await flutterLocalNotificationsPlugin.show(0, message.notification?.title,
          message.notification?.body, platformChannelSpecifics,
          payload: message.data['body']);
    });
    flutterLocalNotificationsPlugin.initialize(
      initializatonsSettings,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: username,
            ),
            TextFormField(
              controller: title,
            ),
            TextFormField(
              controller: body,
            ),
            MaterialButton(
              onPressed: () async {
                print("--->");
                String name = username.text.trim();
                String titleText = title.text;
                String bodyText = body.text;
                // if (name != "") {
                  // DocumentSnapshot snap = await FirebaseFirestore.instance.
                  // collection("UserTokens").doc(name).get();
                  //
                  String token = "eiI5jY9FTAad_59OHjwWMY:APA91bEPvb-sNEkqHLOr1UFy-ZZmXSsTytAbgpbn4bypkEkqMIJOMv6mrkQexl_Df3W2MnNdE6v3lu0DoB6Renxbf9vIXBkOFIpj-rCmfazgZ9maC0tR7SyDkJRSy7_icCp2xEhBJ11k";
                  //  print("token$token");
                //eiI5jY9FTAad_59OHjwWMY:APA91bEPvb-sNEkqHLOr1UFy-ZZmXSsTytAbgpbn4bypkEkqMIJOMv6mrkQexl_Df3W2MnNdE6v3lu0DoB6Renxbf9vIXBkOFIpj-rCmfazgZ9maC0tR7SyDkJRSy7_icCp2xEhBJ11k
                  senPushMessage(
token,                      bodyText,
                      titleText);
                // }
              },
              child: Container(
                margin: EdgeInsets.all(20),
                height: 40,
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.redAccent.withOpacity(0.5),
                    )
                  ],
                ),
                child: Center(
                  child: Text("Butoon"),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
