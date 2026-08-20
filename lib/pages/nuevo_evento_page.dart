import 'package:flutter/cupertino.dart';

import '../core/services/storage_service.dart';
import '../models/evento.dart';
import '../models/tipo_evento.dart';
import '../repositories/evento_repository.dart';
import '../repositories/tipo_evento_repository.dart';

class NuevoEventoPage extends StatefulWidget {
  final DateTime fechaSeleccionada;

  const NuevoEventoPage({super.key, required this.fechaSeleccionada});

  @override
  State<NuevoEventoPage> createState() => _NuevoEventoPageState();
}

class _NuevoEventoPageState extends State<NuevoEventoPage> {
  final TipoEventoRepository tipoEventoRepository = TipoEventoRepository();

  final EventoRepository eventoRepository = EventoRepository();

  final TextEditingController informacionController = TextEditingController();

  List<TipoEvento> tiposEvento = [];

  TipoEvento? tipoSeleccionado;

  late DateTime fechaInicio;
  late DateTime fechaFin;

  bool cargandoTipos = true;
  bool guardando = false;
  String? errorCarga;

  @override
  void initState() {
    super.initState();

    fechaInicio = DateTime(
      widget.fechaSeleccionada.year,
      widget.fechaSeleccionada.month,
      widget.fechaSeleccionada.day,
    );

    fechaFin = fechaInicio;

    cargarTiposEvento();
  }

  @override
  void dispose() {
    informacionController.dispose();
    super.dispose();
  }

