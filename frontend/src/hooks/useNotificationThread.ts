import { QueryFunction, useQuery, UseQueryResult } from "react-query";
import { get } from "../services/api";
interface Props {
  isOpen: boolean;
  notificationId: string;
  token: string;
}

interface Thread {}

type QueryContext = [[string, string], Props];

const endpoint = (id: string): string => `/notifications/${id}/thread`;

const getThread: QueryFunction<
  { isOpen: false; thread: null } | { isOpen: true; thread: Thread },
  QueryContext
> = async ({
  queryKey: [[_key, _thread], { isOpen, notificationId, token }],
}) =>
  isOpen === false
    ? {
        isOpen: false,
        thread: null,
      }
    : {
        isOpen: true,
        thread: await get<Thread>(endpoint(notificationId), { token }),
      };

const useNotificationThread = (props: Props): UseQueryResult =>
  useQuery([["notification", "thread"], props], getThread);

export default useNotificationThread;
