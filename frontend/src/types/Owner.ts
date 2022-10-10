export type OwnerType = "organization";

type ParsedKey = "is_site_admin" | "type";

export default interface Owner {
  avatar_url: string;
  id: number;
  is_site_admin: boolean;
  login: string;
  node_id: string;
  received_events_url: string;
  repos_url: string;
  type: OwnerType;
  url: string;
}

type RenamedDict = {
  "is_site_admin?": "is_site_admin";
};

type RawRenamed = {
  "is_site_admin?": boolean;
};

type RawParsed = {
  type: string;
};

export type RawOwner = Omit<Owner, ParsedKey> &
  Record<DiscardKey, string> &
  RawRenamed &
  RawParsed;

export type DiscardKey =
  | "events_url"
  | "followers_url"
  | "following_url"
  | "gists_url"
  | "gravatar_id"
  | "html_url"
  | "organizations_url"
  | "starred_url"
  | "subscriptions_url";
