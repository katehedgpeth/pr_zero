import { MutableRefObject, useEffect, useMemo, useRef } from "react";
import { useSearchParams } from "react-router-dom";
import Cookie from "js-cookie";
import { ROUTES } from "../router";

export interface Params {
  token: string;
  query: URLSearchParams;
}

const calls = { count: 0 };

export const TOKEN_NAME = "github_token";

const getCookieToken = () => Cookie.get(TOKEN_NAME);

const guaranteeToken = (query: URLSearchParams): string => {
  const cookieToken = getCookieToken();
  if (cookieToken) return cookieToken;

  // This is only used in development - the actual website sets a cookie
  // after authentication.
  const queryToken = query.get(TOKEN_NAME);
  if (!queryToken) throw new Error("Token is missing!");

  Cookie.set(TOKEN_NAME, queryToken);

  return queryToken;
};

const useParams = (ref: MutableRefObject<unknown>): Params => {
  const cookieToken = getCookieToken();
  const [query, setQuery] = useSearchParams();
  useEffect(() => {
    guaranteeToken(query);
    if (cookieToken && ref?.current && query.get(TOKEN_NAME)) {
      setQuery(
        (oldQuery) => {
          oldQuery.delete(TOKEN_NAME);
          return oldQuery;
        },
        { replace: false }
      );
    }
  }, [cookieToken]);
  return useMemo(() => {
    const token = guaranteeToken(query);
    Cookie.set(TOKEN_NAME, token);

    return {
      token,
      query,
    };
  }, [query, cookieToken]);
};

export default useParams;
