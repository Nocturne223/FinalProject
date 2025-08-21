import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/theme/app_colors.dart';
import 'features/dashboard/pages/dashboard_main_page.dart';
import 'core/infrastructure/metrics/metrics_service.dart';
import 'features/evaluation/evaluation_page.dart';
import 'core/infrastructure/firebase_emulator.dart';
import 'features/auth/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await configureFirebaseEmulators();
  // Initialize Firebase Messaging
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  // Request notification permissions (for web and mobile)
  await messaging.requestPermission();
  // Optionally get the device token for testing
  String? token = await messaging.getToken();
  print('FCM Token: $token');

  // Handle foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Received a foreground message: ${message.notification?.title}');
    // TODO: Show in-app notification/banner here
  });

  // Handle background/terminated messages (optional)
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // Capture frame timings for UI performance metrics.
  SchedulerBinding.instance.addTimingsCallback((timings) {
    for (final t in timings) {
      final int buildMs = t.totalSpan.inMilliseconds;
      final int rasterMs = t.rasterDuration.inMilliseconds;
      MetricsService.instance.recordSuccess('ui.frameBuild', buildMs);
      MetricsService.instance.recordSuccess('ui.frameRaster', rasterMs);
    }
  });
  runApp(const MyApp());
}

// Top-level function for background message handling
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Intellistock',
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        textTheme: GoogleFonts.assistantTextTheme(
          Theme.of(context).textTheme.apply(bodyColor: AppColors.lightMainText),
        ),
        scaffoldBackgroundColor: AppColors.lightBackground,
        cardColor: AppColors.lightCardBackground,
        dividerColor: AppColors.lightDivider,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.lightAppBarBackground,
          foregroundColor: AppColors.lightMainText,
        ),
        drawerTheme: const DrawerThemeData(
          backgroundColor: AppColors.lightDrawerBackground,
        ),
        colorScheme: ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.accent,
          error: AppColors.error,
          background: AppColors.lightBackground,
          surface: AppColors.lightSurface,
        ),
      ),
      home: const AuthWrapper(child: DashboardMainPage()),
      routes: <String, WidgetBuilder>{
        '/evaluation': (_) => const EvaluationPage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
