import React, { FC, useRef } from "react";
import useParams from "../../hooks/useParams";
import useNotifications from "../../hooks/useNotifications";
import Notification from "../Notification";

const Dashboard: FC = () => {
  const ref = useRef(null);
  const { token } = useParams(ref);
  const notifications = useNotifications({ token });
  if (notifications.isLoading) return <div ref={ref}>Loading...</div>;
  if (notifications.error)
    return <div ref={ref}>{notifications.error.toString()}</div>;
  if (notifications.data)
    return (
      <div ref={ref}>
        {notifications.data.map((notification) => (
          <Notification key={notification.id} {...notification} />
        ))}
      </div>
    );

  return <div>something went wrong</div>;
};

export default Dashboard;
