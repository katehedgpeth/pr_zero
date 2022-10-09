import React from "react";
import {
  createBrowserRouter,
  RouteObject,
  LoaderFunction,
  useSearchParams,
} from "react-router-dom";
import Cookie from "js-cookie";
import Dashboard from "./components/Dashboard/Dashboard";
import { TOKEN_NAME } from "./hooks/useParams";

type Path = "/dashboard";

type RouteObjectWithKnownPath = RouteObject & {
  path: Path;
};

const DASHBOARD_PATH: RouteObjectWithKnownPath = {
  path: "/dashboard",
  element: <Dashboard />,
};

export const ROUTES = {
  dashboard: DASHBOARD_PATH,
};

const router = createBrowserRouter(Object.values(ROUTES));

export default router;
