import React, { FC } from "react";
import styled from "styled-components";

interface Props {
  updated_at: Date;
  last_read_at?: Date;
}

const StyledDate = styled.div`
  color: #7e7e7e;
  flex: 1;
  font-size: 0.75rem;
`;

interface DateProps {
  date?: Date;
  name: string;
}
const Date: FC<DateProps> = ({ date, name }) => (
  <StyledDate>
    <span>{name}: </span>
    {date
      ? date.toLocaleString("en-US", {
          day: "numeric",
          month: "short",
          year: "numeric",
          hour: "numeric",
          minute: "2-digit",
          // timeZone: "EST",
        })
      : "--"}
  </StyledDate>
);

const StyledDates = styled.div`
  display: flex;
`;

const Dates: FC<Props> = ({ updated_at, last_read_at }) => (
  <StyledDates>
    <Date date={updated_at} name="Updated at" />
    <Date date={last_read_at} name="Last Read" />
  </StyledDates>
);

export default Dates;
