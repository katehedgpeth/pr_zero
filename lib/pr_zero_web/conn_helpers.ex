defmodule PrZeroWeb.ConnHelpers do
  alias Plug.Conn

  @spec get_csrf_token(Conn.t()) :: {:ok, {String.t(), Conn.t()}} | :error
  def get_csrf_token(%Conn{private: %{:plug_session => %{"_csrf_token" => csrf_token}}} = conn),
    do: {:ok, {csrf_token, conn}}

  def get_csrf_token(%Conn{}), do: :error
end
