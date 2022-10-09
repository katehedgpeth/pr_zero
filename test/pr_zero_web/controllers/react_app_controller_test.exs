defmodule ReactAppControllerTest do
  use PrZeroWeb.ConnCase

  @token "TOKEN"
  @cookie_name "github_token"

  defp get_redirect_location(conn) do
    conn
    |> Map.fetch!(:resp_headers)
    |> Enum.into(%{})
    |> Map.fetch!("location")
  end

  defp validate_cookie(%{resp_cookies: %{@cookie_name => %{value: @token}}} = conn), do: conn

  describe "GET /dashboard" do
    test "with ?token=TOKEN query param, redirects to /dashboard and sets token as cookie", %{
      conn: conn
    } do
      conn = get(conn, Routes.react_app_path(conn, :index, token: @token))

      assert conn.status == 302
      assert validate_cookie(conn)

      redirect_location = get_redirect_location(conn)
      assert redirect_location == "/dashboard"

      redirected = get(conn, redirect_location)
      assert validate_cookie(redirected)
    end

    test "with cookie and no query param, sends react HTML", %{conn: conn} do
      assert conn
             |> put_req_cookie(@cookie_name, @token)
             |> get(Routes.react_app_path(conn, :index))
             |> validate_cookie()
             |> html_response(200) =~ "<body>\n    <div id=\"root\"></div>\n    \n  </body>"
    end

    test "with invalid token param, sends forbidden response", %{conn: conn} do
      conn = get(conn, Routes.react_app_path(conn, :index, token: nil))
      assert html_response(conn, :forbidden) =~ "You Shall Not Pass"
    end

    test "with no token param and no cookie, sends forbidden response", %{conn: conn} do
      conn = get(conn, Routes.react_app_path(conn, :index))
      assert html_response(conn, :forbidden) =~ "You Shall Not Pass"
    end
  end
end
