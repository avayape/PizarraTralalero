import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'nuevo_evento_page.dart';
import '../repositories/evento_repository.dart';
import '../core/services/storage_service.dart';
import '../repositories/usuario_repository.dart';
import 'mi_perfil_page.dart';
import 'tipos_evento_page.dart';
import '../core/utils/iconos.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  bool vistaMensual = true;

  Map<String, List<String>> coloresPorDia = {};

  String? usuarioActualId;
  String nombreUsuario = '';
  String colorUsuario = 'blue';
  String avatarUsuario = '😀';

  final EventoRepository eventoRepository = EventoRepository();

  DateTime fechaSeleccionada = DateTime.now();
  late DateTime mesVisible;

  List<dynamic> eventosDia = [];

  bool cargandoEventos = false;

  final UsuarioRepository usuarioRepository = UsuarioRepository();

  final List<String> nombresMeses = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  final SupabaseClient supabase = Supabase.instance.client;

  RealtimeChannel? canalEventos;

  bool refrescoRealtimeEnCurso = false;

  bool puedeIrAtras() {
    final hoy = DateTime.now();

    if (vistaMensual) {
      return mesVisible.year > hoy.year ||
          (mesVisible.year == hoy.year && mesVisible.month > hoy.month);
    }

    final inicioSemanaActual = DateTime(hoy.year, hoy.month, hoy.day);

    final inicioSemanaSeleccionada = DateTime(
      fechaSeleccionada.year,
      fechaSeleccionada.month,
      fechaSeleccionada.day,
    );

    return inicioSemanaSeleccionada.isAfter(inicioSemanaActual);
  }

  Future<void> refrescarPorCambioRealtime() async {
    if (!mounted || refrescoRealtimeEnCurso) {
      return;
    }

    refrescoRealtimeEnCurso = true;

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      await cargarEventosDia();

      if (!mounted) return;

      setState(() {
        coloresPorDia = {};
      });

      await cargarIndicadoresMes();
    } finally {
      refrescoRealtimeEnCurso = false;
    }
  }

  void suscribirCambiosEventos() {
    canalEventos = supabase
        .channel('cambios-eventos-pizarra-tralalero')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'eventos',
          callback: (payload) {
            refrescarPorCambioRealtime();
          },
        )
        .subscribe();
  }

  Widget construirPuntoColor(String color, {required bool esSeleccionado}) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: esSeleccionado
            ? obtenerColorUsuario(color).withOpacity(0.85)
            : obtenerColorUsuario(color),
        shape: BoxShape.circle,
        border: esSeleccionado
            ? Border.all(color: CupertinoColors.white, width: 0.7)
            : null,
      ),
    );
  }

  Widget construirCalendarioMensual() {
    final hoyActual = DateTime.now();

    final hoy = DateTime(hoyActual.year, hoyActual.month, hoyActual.day);

    final primerDiaMes = DateTime(mesVisible.year, mesVisible.month, 1);

    final diasMes = DateTime(mesVisible.year, mesVisible.month + 1, 0).day;

    // Restamos uno para trabajar con columnas de 0 a 6.
    final posicionPrimerDia = primerDiaMes.weekday - 1;

    final totalCasillasNecesarias = posicionPrimerDia + diasMes;

    final numeroSemanas = (totalCasillasNecesarias / 7).ceil();

    final List<TableRow> filas = [];

    for (int semana = 0; semana < numeroSemanas; semana++) {
      final List<Widget> celdasSemana = [];

      for (int columna = 0; columna < 7; columna++) {
        final posicion = semana * 7 + columna;

        final numeroDia = posicion - posicionPrimerDia + 1;

        if (numeroDia < 1 || numeroDia > diasMes) {
          celdasSemana.add(const SizedBox(height: 52));

          continue;
        }

        final fecha = DateTime(mesVisible.year, mesVisible.month, numeroDia);

        final esHoy =
            fecha.year == hoy.year &&
            fecha.month == hoy.month &&
            fecha.day == hoy.day;

        final esSeleccionado =
            fecha.year == fechaSeleccionada.year &&
            fecha.month == fechaSeleccionada.month &&
            fecha.day == fechaSeleccionada.day;

        final esPasado = fecha.isBefore(hoy);

        final coloresDia = obtenerColoresDia(fecha);

        celdasSemana.add(
          GestureDetector(
            behavior: HitTestBehavior.opaque,

            onTap: esPasado
                ? null
                : () async {
                    await seleccionarFecha(fecha);
                  },

            child: Container(
              height: 52,
              margin: const EdgeInsets.all(2),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: esSeleccionado
                    ? CupertinoColors.systemBlue
                    : CupertinoColors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: esHoy
                      ? CupertinoColors.systemRed
                      : CupertinoColors.systemGrey4,
                  width: esHoy ? 2 : 1,
                ),
              ),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    numeroDia.toString(),
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: esHoy || esSeleccionado
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: esSeleccionado
                          ? CupertinoColors.white
                          : esPasado
                          ? CupertinoColors.systemGrey2
                          : CupertinoColors.black,
                    ),
                  ),

                  if (coloresDia.isNotEmpty) ...[
                    const SizedBox(height: 2),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: coloresDia
                          .take(3)
                          .map(
                            (color) => Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 1,
                              ),
                              child: construirPuntoColor(
                                color,
                                esSeleccionado: esSeleccionado,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      }

      filas.add(TableRow(children: celdasSemana));
    }

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(),
        1: FlexColumnWidth(),
        2: FlexColumnWidth(),
        3: FlexColumnWidth(),
        4: FlexColumnWidth(),
        5: FlexColumnWidth(),
        6: FlexColumnWidth(),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: filas,
    );
  }

  List<String> obtenerColoresDia(DateTime fecha) {
    final clave = formatearClaveFecha(fecha);

    return coloresPorDia[clave] ?? [];
  }

  String formatearClaveFecha(DateTime fecha) {
    final year = fecha.year.toString().padLeft(4, '0');

    final month = fecha.month.toString().padLeft(2, '0');

    final day = fecha.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  Future<void> cargarIndicadoresMes() async {
    //debugPrint('Indicadores mes cargados: ${DateTime.now()}');

    try {
      final resultado = await eventoRepository.obtenerEventosMes(
        mesVisible.year,
        mesVisible.month,
      );

      final Map<String, List<String>> nuevoMapa = {};

      for (final item in resultado) {
        final evento = Map<String, dynamic>.from(item as Map);

        final usuarioRaw = evento['usuarios'];

        if (usuarioRaw == null) {
          continue;
        }

        final usuario = Map<String, dynamic>.from(usuarioRaw as Map);

        final colorUsuario = usuario['color']?.toString() ?? 'blue';

        final fechaInicioTexto = evento['fecha_inicio']?.toString();

        final fechaFinTexto = evento['fecha_fin']?.toString();

        if (fechaInicioTexto == null || fechaFinTexto == null) {
          continue;
        }

        final fechaInicio = DateTime.parse(fechaInicioTexto);

        final fechaFin = DateTime.parse(fechaFinTexto);

        var fechaActual = DateTime(
          fechaInicio.year,
          fechaInicio.month,
          fechaInicio.day,
        );

        final fechaFinal = DateTime(
          fechaFin.year,
          fechaFin.month,
          fechaFin.day,
        );

       // debugPrint('Evento indicador: $fechaInicioTexto -> $fechaFinTexto');

        while (!fechaActual.isAfter(fechaFinal)) {
          final clave = formatearClaveFecha(fechaActual);

          nuevoMapa.putIfAbsent(clave, () => <String>[]);

          if (!nuevoMapa[clave]!.contains(colorUsuario)) {
            nuevoMapa[clave]!.add(colorUsuario);
          }

          fechaActual = fechaActual.add(const Duration(days: 1));
        }
      }

      if (!mounted) return;

      setState(() {
        coloresPorDia = nuevoMapa;
      });

    //  debugPrint('Mapa coloresPorDia: $coloresPorDia');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        coloresPorDia = {};
      });

      //debugPrint('Error al cargar indicadores: $e');
    }
  }

  Widget indicadorColor(String color) {
    return Container(
      width: 5,
      height: 5,
      decoration: BoxDecoration(
        color: obtenerColorUsuario(color),
        shape: BoxShape.circle,
      ),
    );
  }

  Future<void> eliminarEvento(int eventoId) async {
    try {
      await eventoRepository.eliminarEvento(eventoId);

      await cargarEventosDia();
      await cargarIndicadoresMes();

      if (!mounted) return;

      showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text('Evento eliminado'),
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
    } catch (e) {
      if (!mounted) return;

      showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text('Error'),
          content: Text(e.toString()),
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
  }

  Widget construirCalendarioSemanal() {
    final inicioSemana = fechaSeleccionada.subtract(
      Duration(days: fechaSeleccionada.weekday - 1),
    );

    return Row(
      children: List.generate(7, (index) {
        final fecha = inicioSemana.add(Duration(days: index));

        final hoy = DateTime.now();

        final esHoy =
            fecha.year == hoy.year &&
            fecha.month == hoy.month &&
            fecha.day == hoy.day;

        final esSeleccionado =
            fecha.year == fechaSeleccionada.year &&
            fecha.month == fechaSeleccionada.month &&
            fecha.day == fechaSeleccionada.day;

        final esPasado = fecha.isBefore(DateTime(hoy.year, hoy.month, hoy.day));

        final coloresDia = obtenerColoresDia(fecha);

        return Expanded(
          child: GestureDetector(
            onTap: () async {
              if (esPasado) return;

              await seleccionarFecha(fecha);
            },

            child: Container(
              margin: const EdgeInsets.all(3),

              decoration: BoxDecoration(
                color: esSeleccionado
                    ? CupertinoColors.systemBlue
                    : CupertinoColors.white,

                borderRadius: BorderRadius.circular(10),

                border: Border.all(
                  color: esHoy
                      ? CupertinoColors.systemRed
                      : CupertinoColors.systemGrey4,
                ),
              ),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${fecha.day}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: esSeleccionado
                          ? CupertinoColors.white
                          : esPasado
                          ? CupertinoColors.systemGrey2
                          : CupertinoColors.black,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    const ['L', 'M', 'X', 'J', 'V', 'S', 'D'][index],
                    style: TextStyle(
                      fontSize: 13,
                      color: esSeleccionado
                          ? CupertinoColors.white
                          : CupertinoColors.systemGrey,
                    ),
                  ),

                  if (coloresDia.isNotEmpty) ...[
                    const SizedBox(height: 4),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: coloresDia
                          .take(3)
                          .map(
                            (color) => Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 1,
                              ),
                              child: construirPuntoColor(
                                color,
                                esSeleccionado: esSeleccionado,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Future<void> irMesAnterior() async {
    setState(() {
      if (vistaMensual) {
        mesVisible = DateTime(mesVisible.year, mesVisible.month - 1);
      } else {
        fechaSeleccionada = fechaSeleccionada.subtract(const Duration(days: 7));

        mesVisible = DateTime(fechaSeleccionada.year, fechaSeleccionada.month);
      }
    });

    await StorageService.guardarFechaSeleccionada(fechaSeleccionada);

    await cargarEventosDia();
    await cargarIndicadoresMes();
  }

  Future<void> irMesSiguiente() async {
    setState(() {
      if (vistaMensual) {
        mesVisible = DateTime(mesVisible.year, mesVisible.month + 1);
      } else {
        fechaSeleccionada = fechaSeleccionada.add(const Duration(days: 7));

        mesVisible = DateTime(fechaSeleccionada.year, fechaSeleccionada.month);
      }
    });

    await StorageService.guardarFechaSeleccionada(fechaSeleccionada);

    await cargarEventosDia();
    await cargarIndicadoresMes();
  }

  Future<void> volverAHoy() async {
    final hoy = DateTime.now();

    await seleccionarFecha(DateTime(hoy.year, hoy.month, hoy.day));

    if (!mounted) return;

    setState(() {
      mesVisible = DateTime(hoy.year, hoy.month);
    });

    await cargarIndicadoresMes();
  }

  Future<void> seleccionarFecha(DateTime fecha) async {
  setState(() {
    fechaSeleccionada = fecha;
  });

  await StorageService.guardarFechaSeleccionada(
    fecha,
  );

  await cargarEventosDia();

  await cargarIndicadoresMes();
}



  Future<void> abrirNuevoEvento() async {
    final guardado = await Navigator.of(context).push<bool>(
      CupertinoPageRoute(
        builder: (_) => NuevoEventoPage(fechaSeleccionada: fechaSeleccionada),
      ),
    );

    if (guardado == true) {
      await cargarEventosDia();
      await cargarIndicadoresMes();

      if (!mounted) return;

      showCupertinoDialog<void>(
        context: context,
        builder: (dialogContext) {
          return CupertinoAlertDialog(
            title: const Text('Evento guardado'),
            content: const Text('El evento se ha registrado correctamente.'),
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
  }

  Future<void> confirmarBorradoEvento(int eventoId, String descripcion) async {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Eliminar evento'),
        content: Text('¿Deseas eliminar "$descripcion"?'),
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

              await eliminarEvento(eventoId);
            },
          ),
        ],
      ),
    );
  }

  Future<void> cargarEventosDia() async {
    setState(() {
      cargandoEventos = true;
    });

    try {
      final resultado = await eventoRepository.obtenerEventosDia(
        fechaSeleccionada,
      );

      if (!mounted) return;

      setState(() {
        eventosDia = resultado;
        cargandoEventos = false;
      });

     // debugPrint('Eventos recuperados: ${eventosDia.length}');

      //debugPrint(resultado.toString());
    } catch (_) {
      if (!mounted) return;

      setState(() {
        cargandoEventos = false;
        eventosDia = [];
      });
    }
  }

  Future<void> cargarDatosUsuario() async {
    usuarioActualId = await StorageService.obtenerUuid();

    if (usuarioActualId == null) {
      return;
    }

    final usuario = await usuarioRepository.obtenerUsuario(usuarioActualId!);

    if (usuario == null) {
      return;
    }

    if (!mounted) return;

    setState(() {
      nombreUsuario = usuario['nombre']?.toString() ?? '';

      colorUsuario = usuario['color']?.toString() ?? 'blue';

      avatarUsuario = usuario['avatar']?.toString() ?? '😀';
    });
  }

  Future<void> inicializarPantalla() async {
    usuarioActualId = await StorageService.obtenerUuid();

    await cargarDatosUsuario();
    final vistaGuardada = await StorageService.obtenerVistaCalendario();
    final fechaGuardada = await StorageService.obtenerFechaSeleccionada();

    if (mounted) {
      setState(() {
        vistaMensual = vistaGuardada ?? true;

        if (fechaGuardada != null) {
          fechaSeleccionada = DateTime(
            fechaGuardada.year,
            fechaGuardada.month,
            fechaGuardada.day,
          );

          mesVisible = DateTime(fechaGuardada.year, fechaGuardada.month);
        }
      });
    }

    await cargarEventosDia();
    await cargarIndicadoresMes();
  }

  @override
  void dispose() {
    final canal = canalEventos;

    if (canal != null) {
      supabase.removeChannel(canal);
    }

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    mesVisible = DateTime(fechaSeleccionada.year, fechaSeleccionada.month);

    suscribirCambiosEventos();

    inicializarPantalla();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,

      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: mostrarMenu,
          child: const Icon(CupertinoIcons.line_horizontal_3),
        ),

        middle: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Pizarra Tralalero',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),

            Text(
              '$avatarUsuario $nombreUsuario',
              style: TextStyle(
                fontSize: 12,
                color: obtenerColorUsuario(colorUsuario),
              ),
            ),
          ],
        ),

        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: volverAHoy,
          child: const Text('Hoy'),
        ),
      ),

      child: SafeArea(
        child: Column(
          children: [
            construirZonaCalendario(),
            Container(height: 1, color: CupertinoColors.systemGrey4),
            Expanded(child: construirZonaEventos()),
          ],
        ),
      ),
    );
  }

  Widget construirZonaCalendario() {
    return Container(
      width: double.infinity,
      color: CupertinoColors.white,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Column(
        children: [
          Row(
            children: [
              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                onPressed: puedeIrAtras() ? irMesAnterior : null,
                child: Icon(
                  CupertinoIcons.chevron_left,
                  color: puedeIrAtras()
                      ? CupertinoColors.activeBlue
                      : CupertinoColors.systemGrey3,
                ),
              ),

              Expanded(
                child: Text(
                  '${nombresMeses[mesVisible.month - 1]} '
                  '${mesVisible.year}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                onPressed: irMesSiguiente,
                child: const Icon(CupertinoIcons.chevron_right),
              ),
            ],
          ),

          const SizedBox(height: 8),

          CupertinoSlidingSegmentedControl<bool>(
            groupValue: vistaMensual,
            children: const {
              true: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('Mes'),
              ),
              false: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('Semana'),
              ),
            },
            onValueChanged: (valor) {
              if (valor == null) return;

              setState(() {
                vistaMensual = valor;
              });

              StorageService.guardarVistaCalendario(valor);
            },
          ),

          const SizedBox(height: 12),

          if (vistaMensual)
            const Row(
              children: [
                Expanded(child: _CabeceraDia(texto: 'L')),
                Expanded(child: _CabeceraDia(texto: 'M')),
                Expanded(child: _CabeceraDia(texto: 'X')),
                Expanded(child: _CabeceraDia(texto: 'J')),
                Expanded(child: _CabeceraDia(texto: 'V')),
                Expanded(child: _CabeceraDia(texto: 'S')),
                Expanded(child: _CabeceraDia(texto: 'D')),
              ],
            ),

          SizedBox(height: vistaMensual ? 12 : 4),

          if (vistaMensual)
            construirCalendarioMensual()
          else
            SizedBox(height: 90, child: construirCalendarioSemanal()),
        ],
      ),
    );
  }

  Widget construirZonaEventos() {
    return Container(
      width: double.infinity,
      color: CupertinoColors.white,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            obtenerFechaSeleccionadaTexto(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          Expanded(child: construirContenidoEventos()),
        ],
      ),
    );
  }

  Widget construirContenidoEventos() {
    if (cargandoEventos) {
      return const Center(child: CupertinoActivityIndicator(radius: 14));
    }

    if (eventosDia.isEmpty) {
      return const Center(
        child: Text(
          'No hay eventos para este día',
          style: TextStyle(color: CupertinoColors.systemGrey, fontSize: 15),
        ),
      );
    }

    final eventosAgrupados = agruparEventosPorUsuario();

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: eventosAgrupados.length,
      separatorBuilder: (_, __) {
        return const SizedBox(height: 10);
      },
      itemBuilder: (context, index) {
        final grupo = eventosAgrupados[index];

        return construirGrupoUsuario(grupo);
      },
    );
  }

  /*




  Widget construirContenidoEventos() {
    if (cargandoEventos) {
      return const Center(child: CupertinoActivityIndicator(radius: 14));
    }

    if (eventosDia.isEmpty) {
      return const Center(
        child: Text(
          'No hay eventos para este día',
          style: TextStyle(color: CupertinoColors.systemGrey, fontSize: 15),
        ),
      );
    }

    final eventosAgrupados = agruparEventosPorUsuario();

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: eventosAgrupados.length,
      separatorBuilder: (_, __) {
        return const SizedBox(height: 10);
      },
      itemBuilder: (context, index) {
        final grupo = eventosAgrupados[index];

        return construirGrupoUsuario(grupo);
      },
    );
  }

  */

  List<Map<String, dynamic>> agruparEventosPorUsuario() {
    final Map<String, Map<String, dynamic>> grupos = {};

    for (final eventoDinamico in eventosDia) {
      final evento = Map<String, dynamic>.from(eventoDinamico as Map);

      final usuario = Map<String, dynamic>.from(evento['usuarios'] as Map);

      final usuarioId = usuario['usuario_id'].toString();

      if (!grupos.containsKey(usuarioId)) {
        grupos[usuarioId] = {
          'usuario_id': usuarioId,
          'nombre': usuario['nombre']?.toString() ?? '',
          'color': usuario['color']?.toString() ?? 'blue',
          'eventos': <Map<String, dynamic>>[],
        };
      }

      final listaEventos =
          grupos[usuarioId]!['eventos'] as List<Map<String, dynamic>>;

      listaEventos.add(evento);
    }

    final resultado = grupos.values.toList();

    resultado.sort((a, b) {
      final nombreA = a['nombre'].toString().toLowerCase();

      final nombreB = b['nombre'].toString().toLowerCase();

      return nombreA.compareTo(nombreB);
    });

    return resultado;
  }

  /*


  List<Map<String, dynamic>> agruparEventosPorUsuario() {
    final Map<String, Map<String, dynamic>> grupos = {};

    for (final eventoDinamico in eventosDia) {
      final evento = Map<String, dynamic>.from(eventoDinamico as Map);

      final usuario = Map<String, dynamic>.from(evento['usuarios'] as Map);

      final usuarioId = usuario['usuario_id'].toString();

      if (!grupos.containsKey(usuarioId)) {
        grupos[usuarioId] = {
          'usuario_id': usuarioId,
          'nombre': usuario['nombre']?.toString() ?? '',
          'color': usuario['color']?.toString() ?? 'blue',
          'eventos': <Map<String, dynamic>>[],
        };
      }

      final listaEventos =
          grupos[usuarioId]!['eventos'] as List<Map<String, dynamic>>;

      listaEventos.add(evento);
    }

    final resultado = grupos.values.toList();

    resultado.sort((a, b) {
      final nombreA = a['nombre'].toString().toLowerCase();

      final nombreB = b['nombre'].toString().toLowerCase();

      return nombreA.compareTo(nombreB);
    });

    return resultado;
  }


*/
  Widget construirGrupoUsuario(Map<String, dynamic> grupo) {
    final usuarioId = grupo['usuario_id'].toString();

    final nombre = grupo['nombre'].toString();

    final color = obtenerColorUsuario(grupo['color'].toString());

    final eventos = grupo['eventos'] as List<Map<String, dynamic>>;

    final esUsuarioActual = usuarioId == usuarioActualId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          nombre,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 3),

        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Wrap(
            spacing: 12,
            runSpacing: 5,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ...eventos.map(construirEventoCompacto),

              if (esUsuarioActual)
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 3,
                    vertical: 0,
                  ),
                  minimumSize: const Size(28, 28),
                  onPressed: () {
                    mostrarSelectorBorrado(eventos);
                  },
                  child: const Icon(
                    CupertinoIcons.delete,
                    size: 19,
                    color: CupertinoColors.systemRed,
                  ),
                ),
            ],
          ),
        ),

        ...construirObservaciones(eventos),
      ],
    );
  }

  Widget construirEventoCompacto(Map<String, dynamic> evento) {
    final tipo = Map<String, dynamic>.from(evento['tipos_evento'] as Map);

    final descripcion = tipo['descripcion']?.toString() ?? '';

    final icono = obtenerIcono(tipo['icono']?.toString() ?? '');

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, size: 18, color: CupertinoColors.black),

        const SizedBox(width: 4),

        Text(
          descripcion,
          style: const TextStyle(fontSize: 15, color: CupertinoColors.black),
        ),
      ],
    );
  }

  List<Widget> construirObservaciones(List<Map<String, dynamic>> eventos) {
    final widgets = <Widget>[];

    for (final evento in eventos) {
      final texto = evento['informacion_adicional']?.toString().trim();

      if (texto == null || texto.isEmpty) {
        continue;
      }

      final tipo = Map<String, dynamic>.from(evento['tipos_evento'] as Map);

      final descripcion = tipo['descripcion']?.toString() ?? 'Evento';

      widgets.add(
        Padding(
          padding: const EdgeInsets.only(left: 10, top: 3),
          child: Text(
            '$descripcion: $texto',
            style: const TextStyle(
              fontSize: 13,
              color: CupertinoColors.systemGrey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  Color obtenerColorUsuario(String color) {
    switch (color.toLowerCase()) {
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
      case 'grey':
        return CupertinoColors.systemGrey;

      default:
        return CupertinoColors.systemBlue;
    }
  }

  void mostrarSelectorBorrado(List<Map<String, dynamic>> eventos) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (popupContext) {
        return CupertinoActionSheet(
          title: const Text('Eliminar evento'),
          message: const Text('Selecciona el evento que deseas eliminar'),
          actions: eventos.map((evento) {
            final tipo = Map<String, dynamic>.from(
              evento['tipos_evento'] as Map,
            );

            return CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.pop(popupContext);

                confirmarBorradoEvento(
                  evento['evento_id'] as int,
                  tipo['descripcion']?.toString() ?? 'Evento',
                );
              },
              child: Text(tipo['descripcion']?.toString() ?? 'Evento'),
            );
          }).toList(),
          cancelButton: CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(popupContext);
            },
            child: const Text('Cancelar'),
          ),
        );
      },
    );
  }

  void mostrarMenu() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          title: const Text('Pizarra Tralalero'),
          message: const Text('Selecciona una opción'),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () async {
                Navigator.pop(context);

                await Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (_) => const MiPerfilPage()),
                );

                await cargarDatosUsuario();
              },
              child: const Text('Mi Perfil'),
            ),

            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);

                abrirNuevoEvento();
              },
              child: const Text('Nuevo evento'),
            ),

            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (_) => const TiposEventoPage()),
                );
              },
              child: const Text('Tipos de evento'),
            ),

            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.pop(context);

                SystemNavigator.pop();
              },
              child: const Text('Salir'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
        );
      },
    );
  }

  double obtenerAlturaCalendario() {
    if (!vistaMensual) {
      return 220;
    }

    final diasMes = DateTime(mesVisible.year, mesVisible.month + 1, 0).day;

    final primerDiaMes = DateTime(mesVisible.year, mesVisible.month, 1);

    final celdasNecesarias = (primerDiaMes.weekday - 1) + diasMes;

    final semanas = (celdasNecesarias / 7).ceil();

    switch (semanas) {
      case 4:
        return 290;

      case 5:
        return 360;

      default:
        return 430;
    }
  }

  String obtenerFechaSeleccionadaTexto() {
    return '${fechaSeleccionada.day.toString().padLeft(2, '0')}/'
        '${fechaSeleccionada.month.toString().padLeft(2, '0')}/'
        '${fechaSeleccionada.year}';
  }
}

class _CabeceraDia extends StatelessWidget {
  final String texto;

  const _CabeceraDia({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: CupertinoColors.systemGrey,
        ),
      ),
    );
  }
}
