import Notification, {
  ParsedKey,
  RawNotification,
  RawSubject,
} from "../types/Notification";
import { RawRepo } from "../types/Repo";
import parseRepo, { SAMPLE_RAW_REPO } from "./parseRepo";
import { throwIfUnexpectedKey } from "./helpers";
import parseSubject, { SAMPLE_RAW_SUBJECT } from "./parseSubject";

export const SAMPLE_RAW_NOTIFICATION: RawNotification = {
  id: "10348243",
  "is_unread?": true,
  last_read_at: null,
  reason: "subscribed",
  repo: SAMPLE_RAW_REPO,
  subject: SAMPLE_RAW_SUBJECT,
  subscription_url: "https://www.github.com",
  updated_at: "2020-10-01T10:10:10",
  url: "https://www.github.com/",
};

const KEYS = Object.keys(SAMPLE_RAW_NOTIFICATION) as Array<
  keyof RawNotification
>;

type DateKey = "last_read_at" | "updated_at";
const parseDate = (
  key: DateKey,
  val?: string
): [DateKey, Notification[DateKey]] => [key, val ? new Date(val) : undefined];

type ParsedVal = Notification[keyof Notification];

const parseKeyVal = (
  maybeKey: string,
  val: RawNotification[keyof RawNotification]
): [keyof Notification, ParsedVal] => {
  const rawKey = throwIfUnexpectedKey<RawNotification>(
    maybeKey,
    KEYS,
    "RawNotification"
  );
  switch (rawKey) {
    case "is_unread?":
      return ["is_unread", val as RawNotification["is_unread?"]];

    case "last_read_at":
    case "updated_at":
      return parseDate(rawKey, val as string | undefined);

    case "repo":
      return [rawKey, parseRepo(val as RawRepo)];

    case "subject":
      return [rawKey, parseSubject(val as RawSubject)];

    default:
      return [rawKey, val === null ? undefined : (val as ParsedVal)];
  }
};

const reducer = (
  notification: Notification,
  [maybeKey, val]: [string, RawNotification[keyof RawNotification]]
) => {
  const [key, parsedVal] = parseKeyVal(maybeKey, val);
  return { ...notification, [key]: parsedVal };
};

const parseNotification = (raw: RawNotification): Notification =>
  Object.entries(raw).reduce(reducer, {} as Notification);

export default parseNotification;
