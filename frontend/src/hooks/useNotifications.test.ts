import { describe, it, expect, TestFunction } from "vitest";
import { waitFor } from "@testing-library/react";
import useNotifications, { getNotifications } from "./useNotifications";

const TEST_TOKEN = __ENV__.VITE_TEST_TOKEN;
if (!TEST_TOKEN) throw new Error("VITE_TEST_TOKEN not found");

describe("useNotifications", async () => {
  describe("getNotifications", async () => {
    it("fetches notifications", async () => {
      const notifications = await getNotifications(TEST_TOKEN)();
      expect(notifications.length).toBeGreaterThan(0);
    });
  });
});
