defmodule PrZeroWeb.AuthControllerTest do
  use PrZeroWeb.ConnCase
  alias Plug.Conn
  alias ExUnit.CaptureLog
  alias PrZero.Github
  alias Github.Auth
  alias PrZeroWeb.ConnHelpers

  defp pass_through_homepage(%Conn{} = conn) do
    get(conn, Routes.page_path(conn, :index))
  end

  defp setup_with_bypass_and_csrf(%Conn{} = conn) do
    bypass = Bypass.open()
    TestHelpers.set_github_host(bypass, :base_auth_url)
    conn = pass_through_homepage(conn)
    {:ok, bypass: bypass, conn: conn}
  end

  describe "auth_path :index" do
    test "redirects to github", %{conn: conn} do
      TestHelpers.set_github_host(
        :github,
        :base_auth_url
      )

      conn = pass_through_homepage(conn)

      assert %{status: 302, resp_headers: headers} = get(conn, Routes.auth_path(conn, :index))

      assert {:ok, %URI{host: "github.com"}} =
               headers
               |> TestHelpers.get_redirect_uri()
               |> TestHelpers.assert_github_url()
    end
  end

  def auth_create_path_with_params(conn, code) do
    {:ok, {csrf, conn}} = ConnHelpers.get_csrf_token(conn)

    Routes.auth_path(conn, :create,
      code: code,
      state: csrf
    )
  end

  describe "auth_path :create" do
    setup %{conn: conn} do
      setup_with_bypass_and_csrf(conn)
    end

    test "redirects to main page if github returns an access token", %{conn: conn, bypass: bypass} do
      code = "GITHUB_CODE_987654"
      access_token = "GITHUB_ACCESS_TOKEN_12345"

      TestHelpers.bypass_access_token_success(bypass, %{access_token: access_token, code: code})

      assert %{status: 302, resp_headers: headers} =
               get(conn, auth_create_path_with_params(conn, code))

      assert headers
             |> TestHelpers.get_redirect_uri()
             |> URI.to_string() == Routes.dashboard_path(conn, :index, token: access_token)
    end

    test "shows an error if access token request gets denied", %{conn: conn, bypass: bypass} do
      TestHelpers.bypass_access_token_bad_code(bypass)

      assert %{status: 403, resp_body: body} =
               get(conn, auth_create_path_with_params(conn, "BAD_CODE"))

      assert body =~ "Unable to authenticate with GitHub"
    end

    test "returns a :bad_gateway error if code param is missing", %{conn: conn} do
      assert %{status: 502, resp_body: body} = get(conn, Routes.auth_path(conn, :create))
      assert body =~ "Code not received"
    end

    test "returns :service_unavailable error if Github is not responding", %{
      conn: conn,
      bypass: bypass
    } do
      Bypass.down(bypass)

      {result, log} =
        CaptureLog.with_log(fn ->
          get(conn, auth_create_path_with_params(conn, "CODE"))
        end)

      assert %{status: 503, resp_body: body} = result
      assert body =~ "Unable to authenticate with GitHub"
      assert log =~ "error=github_is_down"
      Bypass.up(bypass)
    end

    test "returns :bad_gateway if github returns an unexpected response", %{
      conn: conn,
      bypass: bypass
    } do
      Bypass.expect_once(
        bypass,
        "POST",
        Auth.access_token_endpoint(),
        fn conn_ -> Plug.Conn.resp(conn_, 404, "") end
      )

      {result, log} =
        CaptureLog.with_log(fn -> get(conn, auth_create_path_with_params(conn, "code")) end)

      assert %{status: 502, resp_body: body} = result
      assert body =~ "Unable to authenticate with GitHub"
      assert log =~ "error=unexpected_access_token_response"
      assert log =~ "body="
      assert log =~ "headers="
      assert log =~ "status_code=404"
    end
  end
end
