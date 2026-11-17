import "server-only";

import { drizzle } from "drizzle-orm/postgres-js";
import postgres from "postgres";
import * as schema from "./schema";

const globalForDb = globalThis as unknown as {
  checklistSql?: ReturnType<typeof postgres>;
  checklistDb?: ReturnType<typeof createDatabase>;
};

function createClient() {
  const connectionString = process.env.DATABASE_URL;
  if (!connectionString) {
    throw new Error("DATABASE_URL is not configured.");
  }

  return postgres(connectionString, {
    max: process.env.NODE_ENV === "production" ? 10 : 3,
    idle_timeout: 20,
    connect_timeout: 10,
    prepare: false,
    ssl: "require",
  });
}

function createDatabase() {
  const sqlClient = globalForDb.checklistSql ?? createClient();

  if (process.env.NODE_ENV !== "production") {
    globalForDb.checklistSql = sqlClient;
  }

  return drizzle(sqlClient, { schema });
}

export function getDb() {
  const database = globalForDb.checklistDb ?? createDatabase();
  if (process.env.NODE_ENV !== "production") {
    globalForDb.checklistDb = database;
  }
  return database;
}

export type Database = ReturnType<typeof createDatabase>;