  Future<void> cargarTiposEvento() async {
    try {
      final resultado = await tipoEventoRepository.obtenerTiposActivos();

      if (!mounted) return;

      setState(() {
        tiposEvento = resultado;

        if (resultado.isNotEmpty) {
          tipoSeleccionado = resultado.first;
        }

        cargandoTipos = false;
        errorCarga = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        cargandoTipos = false;
        errorCarga = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,

      navigationBar: CupertinoNavigationBar(
        middle: const Text('Nuevo Evento'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: guardando
              ? null
              : () {
                  Navigator.pop(context, false);
                },
          child: const Icon(CupertinoIcons.back),
        ),
      ),

      child: SafeArea(
        child: cargandoTipos
            ? const Center(child: CupertinoActivityIndicator(radius: 16))
            : construirFormulario(),
      ),
    );
  }

  Widget construirFormulario() {
    if (errorCarga != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                CupertinoIcons.exclamationmark_triangle,
                size: 42,
                color: CupertinoColors.systemRed,
              ),
              const SizedBox(height: 14),
              const Text(
                'No se pudieron cargar los tipos de evento',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                errorCarga!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: CupertinoColors.systemGrey,
                ),
              ),
              const SizedBox(height: 20),
              CupertinoButton.filled(
                onPressed: () {
                  setState(() {
                    cargandoTipos = true;
                    errorCarga = null;
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
      return const Center(child: Text('No existen tipos de evento activos'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tipo de evento',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 10),

          construirSelectorTipoEvento(),

          const SizedBox(height: 26),

          const Row(
            children: [
              Expanded(
                child: Text(
                  'Fecha inicio',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Fecha fin',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: construirBotonFecha(
                  fecha: fechaInicio,
                  onPressed: () {
                    seleccionarFecha(esFechaInicio: true);
                  },
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: construirBotonFecha(
                  fecha: fechaFin,
                  onPressed: () {
                    seleccionarFecha(esFechaInicio: false);
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 26),

          const Text(
            'Información adicional',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 10),

          CupertinoTextField(
            controller: informacionController,
            placeholder: 'Añade información opcional',
            minLines: 4,
            maxLines: 6,
            textCapitalization: TextCapitalization.sentences,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CupertinoColors.systemGrey4),
            ),
          ),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: CupertinoButton.filled(
              onPressed: guardando ? null : guardarEvento,
              child: guardando
                  ? const CupertinoActivityIndicator(
                      color: CupertinoColors.white,
                    )
                  : const Text('Guardar'),
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: CupertinoButton(
              onPressed: guardando
                  ? null
                  : () {
                      Navigator.pop(context, false);
                    },
              child: const Text('Cancelar'),
            ),
          ),
        ],
      ),
    );
  }

  Widget construirSelectorTipoEvento() {
    final tipo = tipoSeleccionado;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: mostrarSelectorTipoEvento,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: CupertinoColors.systemGrey4),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                tipo?.descripcion ?? 'Selecciona un tipo',
                style: const TextStyle(
                  color: CupertinoColors.black,
                  fontSize: 16,
                ),
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_down,
              size: 18,
              color: CupertinoColors.systemGrey,
            ),
          ],
        ),
      ),
    );
  }

  Widget construirBotonFecha({
    required DateTime fecha,
    required VoidCallback onPressed,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: CupertinoColors.systemGrey4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(CupertinoIcons.calendar, size: 18),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                formatearFecha(fecha),
                style: const TextStyle(
                  color: CupertinoColors.black,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void mostrarSelectorTipoEvento() {
    int indiceSeleccionado = tiposEvento.indexWhere(
      (tipo) => tipo.tipoEventoId == tipoSeleccionado?.tipoEventoId,
    );

    if (indiceSeleccionado < 0) {
      indiceSeleccionado = 0;
    }

    int indiceTemporal = indiceSeleccionado;

    showCupertinoModalPopup<void>(
      context: context,
      builder: (popupContext) {
        return Container(
          height: 300,
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: Column(
            children: [
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        Navigator.pop(popupContext);
                      },
                      child: const Text('Cancelar'),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        setState(() {
                          tipoSeleccionado = tiposEvento[indiceTemporal];
                        });

                        Navigator.pop(popupContext);
                      },
                      child: const Text('Aceptar'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem: indiceSeleccionado,
                  ),
                  itemExtent: 40,
                  onSelectedItemChanged: (indice) {
                    indiceTemporal = indice;
                  },
                  children: tiposEvento
                      .map((tipo) => Center(child: Text(tipo.descripcion)))
                      .toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void seleccionarFecha({required bool esFechaInicio}) {
    final fechaInicial = esFechaInicio ? fechaInicio : fechaFin;

    DateTime fechaTemporal = fechaInicial;

    final hoyActual = DateTime.now();

    final fechaMinima = DateTime(
      hoyActual.year,
      hoyActual.month,
      hoyActual.day,
    );

    final fechaMaxima = DateTime(
      fechaMinima.year,
      fechaMinima.month + 7,
      fechaMinima.day,
    );

    showCupertinoModalPopup<void>(
      context: context,
      builder: (popupContext) {
        return Container(
          height: 340,
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: Column(
            children: [
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        Navigator.pop(popupContext);
                      },
                      child: const Text('Cancelar'),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        actualizarFecha(
                          esFechaInicio: esFechaInicio,
                          nuevaFecha: fechaTemporal,
                        );

                        Navigator.pop(popupContext);
                      },
                      child: const Text('Aceptar'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: fechaInicial,
                  //minimumDate: fechaMinima,
                  minimumDate: esFechaInicio ? fechaMinima : fechaInicio,
                  maximumDate: fechaMaxima,
                  onDateTimeChanged: (fecha) {
                    fechaTemporal = fecha;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void actualizarFecha({
    required bool esFechaInicio,
    required DateTime nuevaFecha,
  }) {
    final fechaNormalizada = DateTime(
      nuevaFecha.year,
      nuevaFecha.month,
      nuevaFecha.day,
    );

    setState(() {
      if (esFechaInicio) {
        fechaInicio = fechaNormalizada;

        if (fechaFin.isBefore(fechaInicio)) {
          fechaFin = fechaInicio;
        }
      } else {
        fechaFin = fechaNormalizada;

        if (fechaFin.isBefore(fechaInicio)) {
          fechaFin = fechaInicio;
        }
      }
    });
  }

  Future<void> guardarEvento() async {
    if (tipoSeleccionado == null) {
      mostrarMensaje('Debes seleccionar un tipo de evento.');
      return;
    }

    if (fechaFin.isBefore(fechaInicio)) {
      mostrarMensaje(
        'La fecha fin no puede ser anterior '
        'a la fecha inicio.',
      );
      return;
    }

    final usuarioUuid = await StorageService.obtenerUuid();

    if (usuarioUuid == null) {
      if (!mounted) return;

      mostrarMensaje('No se ha podido identificar al usuario.');
      return;
    }

    final existeDuplicado = await eventoRepository.existeEventoDuplicado(
      usuarioId: usuarioUuid!,
      tipoEventoId: tipoSeleccionado!.tipoEventoId,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
    );

    if (existeDuplicado) {
      mostrarMensaje(
        'Ya tienes registrado este evento '
        'para esas fechas.',
      );

      setState(() {
        guardando = false;
      });

      return;
    }

    setState(() {
      guardando = true;
    });

    try {
      final evento = Evento(
        usuarioId: usuarioUuid,
        tipoEventoId: tipoSeleccionado!.tipoEventoId,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
        informacionAdicional: informacionController.text,
      );

      await eventoRepository.insertarEvento(evento);

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        guardando = false;
      });

      mostrarMensaje('No se pudo guardar el evento.\n\n$e');
    }
  }

  void mostrarMensaje(String mensaje) {
    showCupertinoDialog<void>(
      context: context,
      builder: (dialogContext) {
        return CupertinoAlertDialog(
          title: const Text('Pizarra Tralalero'),
          content: Text(mensaje),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  String formatearFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');

    return '$dia/$mes/${fecha.year}';
  }
}
