import 'package:flutter/cupertino.dart';
import 'package:pizarra_tralalero/pages/calendar_page.dart';

import '../core/services/storage_service.dart';
import 'home_page.dart';
import 'registro_page.dart';
import '../repositories/usuario_repository.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    iniciar();
  }

  final usuarioRepository = UsuarioRepository();

  Future<void> iniciar() async {
    final uuid = await StorageService.obtenerUuid();

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    if (uuid == null) {
      Navigator.of(context).pushReplacement(
        CupertinoPageRoute(builder: (_) => const RegistroPage()),
      );
      return;
    }

    final usuario = await usuarioRepository.obtenerUsuario(uuid);

    if (!mounted) return;

    if (usuario == null) {
      await StorageService.eliminarUuid();

      Navigator.of(context).pushReplacement(
        CupertinoPageRoute(builder: (_) => const RegistroPage()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        CupertinoPageRoute(builder: (_) => const CalendarPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      child: Center(child: CupertinoActivityIndicator(radius: 20)),
    );
  }
}
