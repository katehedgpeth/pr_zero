import { useQuery, UseQueryResult } from "react-query";
import parseNotification from "../parsers/parseNotification";
import { get } from "../services/api";
import Notification, { RawNotification } from "../types/Notification";

const ENDPOINT = "/notifications";

interface Props {
  token: string;
}

export const getNotifications =
  (token: string) => async (): Promise<Notification[]> => {
    const { notifications } = await get<{ notifications: RawNotification[] }>(
      ENDPOINT,
      {
        token,
      }
    );
    return notifications.map(parseNotification);
  };

const useNotifications = ({ token }: Props): UseQueryResult<Notification[]> =>
  useQuery<Notification[]>(["notifications", token], getNotifications(token));

export default useNotifications;
