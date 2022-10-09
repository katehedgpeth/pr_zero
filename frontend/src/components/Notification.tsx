import React, { FC } from "react";
import { Notification as INotification } from "../hooks/useNotifications";

const Row: FC<{ k: string; v: { title?: string } }> = ({ k, v }) => (
  <div>
    <label id={`${k}-label`}>{k}:</label>
    <span id={`${k}-value`} aria-labelledby={`${k}-label`}>
      {k === "subject" ? v.title : JSON.stringify(v)}
    </span>
  </div>
);

const Notification: FC<INotification> = (notification) => (
  <div>
    {Object.entries(notification).map(([k, v]) => (
      <Row key={k} k={k} v={v} />
    ))}
  </div>
);

export default Notification;
