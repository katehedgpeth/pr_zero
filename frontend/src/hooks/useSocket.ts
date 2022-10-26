import { Socket } from "phoenix";
import { useEffect, useState } from "react";
import { useQuery, useQueryClient } from "react-query";
import Notification from "../types/Notification";

const ENDPOINT = "ws://localhost:4000/socket";

interface MessagePayload {
  notifications: Notification[];
}

const useSocket = (github_token: string) => {
  const queryClient = useQueryClient();
  const [socket] = useState<Socket>(
    new Socket(ENDPOINT, { params: { github_token } })
  );
  const [queryKey] = useState<[string, string]>([
    "notifications",
    github_token,
  ]);

  useEffect(() => {
    if (socket.isConnected()) return;
    console.log("Connecting socket");
    // socket.connect();
  }, [socket]);

  const getNotifications = async () => {
    if (!socket.isConnected()) socket.connect();

    const channel = socket.channel(`notifications:${github_token}`);
    channel.on("updated_data", ({ notifications }: MessagePayload) => {
      queryClient.setQueryData(["notifications", github_token], notifications);
    });
    channel.join();
    return [];
  };

  return useQuery<Notification[]>(queryKey, getNotifications);
};

export default useSocket;
