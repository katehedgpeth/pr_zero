defmodule PrZeroWeb.NotificationsChannel do
  alias Phoenix.Socket
  alias PrZero.{State, Github}
  use Phoenix.Channel

  def join(
        "notifications:" <> token,
        _payload,
        %Socket{
          assigns: %{
            user: %State.User{
              user_data: %Github.User{token: token},
              notifications: notifications_pid
            }
          }
        } = socket
      ) do
    :ok = State.Notifications.subscribe(notifications_pid)
    {:ok, socket}
  end

  def join("notifications:" <> _, _payload, %Socket{}) do
    {:error, %{reason: :not_authorized}}
  end

  def handle_info({:updated_data, notifications}, socket) do
    push(socket, "updated_data", %{notifications: notifications})
    {:noreply, socket}
  end
end
