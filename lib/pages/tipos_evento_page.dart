import 'package:flutter/cupertino.dart';
import '../models/tipo_evento.dart';
import '../repositories/tipo_evento_repository.dart';
import '../core/services/storage_service.dart';
import 'tipo_evento_form_page.dart';
import '../core/utils/iconos.dart';

class TiposEventoPage extends StatefulWidget {
  const TiposEventoPage({super.key});

  @override
  State<TiposEventoPage> createState() => _TiposEventoPageState();
}

class _TiposEventoPageState extends State<TiposEventoPage> {
  final TipoEventoRepository tipoEventoRepository = TipoEventoRepository();

  String? usuarioActualId;

  List<TipoEvento> tiposEvento = [];
  bool cargando = true;
  String? error;

  final TipoEventoRepository repository = TipoEventoRepository();

  List<TipoEvento> tipos = [];

  @override
  void initState() {
    super.initState();
    cargarTiposEvento();
  }

  Future<void> confirmarEliminarTipo(TipoEvento tipo) async {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Eliminar tipo'),
        content: Text('¿Deseas eliminar "${tipo.descripcion}"?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancelar'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Eliminar'),
            onPressed: () async {
              Navigator.pop(context);

              await eliminarTipoEvento(tipo);
            },
          ),
        ],
      ),
    );
  }

  Future<void> cargarTipos() async {
    final usuarioId = await StorageService.obtenerUuid();

    if (usuarioId == null) {
      return;
    }

    final resultado = await repository.obtenerTiposUsuario(usuarioId);

    if (!mounted) return;

    setState(() {
      tipos = resultado;
      cargando = false;
    });
  }

  Future<void> eliminarTipoEvento(TipoEvento tipo) async {
    final tieneEventos = await repository.tieneEventosAsociados(
      tipo.tipoEventoId,
    );

    if (tieneEventos) {
      if (!mounted) return;

      showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text('No se puede eliminar'),
          content: const Text('Este tipo de evento tiene eventos asociados.'),
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

      return;
    }

    await repository.desactivarTipoEvento(tipo.tipoEventoId);

    setState(() {
      cargando = true;
    });
    await cargarTiposEvento();
  }

  Future<void> cargarTiposEvento() async {
    try {
      usuarioActualId = await StorageService.obtenerUuid();

      final resultado = await tipoEventoRepository.obtenerTiposActivos();

      if (!mounted) return;

      setState(() {
        tiposEvento = resultado;
        cargando = false;
        error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        cargando = false;
        error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Tipos de evento'),
      ),
      child: SafeArea(child: construirContenido()),
    );
  }

  Widget construirContenido() {
    if (cargando) {
      return const Center(child: CupertinoActivityIndicator(radius: 16));
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                CupertinoIcons.exclamationmark_triangle,
                color: CupertinoColors.systemRed,
                size: 40,
              ),
              const SizedBox(height: 12),
              const Text(
                'No se pudieron cargar los tipos de evento',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: CupertinoColors.systemGrey,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              CupertinoButton.filled(
                onPressed: () {
                  setState(() {
                    cargando = true;
                    error = null;
                  });

                  cargarTiposEvento();
                },
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (tiposEvento.isEmpty) {
      return const Center(child: Text('No hay tipos de evento activos'));
    }

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: tiposEvento.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final tipo = tiposEvento[index];

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: obtenerColor(tipo.color).withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        obtenerIcono(tipo.icono),
                        color: obtenerColor(tipo.color),
                        size: 22,
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Text(
                        tipo.descripcion,
                        style: const TextStyle(fontSize: 17),
                      ),
                    ),

                    if (tipo.usuarioId == usuarioActualId)
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        minSize: 30,
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (_) => TipoEventoFormPage(tipo: tipo),
                            ),
                          );

                          await cargarTiposEvento();
                        },
                        child: const Icon(CupertinoIcons.pencil, size: 20),
                      ),

                    if (tipo.usuarioId == usuarioActualId)
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        minSize: 30,
                        onPressed: () {
                          confirmarEliminarTipo(tipo);
                        },
                        child: const Icon(
                          CupertinoIcons.delete,
                          size: 20,
                          color: CupertinoColors.systemRed,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: CupertinoButton.filled(
              onPressed: () async {
                await Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (_) => const TipoEventoFormPage(),
                  ),
                );

                await cargarTiposEvento();
              },
              child: const Text('Nuevo Tipo'),
            ),
          ),
        ),
      ],
    );
  }

  Color obtenerColor(String color) {
    switch (color) {
      case 'blue':
        return CupertinoColors.systemBlue;
      case 'green':
        return CupertinoColors.systemGreen;
      case 'red':
        return CupertinoColors.systemRed;
      case 'orange':
        return CupertinoColors.systemOrange;
      case 'purple':
        return CupertinoColors.systemPurple;
      case 'gray':
        return CupertinoColors.systemGrey;
      default:
        return CupertinoColors.systemBlue;
    }
  }
}
