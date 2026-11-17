import Image from "next/image";
import Link from "next/link";
import { Camera, ChevronDown, FileText, UserRound } from "lucide-react";
import type { WeeklyInspectionColumn } from "@/features/checklists/presentation/weekly-matrix";

const identityFields = [
  ["responsiblePersonName", "Motorista"],
  ["company", "Empresa"],
  ["licensePlate", "Placa"],
  ["vehicleMakeModel", "Modelo"],
] as const;

function textValue(identity: Record<string, unknown>, key: string) {
  const value = identity[key];
  return typeof value === "string" && value.trim() ? value : "Não informado";
}

function shortDate(localDate: string) {
  return `${localDate.slice(8, 10)}/${localDate.slice(5, 7)}/${localDate.slice(0, 4)}`;
}

export function WeeklyInspectionDetails({ columns }: { columns: WeeklyInspectionColumn[] }) {
  if (!columns.length) return null;

  return (
    <section className="inspection-details-section" aria-labelledby="inspection-details-title">
      <div className="inspection-details-heading">
        <div>
          <h2 className="panel-title" id="inspection-details-title">
            Informações das inspeções
          </h2>
          <div className="panel-subtitle">
            Identificação, anotações e imagens enviadas em cada data
          </div>
        </div>
      </div>
      <div className="inspection-details-list">
        {columns.map((column, index) => (
          <details className="inspection-detail" key={column.id} open={index === 0}>
            <summary>
              <span className="inspection-summary-date">{shortDate(column.localDate)}</span>
              <span className="inspection-summary-meta">
                Ocorrência {column.occurrenceNo} ·{" "}
                {textValue(column.identification, "responsiblePersonName")}
              </span>
              <span className="inspection-summary-counts">
                {column.observations ? (
                  <span>
                    <FileText aria-hidden="true" /> Anotação
                  </span>
                ) : null}
                {column.attachments.length ? (
                  <span>
                    <Camera aria-hidden="true" /> {column.attachments.length}
                  </span>
                ) : null}
              </span>
              <ChevronDown className="inspection-summary-chevron" aria-hidden="true" />
            </summary>
            <div className="inspection-detail-body">
              <dl className="inspection-identity-grid">
                {identityFields.map(([key, label]) => (
                  <div key={key}>
                    <dt>{label}</dt>
                    <dd>{textValue(column.identification, key)}</dd>
                  </div>
                ))}
              </dl>
              <div className="inspection-detail-content">
                <div className="inspection-notes">
                  <div className="inspection-content-label">
                    <FileText aria-hidden="true" /> Anotações gerais
                  </div>
                  <p>{column.observations?.trim() || "Nenhuma anotação enviada."}</p>
                </div>
                <div className="inspection-photos">
                  <div className="inspection-content-label">
                    <Camera aria-hidden="true" /> Imagens
                  </div>
                  {column.attachments.length ? (
                    <div className="inspection-photo-grid">
                      {column.attachments.map((attachment) => (
                        <a
                          className="inspection-photo"
                          href={`/api/v1/inspections/${column.id}/attachments/${attachment.id}`}
                          target="_blank"
                          rel="noreferrer"
                          key={attachment.id}
                        >
                          <Image
                            src={`/api/v1/inspections/${column.id}/attachments/${attachment.id}`}
                            alt={attachment.fileName}
                            width={320}
                            height={200}
                            unoptimized
                          />
                          <span>{attachment.fileName}</span>
                        </a>
                      ))}
                    </div>
                  ) : (
                    <p className="inspection-empty-copy">Nenhuma imagem enviada.</p>
                  )}
                </div>
              </div>
              <Link className="text-link inspection-open-link" href={`/inspecoes/${column.id}`}>
                <UserRound aria-hidden="true" /> Abrir inspeção completa
              </Link>
            </div>
          </details>
        ))}
      </div>
    </section>
  );
}
