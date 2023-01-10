import React, { FC } from "react";
import useNotificationThread from "../../hooks/useNotificationThread";

interface Props {
  id: string;
  isOpen: boolean;
  token: string;
}

const Thread: FC<Props> = ({ id, isOpen, token }) => {
  const thread = useNotificationThread({ notificationId: id, token });
  if (isOpen === false) return null;
  return (
    <div>
      {thread.status === "success" ? (thread.data as string) : thread.status}
    </div>
  );
};

export default Thread;
