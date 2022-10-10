import { RawSubject, Subject, SubjectType } from "../types/Notification";
import { throwIfUnexpectedKey } from "./helpers";

export const SAMPLE_RAW_SUBJECT: RawSubject = {
  latest_comment_url: null,
  type: "pull_request",
  title: "Title",
  url: "https://github.com",
};

const KEYS = Object.keys(SAMPLE_RAW_SUBJECT) as Array<keyof Subject>;

const TYPES: Subject["type"][] = ["pull_request"];

const typeIsSubjectType = (type: string): type is SubjectType =>
  TYPES.includes(type as Subject["type"]);

const parseKeyVal = (
  maybeKey: string,
  unparsedVal: RawSubject[keyof RawSubject]
): [keyof Subject, Subject[keyof Subject]] => {
  const key = throwIfUnexpectedKey(maybeKey, KEYS, "RawSubject");

  switch (key) {
    case "type":
      if (typeIsSubjectType(unparsedVal as Subject["type"])) {
        return [key, unparsedVal as SubjectType];
      } else {
        throw new Error(`Unexpected subject type: ${unparsedVal}`);
      }

    default:
      return [key, unparsedVal === null ? undefined : unparsedVal];
  }
};

const reducer = (
  subject: Subject,
  [maybeKey, unparsedVal]: [string, RawSubject[keyof RawSubject]]
): Subject => {
  const [key, parsedVal] = parseKeyVal(maybeKey, unparsedVal);
  return { ...subject, [key]: parsedVal };
};

const parseSubject = (raw: RawSubject): Subject =>
  Object.entries(raw).reduce(reducer, {} as Subject);

export default parseSubject;
