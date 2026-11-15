import type { AuthContext } from "@/features/auth/application/auth-context";
import { PostgresRegistryRepository } from "@/features/registry/infrastructure/postgres-registry-repository";

export class RegistryService {
  constructor(private readonly repository = new PostgresRegistryRepository()) {}
  listCompanies(context: AuthContext) { return this.repository.listCompanies(context); }
  createCompany(context: AuthContext, input: { name: string; document?: string | null }) { return this.repository.createCompany(context, input); }
  listSites(context: AuthContext) { return this.repository.listSites(context); }
  createSite(context: AuthContext, input: { companyId: string; name: string }) { return this.repository.createSite(context, input); }
  listPeople(context: AuthContext) { return this.repository.listPeople(context); }
  createPerson(context: AuthContext, input: Parameters<PostgresRegistryRepository["createPerson"]>[1]) { return this.repository.createPerson(context, input); }
  listAssets(context: AuthContext) { return this.repository.listAssets(context); }
  createAsset(context: AuthContext, input: Parameters<PostgresRegistryRepository["createAsset"]>[1]) { return this.repository.createAsset(context, input); }
  assignTemplate(context: AuthContext, assetId: string, input: { templateId: string; operationConfigId: string }) { return this.repository.assignTemplate(context, assetId, input); }
}
