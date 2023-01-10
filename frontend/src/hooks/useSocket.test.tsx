import { describe, it, expect, vi } from "vitest";
import { render, renderHook, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider, UseQueryResult } from "react-query";

import useSocket from "./useSocket";
import Notification from "../types/Notification";
import { FC } from "react";

const FakePage: FC<{ token: string }> = ({ token }) => {
  const notifications = useSocket(token);
  return (
    <>
      {notifications.data?.forEach((notification) => (
        <div key={notification.id}>{notification.subject.title}</div>
      )) ?? null}
    </>
  );
};

const setup = (queryClient: QueryClient) => {
  return render(
    <QueryClientProvider client={queryClient}>
      <FakePage token="GITHUB_TOKEN" />
    </QueryClientProvider>
  );
};

describe("useSocket", () => {
  it("connects to websocket when called", async () => {
    const queryClient = new QueryClient();
    const queryClientSpy = vi.spyOn(queryClient, "setQueryData");
    const screen = setup(queryClient);
    await waitFor(() => {
      expect(queryClientSpy.mock.calls.length).toEqual(1);
    });
  });
});
