import { ArrowLeft } from "lucide-react";
import { PageHeader } from "@/components/ui/page-header";
import { ButtonLink } from "@/components/ui/button";
import { TemplateCreateForm } from "@/features/templates/presentation/template-create-form";

export default function NewTemplatePage() {
  return (
    <>
      <PageHeader
        kicker="Novo formulário"
        title="Criar modelo de checklist"
        description="Comece com a identificação e o primeiro item. Depois você poderá completar as seções no editor antes de publicar."
        actions={
          <ButtonLink href="/modelos" variant="secondary">
            <ArrowLeft />
            Modelos
          </ButtonLink>
        }
      />
      <TemplateCreateForm />
    </>
  );
}
