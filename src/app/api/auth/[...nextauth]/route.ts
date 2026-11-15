import NextAuth from "next-auth";
import { authOptions } from "@/features/auth/infrastructure/auth-options";

const handler = NextAuth(authOptions);

export { handler as GET, handler as POST };
