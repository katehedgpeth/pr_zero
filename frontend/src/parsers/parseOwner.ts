import Owner, { DiscardKey, OwnerType, RawOwner } from "../types/Owner";
import { throwIfUnexpectedKey } from "./helpers";

export const SAMPLE_RAW_OWNER: RawOwner = {
  avatar_url: "https://avatars.github.com",
  events_url: "https://github.com",
  followers_url: "https://github.com",
  following_url: "https://github.com",
  gists_url: "https://github.com",
  gravatar_id: "https://github.com",
  html_url: "https://github.com",
  id: 1234567,
  "is_site_admin?": false,
  login: "owner_username",
  node_id: "WOIURFLSDKJFLSKJF",
  organizations_url: "https://github.com",
  received_events_url: "https://github.com",
  repos_url: "https://github.com",
  starred_url: "https://github.com",
  subscriptions_url: "https://github.com",
  url: "https://github.com",
  type: "organization",
};

const KEYS = Object.keys(SAMPLE_RAW_OWNER) as Array<keyof RawOwner>;

const shouldNotKeepKey = (key: keyof RawOwner): key is DiscardKey =>
  DISCARD_KEYS.includes(key as DiscardKey);

const parseKeyVal = (
  maybeKey: string,
  unparsedVal: RawOwner[keyof RawOwner]
): [keyof Owner, Owner[keyof Owner]] | false => {
  const key = throwIfUnexpectedKey(maybeKey, KEYS, "RawOwner");
  if (shouldNotKeepKey(key)) return false;
  switch (key) {
    case "is_site_admin?":
      return ["is_site_admin", unparsedVal];
    case "type":
      if (["organization"].includes(unparsedVal as string)) {
        return [key, unparsedVal as OwnerType];
      } else {
        throw new Error(`Unexpected organization type: ${unparsedVal}`);
      }
    default:
      return [key, unparsedVal];
  }
};

const DISCARD_KEYS: DiscardKey[] = [
  "events_url",
  "followers_url",
  "following_url",
  "gists_url",
  "gravatar_id",
  "html_url",
  "organizations_url",
  "starred_url",
  "subscriptions_url",
];

const reducer = (
  owner: Owner,
  [maybeKey, unparsedVal]: [string, RawOwner[keyof RawOwner]]
): Owner => {
  const maybeKV = parseKeyVal(maybeKey, unparsedVal);
  if (!maybeKV) return owner;

  const [key, parsedVal] = maybeKV;
  return { ...owner, [key]: parsedVal };
};

const parseOwner = (raw: RawOwner): Owner =>
  Object.entries(raw).reduce(reducer, {} as Owner);

export default parseOwner;
