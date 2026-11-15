import type { DefaultSession } from "next-auth";
import type { Role } from "@/features/auth/domain/permissions";

declare module "next-auth" {
  interface User {
    organizationId: string;
    roles: Role[];
  }

  interface Session {
    user: DefaultSession["user"] & {
      id: string;
      organizationId: string;
      roles: Role[];
    };
  }
}

declare module "next-auth/jwt" {
  interface JWT {
    userId?: string;
    organizationId?: string;
    roles?: Role[];
  }
}
