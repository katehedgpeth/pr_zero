import Repo, { RawRepo, DiscardKey } from "../types/Repo";
import { throwIfUnexpectedKey } from "./helpers";
import parseOwner, { SAMPLE_RAW_OWNER } from "./parseOwner";

export const SAMPLE_RAW_REPO: RawRepo = {
  description: "description",
  full_name: "organization/repo_name",
  events_url: "https://github.com",
  html_url: "https://github.com",
  id: 1,
  "is_fork?": false,
  "is_private?": true,
  name: "Repo Name",
  node_id: "OEIURLSDKJFLJWEOIRU",
  open_issues: null,
  owner: SAMPLE_RAW_OWNER,
  pushed_at: "2022-10-10T10:10:10",
  pulls_url: "https://github.com/org/repo/pulls",
  url: "https://github.com",
  visibility: null,
};

const KEYS = Object.keys(SAMPLE_RAW_REPO) as Array<keyof RawRepo>;

const DISCARD_KEYS: DiscardKey[] = ["is_fork?", "open_issues", "pushed_at"];

const shouldNotKeepKey = (key: keyof RawRepo): key is DiscardKey =>
  DISCARD_KEYS.includes(key as DiscardKey);

const parseKeyVal = (
  maybeKey: string,
  val: RawRepo[keyof RawRepo]
): [keyof Repo, Repo[keyof Repo]] | false => {
  const key = throwIfUnexpectedKey(maybeKey, KEYS, "RawRepo");
  if (shouldNotKeepKey(key)) return false;
  switch (key) {
    case "owner":
      return [key, parseOwner(val as RawRepo["owner"])];

    case "is_private?":
      return ["is_private", val as RawRepo["is_private?"]];

    default:
      return [key, val === null ? undefined : (val as Repo[keyof Repo])];
  }
};

const reducer = (
  repo: Repo,
  [maybeKey, unparsedVal]: [string, RawRepo[keyof RawRepo]]
): Repo => {
  const maybeKV = parseKeyVal(maybeKey, unparsedVal);
  if (!maybeKV) return repo;

  const [key, parsedVal] = maybeKV;
  return { ...repo, [key]: parsedVal };
};

const parseRepo = (raw: RawRepo): Repo =>
  Object.entries(raw).reduce(reducer, {} as Repo);

export default parseRepo;
