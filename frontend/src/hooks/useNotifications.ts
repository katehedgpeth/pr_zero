import Notification from "../components/Notification";
import { useQuery, UseQueryResult } from "react-query";
import { get } from "../services/api";

const ENDPOINT = "/notifications";

export interface Notification {
  id: string;
}

interface Props {
  token: string;
}

export const getNotifications =
  (token: string) => async (): Promise<Notification[]> => {
    const { notifications } = await get<{ notifications: Notification[] }>(
      ENDPOINT,
      {
        token,
      }
    );
    return notifications;
  };

const useNotifications = ({ token }: Props): UseQueryResult<Notification[]> =>
  useQuery<Notification[]>(["notifications", token], getNotifications(token));

export default useNotifications;
