import Owner, { RawOwner } from "./Owner";

type ParsedKey = "is_private" | "owner" | "description";

export default interface Repo {
  description?: string;
  events_url: string;
  full_name: string;
  html_url: string;
  id: number;
  is_private: boolean;
  name: string;
  node_id: string;
  owner: Owner;
  pulls_url: string;
  url: string;
}

export type DiscardKey =
  | "is_fork?"
  | "open_issues"
  | "pushed_at"
  | "visibility";

type ParsedRaw = {
  description: string | null;
  owner: RawOwner;
};

type RenamedRaw = {
  "is_private?": Repo["is_private"];
};

export type RawRepo = Omit<Repo, keyof ParsedRaw | "is_private"> &
  ParsedRaw &
  RenamedRaw &
  Record<DiscardKey, string | boolean | null>;
