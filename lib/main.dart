import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/supabase_config.dart';
import 'package:uuid/uuid.dart';
import 'core/services/storage_service.dart';
import 'pages/splash_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      debugShowCheckedModeBanner: false,

      theme: CupertinoThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: CupertinoColors.white,
      ),

      home: SplashPage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String mensaje = 'Comprobando UUID...';

  @override
  void initState() {
    super.initState();
    comprobarUuid();
  }

  Future<void> comprobarUuid() async {
    String? uuid = await StorageService.obtenerUuid();

    if (uuid == null) {
      uuid = const Uuid().v4();

      await StorageService.guardarUuid(uuid);

      setState(() {
        mensaje = 'UUID creado:\n$uuid';
      });
    } else {
      setState(() {
        mensaje = 'UUID encontrado:\n$uuid';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Pizarra Tralalero'),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(mensaje, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
