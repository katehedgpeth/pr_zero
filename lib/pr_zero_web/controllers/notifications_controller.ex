defmodule PrZeroWeb.NotificationsController do
  require Logger
  use PrZeroWeb, :controller
  use PrZero.Github.Aliases

  alias Plug.Conn

  def index(%Conn{assigns: %{user: %User{} = user}} = conn, %{}) do
    user.token
    |> PrZero.State.Notifications.all()
    |> case do
      {:ok, %{} = notifications} ->
        json(conn, %{notifications: notifications |> Map.values() |> Enum.map(&Map.from_struct/1)})

      {:error, error} ->
        conn |> put_status(:bad_gateway) |> json(%{reason: Jason.encode!(error)})
    end
  end

  def thread(%Conn{assigns: %{user: %User{token: token} = user}} = conn, %{
        "id" => id
      }) do
    id
    |> PrZero.State.Notifications.find(token)
    |> case do
      {:ok, %Notification{} = notification} ->
        do_thread(conn, notification, user)

      {:error, {:not_found, ^token}} ->
        conn
        |> put_status(:forbidden)
        |> json(%{reason: "not_authorized"})
    end
  end

  defp do_thread(%Conn{} = conn, %Notification{} = notification, %User{} = user) do
    notification
    |> Notification.get_thread(user)
    |> case do
      {:ok, thread} ->
        json(conn, %{thread: thread})
    end
  end
end
