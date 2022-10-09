import React, { FC, useRef } from "react";
import { afterEach, describe, it, expect, vi } from "vitest";
import { render } from "@testing-library/react";
import Cookie from "js-cookie";
import {
  RouteObject,
  createMemoryRouter,
  RouterProvider,
} from "react-router-dom";
import useParams, { TOKEN_NAME } from "./useParams";

type Props = {
  spy(params: ReturnType<typeof useParams>): void;
};

const FakePage: FC<Props> = ({ spy }) => {
  const ref = useRef(null);
  const { token, query } = useParams(ref);
  spy({ token, query });

  return <div ref={ref}></div>;
};

const setup = ({ spy }: Props, query: string = "") => {
  const basePath = "/path";
  const path = query ? "/path" + "?" + query : "/path";
  const route: RouteObject = {
    path: basePath,
    element: <FakePage spy={spy} />,
  };
  const router = createMemoryRouter([route], {
    initialEntries: [path],
  });
  return render(<RouterProvider router={router}></RouterProvider>);
};

describe("useParams", () => {
  afterEach(() => {
    Cookie.remove(TOKEN_NAME);
  });
  it("gets the token from cookies if it has been set", () => {
    const token = "TOKEN_1";
    const spy = vi.fn();
    Cookie.set(TOKEN_NAME, token);
    const screen = setup({ spy });
    expect(spy).toHaveBeenCalledWith({ token, query: new URLSearchParams("") });
  });
  it("gets the token from query params if cookie isn't there", () => {
    Cookie.remove(TOKEN_NAME);
    const token = "TOKEN_2";
    const spy = vi.fn();
    const searchParams = new URLSearchParams();
    searchParams.set(TOKEN_NAME, token);
    const screen = setup({ spy }, searchParams.toString());
    expect(spy).toHaveBeenCalledWith({ token, query: searchParams });
  });
});
