import React, { FC } from "react";
import styled, { css } from "styled-components";
import { NotificationReason } from "../../types/Notification";
import { Subject } from "../../types/Notification";
import { Color, COLORS, TYPE_COLORS_DICT } from "./Colors";

interface Props {
  reason: NotificationReason;
  type: Subject["type"];
}

type Type = NotificationReason | Subject["type"];

type Dict = Record<Type, string>;

const WORDING_DICT: Partial<Dict> = {
  review_requested: "Review Requested",
  issue: "Issue",
  subscribed: "Subscribed",
  pull_request: "Pull Request",
};

const ALT_TEXT_DICT: Partial<Dict> = {
  assign: "You were assigned to the issue.",
  author: "You created the thread.",
  comment: "You commented on the thread.",
  ci_activity:
    "A GitHub Actions workflow run that you triggered was completed.",
  invitation: "You accepted an invitation to contribute to the repository.",
  manual: "You subscribed to the thread (via an issue or pull request).",
  mention: "You were specifically @mentioned in the content.",
  review_requested:
    "You, or a team you're a member of, were requested to review a pull request.",
  security_alert:
    "GitHub discovered a security vulnerability in your repository.",
  state_change:
    "You changed the thread state (for example, closing an issue or merging a pull request).",
  subscribed: "You're watching the repository.",
  team_mention: "	You were on a team that was mentioned.",
};

const StyledDiv = styled.div`
  margin: 5px 0;
  display: flex;
`;

const StyledLabel = styled.div<{ text: Type }>`
  border-radius: 5px;
  color: #fff;
  font-size: 0.75em;
  font-weight: 700;
  padding: 0 5px;
  margin-right: 5px;

  ${({ text }) => {
    const colorName = TYPE_COLORS_DICT[text];
    const hex = COLORS[colorName];
    return css`
      background-color: ${hex ?? "#ccc"};
    `;
  }}
`;

const Labels: FC<Props> = ({ reason, type }) => (
  <StyledDiv>
    <StyledLabel text={type} title={ALT_TEXT_DICT[type]}>
      <span></span>
      {WORDING_DICT[type]}
    </StyledLabel>
    <StyledLabel text={reason} title={ALT_TEXT_DICT[reason]}>
      {WORDING_DICT[reason]}
    </StyledLabel>
  </StyledDiv>
);

export default Labels;
