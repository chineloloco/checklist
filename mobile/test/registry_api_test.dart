import 'package:checklist_mobile/core/config/app_config.dart';
import 'package:checklist_mobile/core/network/authenticated_api_client.dart';
import 'package:checklist_mobile/features/auth/domain/auth_session.dart';
import 'package:checklist_mobile/features/checklists/data/local/app_database.dart';
import 'package:checklist_mobile/features/checklists/data/drift_checklist_repository.dart';
import 'package:checklist_mobile/features/checklists/data/remote/registry_api.dart';
import 'package:checklist_mobile/features/checklists/domain/checklist_models.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_fixture.dart';

void main() {
  test(
    'picker reads return local data without waiting for the network',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final repository = DriftChecklistRepository(database);
      await seedVlBootstrap(repository);
      var requests = 0;
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (_, _) {
            // A request would remain pending until the HTTP timeout.
            requests++;
          },
        ),
      );
      final api = RegistryApi(
        AuthenticatedApiClient(
          config: const AppConfig(apiBaseUrl: 'http://slow.test'),
          auth: _FakeAuth(),
          dio: dio,
        ),
        database,
      );
      final companies = await api
          .companies(localOnly: true)
          .timeout(const Duration(seconds: 1));
      final sites = await api
          .sites(localOnly: true)
          .timeout(const Duration(seconds: 1));
      final people = await api
          .people(localOnly: true)
          .timeout(const Duration(seconds: 1));
      expect(companies, isNotEmpty);
      expect(sites, isNotEmpty);
      expect(people, isNotEmpty);
      expect(requests, 0);
    },
  );

  test(
    'creates every registry offline and preserves pending records on refresh',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final repository = DriftChecklistRepository(database);
      await seedVlBootstrap(repository);
      var online = false;
      var posts = 0;
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.method == 'POST') posts++;
            if (!online) {
              handler.reject(
                DioException(
                  requestOptions: options,
                  type: DioExceptionType.connectionError,
                ),
              );
            } else {
              handler.resolve(
                Response<Object?>(
                  requestOptions: options,
                  statusCode: 200,
                  data: {'data': <Object?>[]},
                ),
              );
            }
          },
        ),
      );
      final api = RegistryApi(
        AuthenticatedApiClient(
          config: const AppConfig(apiBaseUrl: 'http://offline.test'),
          auth: _FakeAuth(),
          dio: dio,
        ),
        database,
      );
      final company = await api.createCompany(
        name: 'Nova empresa',
        document: '123',
      );
      final site = await api.createSite(name: 'Novo local');
      final person = await api.createPerson(
        name: 'Novo motorista',
        kind: 'DRIVER',
      );
      final operator = await api.createPerson(
        name: 'Novo operador',
        kind: 'OPERATOR',
      );
      final template = (await repository.listAllTemplateChoices()).single;
      final asset = await api.createAsset(
        companyId: company.id,
        siteId: site.id,
        kind: 'VEHICLE',
        code: 'OFF-01',
        description: 'Modelo offline',
        ownershipType: 'OWN',
        template: template,
      );
      final equipment = await api.createAsset(
        companyId: company.id,
        siteId: site.id,
        kind: 'EQUIPMENT',
        code: 'OFF-02',
        description: 'Equipamento offline',
        ownershipType: 'THIRD_PARTY',
        template: TemplateChoice(
          templateId: template.templateId,
          templateVersionId: template.templateVersionId,
          operationConfigId: template.operationConfigId,
          versionNumber: 1,
          timezone: template.timezone,
          maxOccurrencesPerDate: 1,
          code: 'EQ',
          name: 'Equipment',
          assetKind: 'EQUIPMENT',
        ),
      );
      expect(posts, 0);
      expect(
        (await api.companies()).any((row) => row.id == company.id),
        isTrue,
      );
      expect(
        (await api.sites()).any(
          (row) => row.id == site.id && row.companyId.isEmpty,
        ),
        isTrue,
      );
      expect(
        (await api.people()).map((row) => row.id),
        containsAll([person.id, operator.id]),
      );

      // A server snapshot taken before upload must not hide local registrations.
      online = true;
      expect((await api.companies()).single.id, company.id);
      expect((await api.sites()).single.id, site.id);
      expect(await api.people(), hasLength(2));
      await seedVlBootstrap(repository);
      final reloaded = DriftChecklistRepository(database);
      expect(
        (await reloaded.listAssets()).map((row) => row.id),
        containsAll([asset.id, equipment.id]),
      );
      final weekId = await reloaded.openWeeklyChecklist(
        assetId: asset.id,
        template: template,
        localDate: DateTime(2026, 11, 10),
      );
      final inspectionId = await reloaded.openInspection(
        weeklyChecklistId: weekId,
        localDate: DateTime(2026, 11, 10),
        identification: IdentificationSnapshot(
          company: company.name,
          site: site.name,
          assetCode: asset.code,
          ownershipType: 'OWN',
          responsiblePersonName: person.name,
          responsiblePersonId: person.id,
        ),
      );
      expect(
        (await reloaded.getInspection(
          inspectionId,
        )).identification.responsiblePersonId,
        person.id,
      );
      final pending = await database
          .select(database.syncOutboxOperations)
          .get();
      expect(
        pending.where(
          (row) =>
              {'COMPANY', 'SITE', 'PERSON', 'ASSET'}.contains(row.entityType),
        ),
        hasLength(6),
      );
      expect(posts, 0);
    },
  );

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
