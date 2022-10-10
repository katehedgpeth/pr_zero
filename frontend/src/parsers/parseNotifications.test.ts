import { describe, it, expect } from "vitest";
import notifications from "../../mocks/notifications";
import Notification, { RawNotification, Subject } from "../types/Notification";
import Repo from "../types/Repo";
import parseNotification, {
  SAMPLE_RAW_NOTIFICATION,
} from "./parseNotification";

const SampleNotification = parseNotification(SAMPLE_RAW_NOTIFICATION);

type RawKey = keyof RawNotification;
type RawVal = RawNotification[RawKey];
type ParsedKey = keyof Notification;
type ParsedVal = Notification[ParsedKey] | undefined;

type validator = (
  val: ParsedVal,
  raw: RawVal
) => [boolean, RawKey | ParsedKey, ParsedVal, RawVal];

interface SyncExpectationResult {
  actual: unknown;
  message: () => string;
  pass: boolean;
  expected?: unknown;
}
interface CustomMatchers<R = SyncExpectationResult> {
  toBeOptionalString(received: any, name?: string): R;
  toBeOptionalType(received: any, type: string, name?: string): R;
  toBeOptionalDate(received: any, name?: string): R;
  toBeDate(received: any, name?: string): R;

  toBeUrl(received: any, name?: string): R;
  toBeType(actual: any, type: string, name?: string): R;
}

declare global {
  namespace Vi {
    interface Assertion extends CustomMatchers {}
    interface AsymmetricMatchersContaining extends CustomMatchers {}
  }
}

const matcherResponse = ({
  pass,
  message,
  actual,
  expected,
}: {
  pass: boolean;
  message: string;
  actual: any;
  expected: any;
}): SyncExpectationResult => ({
  actual,
  expected,
  message: () => (pass ? "" : message),
  pass,
});

const buildMessage = (name: string, type: string, received: any) =>
  `Expected ${name} to be ${type}, but got: ${received} `;

expect.extend({
  toBeOptionalString: (actual, name) =>
    expect(actual).toBeOptionalType("string", name),
  toBeOptionalType: (actual, type, name) =>
    matcherResponse({
      actual,
      pass: actual === undefined || typeof actual === type,
      message: buildMessage(name, `a ${type} or undefined`, actual),
      expected: type,
    }),

  toBeOptionalDate: (actual, name) => {
    const response = {
      actual,
      message: buildMessage(name, "a Date or undefined", actual),
      pass: true,
      expected: "a Date",
    };
    try {
      if (actual === undefined) return matcherResponse(response);
      expect(actual).toBeInstanceOf(Date);
      return matcherResponse(response);
    } catch {
      return matcherResponse({
        ...response,
        pass: false,
      });
    }
  },

  toBeType: (actual, type, name) =>
    matcherResponse({
      actual,
      pass: typeof actual === type,
      message: buildMessage(name, type, actual),
      expected: type,
    }),
  toBeUrl: (actual, name) =>
    matcherResponse({
      actual,
      pass: typeof actual === "string" && actual.startsWith("https://"),
      message: buildMessage(name, "a url", actual),
      expected: "string starting with https://",
    }),
});

