import React, { FC, MouseEvent } from "react";
import { Subject as ISubject } from "../../types/Notification";
import styled from "styled-components";
import { COLORS } from "./Colors";

type Props = Omit<ISubject, "type" | "url"> & {
  onClick(ev: MouseEvent): void;
};

const Styled = styled.div`
  font-size: 1.4em;

  a {
    color: ${COLORS.gray_darker};
    &:visited {
      color: ${COLORS.gray_light};
    }
  }
`;

const Subject: FC<Props> = ({ onClick, title }) => (
  <Styled>
    <a onClick={onClick}>{title}</a>
  </Styled>
);

export default Subject;
