import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';

import '../core/services/storage_service.dart';
import '../repositories/usuario_repository.dart';

const coloresDisponibles = ['blue', 'green', 'red', 'orange', 'purple'];
const avataresDisponibles = ['😀', '😎', '🤓', '🐼', '🦊', '🐻', '🐸', '🐧'];

class MiPerfilPage extends StatefulWidget {
  const MiPerfilPage({super.key});

  @override
  State<MiPerfilPage> createState() => _MiPerfilPageState();
}

class _MiPerfilPageState extends State<MiPerfilPage> {
  final TextEditingController nombreController = TextEditingController();

  bool cargando = true;
  final UsuarioRepository usuarioRepository = UsuarioRepository();

  String colorSeleccionado = 'blue';
  String avatarSeleccionado = '😀';

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Mi Perfil')),

      child: SafeArea(
        child: cargando
            ? const Center(child: CupertinoActivityIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nombre',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    CupertinoTextField(controller: nombreController),

                    const SizedBox(height: 24),

                    const Text(
                      'Color',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    CupertinoSlidingSegmentedControl<String>(
                      groupValue: colorSeleccionado,
                      children: const {
                        'blue': Padding(
                          padding: EdgeInsets.all(8),
                          child: Text('Azul'),
                        ),
                        'green': Padding(
                          padding: EdgeInsets.all(8),
                          child: Text('Verde'),
                        ),
                        'red': Padding(
                          padding: EdgeInsets.all(8),
                          child: Text('Rojo'),
                        ),
                        'orange': Padding(
                          padding: EdgeInsets.all(8),
                          child: Text('Naranja'),
                        ),
                        'purple': Padding(
                          padding: EdgeInsets.all(8),
                          child: Text('Morado'),
                        ),
                      },
                      onValueChanged: (valor) {
                        if (valor == null) return;

                        setState(() {
                          colorSeleccionado = valor;
                        });
                      },
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Avatar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: avataresDisponibles.map((avatar) {
                        final seleccionado = avatar == avatarSeleccionado;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              avatarSeleccionado = avatar;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: seleccionado
                                  ? CupertinoColors.systemBlue
                                  : CupertinoColors.systemGrey6,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              avatar,
                              style: const TextStyle(fontSize: 28),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      child: CupertinoButton.filled(
                        onPressed: guardarPerfil,
                        child: const Text('Guardar'),
                      ),
                    ),
                  ],
                ),
              ),
      ),

      /*
      child: SafeArea(
        child: cargando
            ? const Center(child: CupertinoActivityIndicator())
            : const Center(child: Text('Perfil cargado')),
      ),
  */
    );
  }

  @override
  void initState() {
    super.initState();

    cargarUsuario();
  }

  Future<void> guardarPerfil() async {
    final uuid = await StorageService.obtenerUuid();

    if (uuid == null) return;

    await usuarioRepository.actualizarUsuario(
      usuarioId: uuid,
      nombre: nombreController.text.trim(),
      color: colorSeleccionado,
      avatar: avatarSeleccionado,
    );

    if (!mounted) return;

    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text('Perfil actualizado'),
          actions: [
            CupertinoDialogAction(
              child: const Text('Aceptar'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> cargarUsuario() async {
    try {
      final uuid = await StorageService.obtenerUuid();

      if (uuid == null) {
        if (!mounted) return;

        setState(() {
          cargando = false;
        });

        return;
      }

      final usuario = await usuarioRepository.obtenerUsuario(uuid);

      if (usuario == null) {
        if (!mounted) return;

        setState(() {
          cargando = false;
        });

        return;
      }

      if (!mounted) return;

      setState(() {
        nombreController.text = usuario['nombre'] ?? '';

        colorSeleccionado = usuario['color'] ?? 'blue';

        avatarSeleccionado = usuario['avatar'] ?? '😀';

        cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        cargando = false;
      });
    }
  }
}
