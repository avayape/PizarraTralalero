import 'package:flutter/cupertino.dart';
import '../core/utils/iconos.dart';
import '../models/tipo_evento.dart';
import '../repositories/tipo_evento_repository.dart';
import '../core/services/storage_service.dart';

class TipoEventoFormPage extends StatefulWidget {
  final TipoEvento? tipo;

  const TipoEventoFormPage({super.key, this.tipo});

  @override
  State<TipoEventoFormPage> createState() => _TipoEventoFormPageState();
}

class _TipoEventoFormPageState extends State<TipoEventoFormPage> {
  final TextEditingController descripcionController = TextEditingController();

  final TipoEventoRepository repository = TipoEventoRepository();

  String iconoSeleccionado = 'car';
  String colorSeleccionado = 'blue';

  Future<void> guardar() async {
    final descripcion = descripcionController.text.trim();

    if (descripcion.isEmpty) {
      return;
    }

    //final existe = await repository.existeDescripcion(descripcion);
    final existe = await repository.existeDescripcion(
      descripcion,
      excluirTipoEventoId: widget.tipo?.tipoEventoId,
    );
    if (existe) {
      if (!mounted) return;

      showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text('Tipo existente'),
          content: const Text(
            'Ya existe un tipo de evento '
            'con esa descripción.',
          ),
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

    final usuarioId = await StorageService.obtenerUuid();

    if (usuarioId == null) {
      return;
    }

    final nuevoTipo = TipoEvento(
      tipoEventoId: 0,
      descripcion: descripcion,
      icono: iconoSeleccionado,
      color: 'blue',
      orden: 999,
      usuarioId: usuarioId,
      activo: true,
    );

    //await repository.insertarTipoEvento(nuevoTipo);

    if (widget.tipo == null) {
      await repository.insertarTipoEvento(nuevoTipo);
    } else {
      final tipoModificado = TipoEvento(
        tipoEventoId: widget.tipo!.tipoEventoId,
        descripcion: descripcion,
        icono: iconoSeleccionado,
        color: widget.tipo!.color,
        orden: widget.tipo!.orden,
        usuarioId: widget.tipo!.usuarioId,
        activo: true,
      );

      await repository.actualizarTipoEvento(tipoModificado);
    }
    if (!mounted) return;

    Navigator.pop(context, true);
  }

  @override
  void initState() {
    super.initState();

    if (widget.tipo != null) {
      descripcionController.text = widget.tipo!.descripcion;

      iconoSeleccionado = widget.tipo!.icono;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.tipo == null ? 'Nuevo Tipo' : 'Editar Tipo'),
      ),

      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Descripción',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 8),

              CupertinoTextField(
                controller: descripcionController,
                placeholder: 'Descripción del tipo',
              ),

              const SizedBox(height: 24),

              const Text(
                'Icono',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 10),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: iconosDisponibles.map((icono) {
                  final seleccionado = icono == iconoSeleccionado;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        iconoSeleccionado = icono;
                      });
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: seleccionado
                            ? CupertinoColors.activeBlue
                            : CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        obtenerIcono(icono),
                        color: seleccionado
                            ? CupertinoColors.white
                            : CupertinoColors.black,
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                  onPressed: guardar,
                  child: const Text('Guardar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
