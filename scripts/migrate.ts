import { loadEnvConfig } from "@next/env";
import { migrate } from "drizzle-orm/postgres-js/migrator";
import postgres from "postgres";
import { drizzle } from "drizzle-orm/postgres-js";

loadEnvConfig(process.cwd());

async function main() {
  const connectionString = process.env.DATABASE_DIRECT_URL ?? process.env.DATABASE_URL;

  if (!connectionString) {
    throw new Error("Configure DATABASE_DIRECT_URL or DATABASE_URL.");
  }

  const client = postgres(connectionString, { max: 1, prepare: false, ssl: "require" });

  try {
    await migrate(drizzle(client), { migrationsFolder: "drizzle" });
    console.log("Migrations applied.");
  } finally {
    await client.end();
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
