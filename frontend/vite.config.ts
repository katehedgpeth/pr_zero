/// <reference types="vitest" />

import { ConfigEnv, defineConfig, loadEnv, UserConfig } from "vite";
import react from "@vitejs/plugin-react";

// https://vitejs.dev/config/
export default defineConfig(({ mode }: ConfigEnv): UserConfig => {
  const __ENV__ = loadEnv(mode, process.cwd());
  if (!__ENV__.VITE_TEST_TOKEN)
    throw new Error("VITE_TEST_TOKEN env var is missing!");

  return {
    base: process.env.NODE_ENV === "production" ? "/react_app/" : "/",
    define: {
      __ENV__,
    },
    plugins: [react()],
    test: {
      environment: "jsdom",
      setupFiles: ["./vitest.setup.ts"],
      globals: true,
    },
    server: {
      // host:
      //   process.env.NODE_ENV === "production"
      //     ? undefined
      //     : "http://localhost:4000",
      proxy: {
        "/api": {
          target: "http://localhost:4000",
          secure: false,
          ws: true,
        },
      },
    },
  };
});
