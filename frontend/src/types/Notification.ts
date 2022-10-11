import Notification from "../components/Notification/Notification";
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

export type SubjectType = "pull_request" | "issue" | "release";

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

export type NotificationReason =
  | "assign" //	You were assigned to the issue.
  | "author" //	You created the thread.
  | "comment" //	You commented on the thread.
  | "ci_activity" //	A GitHub Actions workflow run that you triggered was completed.
  | "invitation" //	You accepted an invitation to contribute to the repository.
  | "manual" //	You subscribed to the thread (via an issue or pull request).
  | "mention" //	You were specifically @mentioned in the content.
  | "review_requested" //	You, or a team you're a member of, were requested to review a pull request.
  | "security_alert" //	GitHub discovered a security vulnerability in your repository.
  | "state_change" //	You changed the thread state (for example, closing an issue or merging a pull request).
  | "subscribed" //	You're watching the repository.
  | "team_mention"; //	You were on a team that was mentioned.
