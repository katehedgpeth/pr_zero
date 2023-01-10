import React, { FC, useRef } from "react";
import styled from "styled-components";
import useParams from "../../hooks/useParams";
// import useNotifications from "../../hooks/useNotifications";
import Notification from "../Notification/Notification";
import useSocket from "../../hooks/useSocket";

const StyledDashboard = styled.div`
  margin: 0 30px;
  max-width: 100%;
`;

const Dashboard: FC = () => {
  const ref = useRef(null);
  const { token } = useParams(ref);
  const notifications = useSocket(token);
  if (notifications.isLoading) return <div ref={ref}>Loading...</div>;
  if (notifications.error)
    return <div ref={ref}>{notifications.error.toString()}</div>;
  if (notifications.data)
    return (
      <StyledDashboard ref={ref}>
        {notifications.data.map((notification) => (
          <Notification key={notification.id} {...notification} />
        ))}
      </StyledDashboard>
    );

  return <div>something went wrong</div>;
};

export default Dashboard;
