import React, { FC } from "react";
import { Subject as ISubject } from "../../types/Notification";
import styled from "styled-components";
import { COLORS } from "./Colors";

type Props = Omit<ISubject, "type">;

const Styled = styled.div`
  font-size: 1.4em;

  a {
    color: ${COLORS.gray_darker};
    &:visited {
      color: ${COLORS.gray_light};
    }
  }
`;

const Subject: FC<Props> = ({ title, url }) => (
  <Styled>
    <a href={url}>{title}</a>
  </Styled>
);

export default Subject;
