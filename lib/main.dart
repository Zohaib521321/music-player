import 'package:flutter/material.dart';
import 'package:music_player/providers/AudioPlaying.dart';
import 'package:music_player/providers/ThemeProvider.dart';
import 'package:music_player/providers/permissionprovider.dart';
import 'package:music_player/view/Tabs/main.dart';
import 'package:music_player/view/music_player.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_10y.dart';
import 'package:shared_preferences/shared_preferences.dart';
FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();
void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize shared preferences
await SharedPreferences.getInstance();
  initializeTimeZones();
  AndroidInitializationSettings androidSettings = AndroidInitializationSettings("@mipmap/ic_launcher");

  DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestCriticalPermission: true,
      requestSoundPermission: true
  );

  InitializationSettings initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings
  );

  bool? initialized = await notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        print(response.payload.toString());
      }
  );

  print("Notifications: $initialized");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers:[
        ChangeNotifierProvider(create: (_) => PermissionProvider()),
        ChangeNotifierProvider(create: (_) => AudioPlaybackProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),

      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',

        theme: ThemeData(

          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home:  MusicScreen(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return const Scaffold();
  }
}
