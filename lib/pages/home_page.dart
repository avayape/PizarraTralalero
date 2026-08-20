import 'package:flutter/cupertino.dart';

import '../core/services/storage_service.dart';
import 'tipos_evento_page.dart';
import 'calendar_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Pizarra Tralalero'),
      ),

      child: SafeArea(
        child: Center(
          child: CupertinoButton.filled(
            onPressed: () {
              Navigator.of(
                context,
              ).push(CupertinoPageRoute(builder: (_) => const CalendarPage()));

            },
            child: const Text('Abrir Calendario'),
          ),
        ),
      ),
   
    );
  }
}
