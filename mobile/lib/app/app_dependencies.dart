import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/config/app_config.dart';
import '../core/network/authenticated_api_client.dart';
import '../features/auth/data/password_auth_repository.dart';
import '../features/auth/domain/auth_session.dart';
import '../features/checklists/application/checklist_service.dart';
import '../features/checklists/data/drift_checklist_repository.dart';
import '../features/checklists/data/local/app_database.dart';
import '../features/checklists/data/local/database_factory.dart';
import '../features/checklists/data/remote/checklist_api.dart';
import '../features/checklists/data/remote/registry_api.dart';
import '../features/checklists/domain/checklist_repository.dart';
import '../features/sync/application/sync_coordinator.dart';
import '../features/sync/data/device_identity.dart';
import '../features/sync/data/sync_api.dart';

final class AppDependencies {
  AppDependencies._({
    required this.config,
    required this.secureStorage,
    required this.database,
    required this.auth,
    required this.checklistRepository,
    required this.checklistService,
    required this.checklistApi,
    required this.registryApi,
    required this.syncCoordinator,
  });

  final AppConfig config;
  final FlutterSecureStorage secureStorage;
  final AppDatabase database;
  final AuthSessionRepository auth;
  final ChecklistRepository checklistRepository;
  final ChecklistService checklistService;
  final ChecklistApi checklistApi;
  final RegistryApi registryApi;
  final SyncCoordinator syncCoordinator;

  static Future<AppDependencies> create() async {
    final config = AppConfig.fromEnvironment();
    const secureStorage = FlutterSecureStorage();
    final database = await DatabaseFactory.open(secureStorage);
    final deviceIdentity = DeviceIdentity(secureStorage);
    final auth = PasswordAuthRepository(
      config: config,
      secureStorage: secureStorage,
      deviceId: () => deviceIdentity.id,
    );
    final client = AuthenticatedApiClient(config: config, auth: auth);
    final checklistRepository = DriftChecklistRepository(database);
    final checklistService = ChecklistService(checklistRepository);
    final checklistApi = ChecklistApi(client);
    final syncCoordinator = SyncCoordinator(
      database: database,
      syncApi: SyncApi(client),
      checklistApi: checklistApi,
      checklistRepository: checklistRepository,
      deviceIdentity: deviceIdentity,
    );
    final registryApi = RegistryApi(
      client,
      database,
      onQueued: () => unawaited(syncCoordinator.syncNow()),
    );
    await syncCoordinator.initialize();
    return AppDependencies._(
      config: config,
      secureStorage: secureStorage,
      database: database,
      auth: auth,
      checklistRepository: checklistRepository,
      checklistService: checklistService,
      checklistApi: checklistApi,
      registryApi: registryApi,
      syncCoordinator: syncCoordinator,
    );
  }

  Future<void> dispose() async {
    await syncCoordinator.dispose();
    await database.close();
  }
}
