import Axios, { Method, AxiosError, AxiosBasicCredentials } from "axios";

interface Options<T> {
  body?: T;
  token: string;
}

declare global {
  interface Window {
    baseURL: string;
  }
}

window.baseURL = "http://localhost:4000/api";

export const get = <T>(
  path: string,
  { token }: Options<undefined>
): Promise<T> => request("GET", path, { token });

const request = <T, B extends BodyInit | undefined = undefined>(
  method: Method,
  path: string,
  { token, body }: Options<B>
): Promise<T> =>
  Axios.request<T>({
    method,
    data: body,
    url: "/api" + path,
    baseURL: "http://localhost:4000",
    headers: { Authorization: "Bearer " + token },
  }).then(({ data }) => data);
