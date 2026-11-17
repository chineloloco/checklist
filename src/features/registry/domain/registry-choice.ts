export type RegistryCompanyChoice = {
  id: string;
  name: string;
};

export type RegistrySiteChoice = RegistryCompanyChoice & {
  companyId: string | null;
};
