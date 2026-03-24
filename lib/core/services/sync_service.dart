import 'package:dio/dio.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'currency_service.dart';

class SyncService {
  final Dio _dio;

  SyncService(this._dio);

  Future<SyncResult> syncServiceTemplates() async {
    try {
      // In a real app we'd fetch and save templates to a database
      // Since ServiceTemplate logic isn't fully set up yet in data layer
      // We will simulate fetching here.
      final response = await _dio.get('https://raw.githubusercontent.com/user/repo/main/templates.json');
      
      // Simulate processing
      final data = response.data;
      
      return const SyncResult.success(updated: 10);
    } catch (e) {
      return SyncResult.failure(error: e.toString());
    }
  }
}

class SyncResult {
  final bool success;
  final int updated;
  final String? error;

  const SyncResult.success({this.updated = 0})
      : success = true, error = null;
  const SyncResult.failure({required this.error})
      : success = false, updated = 0;
}

class BackgroundSyncManager {
  static void callbackDispatcher() {
    Workmanager().executeTask((task, inputData) async {
      switch (task) {
        case 'sync_task':
          await _performSync();
          break;
      }
      return Future.value(true);
    });
  }

  static Future<void> _performSync() async {
    final dio = Dio();
    final syncService = SyncService(dio);
    final storage = const FlutterSecureStorage();
    final currencyService = CurrencyService(dio, storage);

    await syncService.syncServiceTemplates();
    await currencyService.fetchRates();
  }

  static Future<void> registerPeriodicSync() async {
    await Workmanager().registerPeriodicTask(
      'sync_task', 
      'sync_task',
      frequency: const Duration(hours: 24),
    );
  }
}
