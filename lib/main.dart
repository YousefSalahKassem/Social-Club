import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialclub/Constants/Constantcolors.dart';
import 'package:socialclub/screens/AltPtofile/alt_profileHelper.dart';

import 'package:socialclub/screens/Chatroom/chat_roomHelper.dart';
import 'package:socialclub/screens/Chatroom/chatroom.dart';
import 'package:socialclub/screens/DirectChat/DirectChatHelper.dart';
import 'package:socialclub/screens/Feed/feed_helpers.dart';
import 'package:socialclub/screens/HomePage/home_page_helper.dart';
import 'package:socialclub/screens/LandingPage/landing_helper.dart';
import 'package:socialclub/screens/LandingPage/landing_services.dart';
import 'package:socialclub/screens/LandingPage/landing_utils.dart';
import 'package:socialclub/screens/Messaging/GroupMessageHelper.dart';
import 'package:socialclub/screens/Profile/ProfileHelpers.dart';
import 'package:socialclub/screens/Stories/StoriesHelper.dart';
import 'package:socialclub/screens/postDetails/postDetails_helper.dart';
import 'package:socialclub/screens/splashScreen/splash_screen.dart';
import 'package:socialclub/services/FirebaseOperations.dart';
import 'package:socialclub/services/Notifications.dart';
import 'package:socialclub/services/authentication.dart';
import 'package:socialclub/utils/Uploadpost.dart';
import 'package:socialclub/utils/postOptions.dart';

void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  await Firebase.initializeApp();
  FirebaseFirestore.instance.settings =
      Settings(
      persistenceEnabled: true,);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    LocalNotifications.initialize(context);
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if(message!=null){
        final routeFromMessage=message.data['route'];
        Navigator.of(context).pushNamed(routeFromMessage);
      }
    });
    FirebaseMessaging.onMessage.listen((message) {
      if(message.notification!=null){
        print(message.notification!.body);
      }
      LocalNotifications.display(message);

    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final routeFromMessage=message.data['route'];
      Navigator.of(context).pushNamed(routeFromMessage);
      print(routeFromMessage);
    });
  }

  @override
  Widget build(BuildContext context) {
    ConstantColors constantColors=ConstantColors();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_)=>PostDetailsHelper()),
        ChangeNotifierProvider(create: (_)=>StoriesHelper()),
        ChangeNotifierProvider(create: (_)=>DirectChatHelper()),
        ChangeNotifierProvider(create: (_)=>GroupMessageHelper()),
        ChangeNotifierProvider(create: (_)=>ChatRoomHelper()),
        ChangeNotifierProvider(create: (_)=>AltProfileHelper()),
        ChangeNotifierProvider(create: (_)=>PostOptions()),
        ChangeNotifierProvider(create: (_)=>FeedHelpers()),
        ChangeNotifierProvider(create: (_)=>UploadPost()),
        ChangeNotifierProvider(create: (_)=>ProfileHelpers()),
        ChangeNotifierProvider(create: (_)=>HomePageHelper()),
        ChangeNotifierProvider(create: (_)=>LandingUtils()),
        ChangeNotifierProvider(create: (_)=>FirebaseOperations()),
        ChangeNotifierProvider(create: (_)=>LandingServices()),
        ChangeNotifierProvider(create: (_)=>Authentication()),
        ChangeNotifierProvider(create: (_)=>LandingHelpers())
        ],
      child: MaterialApp(
      home: SplashScreen(),
      routes: {
        'chatroom':(_)=>ChatRoom()
      },
      theme: ThemeData(
        accentColor:  constantColors.blueColor,
        fontFamily: 'Poppins',
        canvasColor: Colors.transparent,
      ),
      debugShowCheckedModeBanner: false,
    ),);
  }
}

Future backgroundHandler(RemoteMessage message)async{
  print(message.data.toString());
  print(message.notification!.title);
}

