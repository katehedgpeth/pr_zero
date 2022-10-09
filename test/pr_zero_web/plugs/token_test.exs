defmodule PrZeroWeb.Plugs.TokenTest do
  use PrZeroWeb.ConnCase
  alias PrZeroWeb.Plugs.Token

  @token "TOKEN1234567"

  describe "plug PrZeroWeb.Plugs.Token" do
    test "assigns token to conn if request includes an auth header", %{conn: conn} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{@token}")
        |> Token.call([])

      assert conn.assigns == %{github_token: @token}
    end

    test "sends an error response if auth header exists but value is malformed", %{conn: conn} do
      conn =
        conn
        |> put_req_header("authorization", @token)
        |> Token.call([])

      assert json_response(conn, :forbidden) == %{
               "error" => "TOKEN_INVALID",
               "received" => @token
             }
    end

    test "sends an error response if auth header does not exist", %{conn: conn} do
      conn = Token.call(conn, [])
      assert json_response(conn, :forbidden) == %{"error" => "TOKEN_MISSING"}
    end
  end
end
