import React, { FC, useRef, useState } from "react";
import styled, { css } from "styled-components";
import INotification from "../../types/Notification";
import Labels from "./Labels";
import Subject from "./Subject";
import Dates from "./Dates";
import { COLORS } from "./Colors";
import useParams from "../../hooks/useParams";
import Thread from "./Thread";

type Props = INotification;
interface PrimitiveValueProps {
  k: keyof INotification;
  v: string | number | boolean | Date | undefined;
}

const StyledContainer = styled.div<{ is_unread: boolean }>`
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

const StyledRow = styled.div`
  display: flex;
  justify-content: space-between;
`;

const PrimitiveValue: FC<PrimitiveValueProps> = ({ k, v }) => (
  <div>
    <label id={`${k}-label`}>{k}:</label>
    <span id={`${k}-value`} aria-labelledby={`${k}-label`}>
      {v?.toString()}
    </span>
  </div>
);

const Notification: FC<Props> = ({
  id,
  is_unread,
  last_read_at,
  reason,
  repo: { full_name: repo_full_name, html_url: repo_html_url },
  subject: { type, title },
  updated_at,
}) => {
  const [threadIsOpen, setThreadIsOpen] = useState(false);
  const ref = useRef(null);
  const { token } = useParams(ref);
  const onClickSubject = () => setThreadIsOpen(!threadIsOpen);
  return (
    <StyledContainer is_unread={is_unread} ref={ref}>
      <StyledRow>
        <div>
          <a href={repo_html_url}>{repo_full_name}</a>
        </div>
        <Labels reason={reason} type={type} />
      </StyledRow>

      <Subject onClick={onClickSubject} title={title} />
      <Dates updated_at={updated_at} last_read_at={last_read_at} />
      <Thread isOpen={threadIsOpen} id={id} token={token} />
    </StyledContainer>
  );
};

export default Notification;