describe("parseNotifications", () => {
  it("parses a notification", () => {
    const raw = notifications.notifications[0];
    const parsed = parseNotification(raw);
    expect(parsed.url).toBeUrl(".url");
    expect([true, false]).toContain(parsed.is_unread);
    expect(parsed.repo.description).toBeOptionalString("repo.description");
  });
  describe.each(notifications.notifications.slice(0, 10))(
    "%o.id",
    (raw: RawNotification) => {
      const parsed = parseNotification(raw);
      const keys = Object.keys(SampleNotification) as Array<keyof Notification>;
      it.each(keys.map((key) => [key, parsed[key]]))(
        "parses %s key correctly",
        // this is giving an error because the return type of my custom parsers is wrong,
        // but the validators still work
        // @ts-expect-error
        (key, val) => {
          switch (key) {
            case "id":
              return expect(val).toBeType("string", ".id");
            case "url":
              return expect(val).toBeUrl(".url");
            case "updated_at":
              return expect(val).toBeInstanceOf(Date);
            case "last_read_at":
              return expect(val).toBeOptionalDate(".last_read_at");
            case "subscription_url":
              return expect(val).toBeUrl(".subscription_url");

            case "subject":
              const subject = val as Subject;
              const subjectKeys = Object.keys(subject) as Array<keyof Subject>;
              return subjectKeys.forEach((subjectKey) =>
                expect(subject[subjectKey]).toBeType(
                  "string",
                  "subject." + subjectKey
                )
              );

            case "repo":
              const repo = val as Repo;
              return expect(repo.id).toBeType("number", "repo.id");
            case "reason":
              return expect(["pull_request", "subscribed"]).toContain(val);

            case "is_unread":
              return expect([true, false]).toContain(val);
            default:
              console.log(parsed);
              return expect(key).toBeUndefined();
          }
        }
      );
    }
  );
  // describe.each(notifications.notifications)(
  //   "id: %o.id",
  //   (raw: RawNotification) => {
  //     const parsed = parseNotification(raw);
  //     it.each(Object.keys(SampleNotification) as Array<keyof Notification>)(
  //       "parses %s correctly",
  //       (key: keyof Notification) => {
  //         const rawKeyDict: Record<string, RawKey> = {
  //           is_unread: "is_unread?",
  //         };
  //         const is = (parsed: unknown): void =>
  //           expect(typeof parsed).toBe(type);
  //         const message = (
  //           maybe: unknown,
  //           raw: unknown,
  //           key: string,
  //           type: string
  //         ) =>
  //           `expected ${raw} to be parsed to a ${type} for key ${key}, but got ${key}`;
  //         const validateType = (
  //           maybe: unknown,
  //           raw: unknown,
  //           key: string,
  //           type: "string" | "number" | "undefined" | "boolean"
  //         ): void =>
  //           expect(typeof maybe, message(maybe, raw, key, type)).toBe(type);
  //         const validateMatch = (
  //           maybe: unknown,
  //           raw: unknown,
  //           key: string,
  //           match: object,
  //           matchName: string
  //         ): void =>
  //           expect(maybe, message(maybe, raw, key, matchName)).toMatchObject(
  //             match
  //           );
  //         type Validator = (maybe: unknown, raw: unknown) => void;
  //         type ValidatorCurry = (key: string) => Validator;
  //         const isNumber: ValidatorCurry =
  //           (key) =>
  //           (maybe, raw): void =>
  //             validateType(maybe, raw, key, "number");
  //         const isString: ValidatorCurry = (key) => (maybe, raw) =>
  //           validateType(maybe, raw, key, "string");
  //         const isUndefined: ValidatorCurry = (key) => (maybe, raw) =>
  //           validateType(maybe, raw, key, "undefined");
  //         const isDate: ValidatorCurry = (key) => (maybe, raw) =>
  //           validateMatch(maybe, raw, key, new Date(), "date");
  //         const isExpectedValue: Record<RawKey | ParsedKey, Validator> = {
  //           id: isString("id"),
  //           updated_at: isDate("updated_at"),
  //           last_read_at: (parsed, raw) =>
  //             typeof raw === "string"
  //               ? isString("last_read_at")(parsed, raw)
  //               : isUndefined("last_read_at")(parsed, raw),
  //           repo: (parsedVal, rawVal) => [
  //             typeof (parsedVal as Repo).id === "number",
  //             "repo",
  //             parsedVal,
  //             rawVal,
  //           ],
  //           subject: (parsed, raw) => [
  //             typeof (parsed as Subject).title === "string",
  //             "subject",
  //             parsed,
  //             raw,
  //           ],
  //           "is_unread?": isUndefined("is_unread?"),
  //           is_unread: (parsed, raw) => [
  //             typeof parsed === "boolean",
  //             "is_unread",
  //             parsed,
  //             raw,
  //           ],
  //           reason,
  //           subscription_url,
  //           url,
  //         };
  //         const parsedVal = parsed[key];
  //         const rawKey = rawKeyDict[key] ?? key;
  //         expect(isExpectedValue[key](parsedVal, raw[rawKey])).toEqual([
  //           true,
  //           parsedVal,
  //         ]);
  //       }
  //     );
  //   }
  // );
  // describe.each(Object.keys(SampleNotification) as Array<keyof Notification>)(
  //   "key: %s",
  //   (key) => {
  //     it.each(notifications.notifications)(
  //       "is parsed correctly for %o.id",
  //       (raw: RawNotification) => {
  //         const parsed = parseNotification(raw);
  //         expect(parsed[key]).toEqual(raw.id);
  //         expect();
  //       }
  //     );
  //   }
  // );
});
