import Notification from "../components/Notification";
import Repo, { RawRepo } from "./Repo";

export default interface Notification {
  id: string;
  is_unread: boolean;
  last_read_at?: Date;
  reason: NotificationReason;
  repo: Repo;
  subject: Subject;
  subscription_url: string;
  updated_at: Date;
  url: string;
}

export interface Subject {
  latest_comment_url?: string;
  title: string;
  type: SubjectType;
  url: string;
}

export type RawSubject = Omit<Subject, "type" | "latest_comment_url"> & {
  type: string;
  latest_comment_url: string | null;
};

export type SubjectType = "pull_request";

export type RawParsed = {
  last_read_at: string | null;
  updated_at: string;
  repo: RawRepo;
  subject: RawSubject;
};

export type RawRenamed = {
  "is_unread?": boolean;
};

interface RawRenamedDict {
  "is_unread?": "is_unread";
}

export type ParsedKey = keyof RawParsed | RawRenamedDict["is_unread?"];

export type RawNotification = Omit<Notification, ParsedKey> &
  RawParsed &
  RawRenamed;

type NotificationReason = "subscribed";
