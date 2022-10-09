defmodule PrZeroWeb.NotificationsController do
  require Logger
  use PrZeroWeb, :controller
  use PrZero.Github.Aliases

  alias Plug.Conn

  def index(%Conn{assigns: %{user: {:ok, %User{} = user}}} = conn, %{}) do
    user
    |> Notifications.get()
    |> case do
      {:ok, notifications} ->
        json(conn, %{notifications: Enum.map(notifications, &Map.from_struct/1)})

      {:error, error} ->
        conn |> put_status(:bad_gateway) |> json(%{reason: Jason.encode!(error)})
    end
  end
end
