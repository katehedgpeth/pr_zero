import { describe, it, expect } from "vitest";
import { AxiosError } from "axios";
import * as API from "./api";
import { Notification } from "../hooks/useNotifications";

type Expected = {
  notifications: Notification[];
};

describe("Api", () => {
  describe("get/2", () => {
    it("calls the API and returns the response payload", async () => {
      const response = (await API.get<Expected>("/notifications", {
        token: __ENV__.VITE_TEST_TOKEN,
      })) as Expected;
      expect(response.notifications.length).toEqual(50);
    });
  });
});
