import React, { FC } from "react";
import styled, { css } from "styled-components";
import INotification from "../../types/Notification";
import Labels from "./Labels";
import Subject from "./Subject";
import Dates from "./Dates";
import { COLORS } from "./Colors";

interface PrimitiveValueProps {
  k: keyof INotification;
  v: string | number | boolean | Date | undefined;
}

const Styled = styled.div<{ is_unread: boolean }>`
  padding: 10px;
  margin-bottom: 30px;
  border-width: 1px 0 0 1px;
  border-style: solid;
  border-color: #ccc;
  ${({ is_unread }) =>
    is_unread &&
    css`
      border-left: 3px solid ${COLORS.pink_purple};
    `}
`;

const PrimitiveValue: FC<PrimitiveValueProps> = ({ k, v }) => (
  <div>
    <label id={`${k}-label`}>{k}:</label>
    <span id={`${k}-value`} aria-labelledby={`${k}-label`}>
      {v?.toString()}
    </span>
  </div>
);

const Notification: FC<INotification> = ({
  id,
  is_unread,
  last_read_at,
  reason,
  repo,
  subject: { type, title },
  subscription_url,
  updated_at,
  url,
}) => (
  <Styled is_unread={is_unread}>
    <Labels reason={reason} type={type} />
    <Subject title={title} url={url} />
    <Dates updated_at={updated_at} last_read_at={last_read_at} />
  </Styled>
);

export default Notification;
