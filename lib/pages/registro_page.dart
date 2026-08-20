import 'package:flutter/cupertino.dart';
import 'package:pizarra_tralalero/pages/calendar_page.dart';
import 'package:uuid/uuid.dart';

import '../core/services/storage_service.dart';
import '../models/usuario.dart';
import '../repositories/usuario_repository.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final nombreController = TextEditingController();
  final telefonoController = TextEditingController();
  final usuarioRepository = UsuarioRepository();

  String avatarSeleccionado = '😀';
  String colorSeleccionado = 'blue';

  void mostrarMensaje(String mensaje) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Pizarra Tralalero'),
        content: Text(mensaje),
        actions: [
          CupertinoDialogAction(
            child: const Text('Aceptar'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> guardarUsuario() async {
    try {
      if (nombreController.text.trim().isEmpty) {
        mostrarMensaje('El nombre es obligatorio');
        return;
      }

      final uuid = const Uuid().v4();

      final usuario = Usuario(
        usuarioId: uuid,
        nombre: nombreController.text.trim(),
        telefono: telefonoController.text.trim(),
        icono: '',
        color: colorSeleccionado,
        avatar: avatarSeleccionado,
      );

      await usuarioRepository.insertarUsuario(usuario);

      await StorageService.guardarUuid(uuid);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(builder: (_) => const CalendarPage()),
      );
    } catch (e) {
      mostrarMensaje('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Registro Usuario'),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              const Text('Nombre'),

              const SizedBox(height: 8),

              CupertinoTextField(
                controller: nombreController,
                placeholder: 'Nombre',
              ),

              const SizedBox(height: 20),

              const Text('Teléfono (Opcional)'),

              const SizedBox(height: 8),

              CupertinoTextField(
                controller: telefonoController,
                placeholder: 'Teléfono',
              ),

              const SizedBox(height: 30),

              const Text('Avatar'),

              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  avatarWidget('😀'),
                  avatarWidget('😎'),
                  avatarWidget('🤓'),
                  avatarWidget('🐼'),
                  avatarWidget('🦊'),
                  avatarWidget('🐻'),
                  avatarWidget('🐸'),
                  avatarWidget('🐧'),
                  avatarWidget('🐨'),
                  avatarWidget('🦁'),
                  avatarWidget('🐯'),
                  avatarWidget('🐵'),
                ],
              ),


              const SizedBox(height: 30),

              const Text('Color'),

              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  colorWidget(CupertinoColors.systemBlue, 'blue'),
                  colorWidget(CupertinoColors.systemGreen, 'green'),
                  colorWidget(CupertinoColors.systemRed, 'red'),
                  colorWidget(CupertinoColors.systemOrange, 'orange'),
                  colorWidget(CupertinoColors.systemPurple, 'purple'),
                ],
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                  child: const Text('Guardar'),
                  onPressed: guardarUsuario,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget avatarWidget(String avatar) {
    final seleccionado = avatarSeleccionado == avatar;

    return GestureDetector(
      onTap: () {
        setState(() {
          avatarSeleccionado = avatar;
        });
      },
      child: Container(
        width: 52,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(
            color: seleccionado
                ? CupertinoColors.activeBlue
                : CupertinoColors.systemGrey4,
            width: seleccionado ? 3 : 1,
          ),
          color: seleccionado
              ? CupertinoColors.systemBlue.withOpacity(0.15)
              : CupertinoColors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(avatar, style: const TextStyle(fontSize: 28)),
      ),
    );
  }

  Widget colorWidget(Color color, String valor) {
    final seleccionado = colorSeleccionado == valor;

    return GestureDetector(
      onTap: () {
        setState(() {
          colorSeleccionado = valor;
        });
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: seleccionado
                ? CupertinoColors.black
                : CupertinoColors.systemGrey4,
            width: 3,
          ),
        ),
      ),
    );
  }
}
