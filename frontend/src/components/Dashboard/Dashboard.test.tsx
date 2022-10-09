import { afterEach, describe, it, expect } from "vitest";
import { render, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "react-query";
import { RouterProvider, createMemoryRouter } from "react-router-dom";
import Cookie from "js-cookie";
import { ROUTES } from "../../router";
import { TOKEN_NAME } from "../../hooks/useParams";

const setup = (query: string = "") => {
  const queryClient = new QueryClient();

  const router = createMemoryRouter([ROUTES.dashboard], {
    initialEntries: [ROUTES.dashboard.path + query],
  });
  return {
    screen: render(
      <QueryClientProvider client={queryClient}>
        <RouterProvider router={router}></RouterProvider>
      </QueryClientProvider>
    ),
    router,
  };
};

describe("Dashboard", () => {
  afterEach(() => {
    Cookie.remove(TOKEN_NAME);
  });
  it("renders all notifications", async () => {
    const { screen } = setup();
    await waitFor(() => {
      expect(screen.getAllByLabelText("subject:").length).toBeGreaterThan(0);
    });
  });
  it("sets cookie using search params if they are available", async () => {
    Cookie.remove(TOKEN_NAME);
    const token = "token1234567";
    const { router } = setup("?" + TOKEN_NAME + "=" + token);
    expect(Cookie.get(TOKEN_NAME)).toEqual(token);
    await waitFor(() => {
      expect(router.state.location.search).toEqual("");
    });
  });
});
