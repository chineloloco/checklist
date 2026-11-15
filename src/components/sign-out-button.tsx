"use client";
import { signOut } from "next-auth/react";
export function SignOutButton() { return <button className="signout" type="button" onClick={() => signOut({ callbackUrl: "/login" })}>Sair da conta</button>; }
