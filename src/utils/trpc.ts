import { QueryClient } from "@tanstack/solid-query";
import type { IAppRouter } from "../server/trpc/router/_app";
import { createTRPCSolid } from "solid-trpc";
import { httpBatchLink } from "@trpc/client";

export const trpc = createTRPCSolid<IAppRouter>({
  links: [
    httpBatchLink({
      url: 'http://localhost:3000/trpc',  // Ensure this points to your backend
    }),
  ],
});

export const queryClient = new QueryClient();
