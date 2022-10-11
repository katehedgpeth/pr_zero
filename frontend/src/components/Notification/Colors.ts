import { NotificationReason, Subject } from "../../types/Notification";

export type Color =
  | "yellow_light"
  | "yellow"
  | "orange"
  | "pink_light"
  | "pink_hot"
  | "pink_bubble_gum"
  | "pink_purple"
  | "purple_light"
  | "purple"
  | "purple_raspberry"
  | "purple_jewel"
  | "purple_dark"
  | "purple_blue"
  | "green_light"
  | "blue_duke_blue"
  | "blue_jewel"
  | "blue_periwinkle"
  | "blue_turquoise"
  | "gray_light"
  | "gray_dark_soft"
  | "gray_darker";

export const COLORS: Record<Color, string> = {
  yellow_light: "#fbf8cc",
  yellow: "#FFBD00",
  orange: "#FF5400",
  pink_light: "#FFCFD2",
  pink_hot: "#FF0054",
  pink_bubble_gum: "#f72585",
  pink_purple: "#b5179e",
  purple_light: "#dbcdf0",
  purple: "#7209b7",
  purple_raspberry: "#9E0059",
  purple_jewel: "#560bad",
  purple_dark: "#480ca8",
  purple_blue: "#3a0ca3",
  blue_duke_blue: "#3f37c9",
  blue_jewel: "#4361ee",
  blue_periwinkle: "#4895ef",
  blue_turquoise: "#4cc9f0",
  green_light: "#cbdfbd",
  gray_light: "#cbcbcb",
  gray_dark_soft: "#706677",
  gray_darker: "#565264",
};

export const TYPE_COLORS_DICT: Record<
  NotificationReason | Subject["type"],
  Color
> = {
  assign: "yellow",
  issue: "orange",
  pull_request: "purple_light",
  author: "pink_bubble_gum",
  comment: "pink_purple",
  ci_activity: "purple",
  invitation: "purple_raspberry",
  manual: "purple_jewel",
  mention: "purple_dark",
  release: "pink_hot",
  review_requested: "purple_blue",
  security_alert: "blue_duke_blue",
  state_change: "blue_jewel",
  subscribed: "pink_light",
  team_mention: "blue_turquoise",
};
