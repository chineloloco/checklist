import 'package:checklist_mobile/core/config/app_config.dart';
import 'package:checklist_mobile/core/network/authenticated_api_client.dart';
import 'package:checklist_mobile/features/auth/domain/auth_session.dart';
import 'package:checklist_mobile/features/checklists/data/local/app_database.dart';
import 'package:checklist_mobile/features/checklists/data/remote/registry_api.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'mantém cadastros ativos após atualizar o cache mais de uma vez',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            final data = switch (options.path) {
              '/companies' => [
                {'id': 'company-1', 'name': 'Empresa salva', 'active': true},
              ],
              '/sites' => [
                {
                  'id': 'site-1',
                  'companyId': 'company-1',
                  'name': 'Local salvo',
                  'active': true,
                },
              ],
              '/people' => [
                {
                  'id': 'person-1',
                  'name': 'Motorista salvo',
                  'kind': 'DRIVER',
                  'active': true,
                },
              ],
              _ => <Object?>[],
            };
            handler.resolve(
              Response<Object?>(
                requestOptions: options,
                statusCode: 200,
                data: {'data': data},
              ),
            );
          },
        ),
      );
      final client = AuthenticatedApiClient(
        config: const AppConfig(apiBaseUrl: 'http://online.test'),
        auth: _FakeAuth(),
        dio: dio,
      );
      final api = RegistryApi(client, database);

      await api.companies();
      await api.sites();
      await api.people();

      expect((await api.companies()).single.name, 'Empresa salva');
      expect((await api.sites()).single.name, 'Local salvo');
      expect((await api.people()).single.name, 'Motorista salvo');
    },
  );

  test(
    'usa empresas, locais e motoristas do cache quando está offline',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      await database
          .into(database.localCompanies)
          .insert(
            LocalCompaniesCompanion.insert(
              id: 'company-1',
              name: 'Empresa local',
            ),
          );
      await database
          .into(database.localSites)
          .insert(
            LocalSitesCompanion.insert(
              id: 'site-1',
              companyId: 'company-1',
              name: 'Pátio local',
            ),
          );
      await database
          .into(database.localPeople)
          .insert(
            LocalPeopleCompanion.insert(
              id: 'person-1',
              name: 'Motorista local',
              kind: 'DRIVER',
            ),
          );
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) => handler.reject(
            DioException(
              requestOptions: options,
              type: DioExceptionType.connectionError,
            ),
          ),
        ),
      );
      final client = AuthenticatedApiClient(
        config: const AppConfig(apiBaseUrl: 'http://offline.test'),
        auth: _FakeAuth(),
        dio: dio,
      );
      final api = RegistryApi(client, database);

      expect((await api.companies()).single.name, 'Empresa local');
      expect(api.lastReadUsedCache, isTrue);
      expect((await api.sites()).single.name, 'Pátio local');
      expect((await api.people()).single.name, 'Motorista local');
    },
  );
}

final class _FakeAuth implements AuthSessionRepository {
  @override
  Future<String> validAccessToken({bool forceRefresh = false}) async => 'token';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
