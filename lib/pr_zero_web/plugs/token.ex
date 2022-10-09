defmodule PrZeroWeb.Plugs.Token do
  @behaviour Plug
  alias Plug.Conn

  @token_missing "TOKEN_MISSING"
  @token_invalid "TOKEN_INVALID"

  def init([]) do
    []
  end

  def call(%Conn{req_headers: headers} = conn, []) do
    headers
    |> Enum.into(%{})
    |> do_call(conn)
  end

  defp do_call(%{"authorization" => "Bearer " <> token}, conn) do
    conn
    |> Conn.assign(:github_token, token)
    |> Conn.put_resp_cookie("github_token", token)
  end

  defp do_call(%{"authorization" => malformed}, conn) do
    send_error_response(conn, %{error: @token_invalid, received: malformed})
  end

  defp do_call(%{}, conn) do
    send_error_response(conn, %{error: @token_missing})
  end

  defp send_error_response(conn, error) do
    {:ok, body} = Jason.encode(error)

    conn
    |> Conn.put_resp_content_type("application/json")
    |> Conn.send_resp(:forbidden, body)
    |> Conn.halt()
  end
end
