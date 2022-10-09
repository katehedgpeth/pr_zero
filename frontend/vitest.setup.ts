import { loadEnv } from "vite";
import { beforeEach } from "vitest";
import Cookie from "js-cookie";
import { fetch, Request, Response } from "@remix-run/web-fetch";

import { TOKEN_NAME } from "./src/hooks/useParams";

beforeEach((_, { mode }) => {
  const __ENV__ = loadEnv(mode, process.cwd());
  if (!__ENV__.VITE_TEST_TOKEN)
    throw new Error("VITE_TEST_TOKEN env var is missing!");
  Cookie.set(TOKEN_NAME, __ENV__.VITE_TEST_TOKEN);

  // copied from https://github.com/remix-run/react-router/blob/main/packages/react-router-dom/__tests__/setup.ts
  if (!globalThis.fetch) {
    // Built-in lib.dom.d.ts expects `fetch(Request | string, ...)` but the web
    // fetch API allows a URL so @remix-run/web-fetch defines
    // `fetch(string | URL | Request, ...)`
    // @ts-expect-error
    globalThis.fetch = fetch;
    // Same as above, lib.dom.d.ts doesn't allow a URL to the Request constructor
    // @ts-expect-error
    globalThis.Request = Request;
    // web-std/fetch Response does not currently implement Response.error()
    // @ts-expect-error
    globalThis.Response = Response;
  }
});
