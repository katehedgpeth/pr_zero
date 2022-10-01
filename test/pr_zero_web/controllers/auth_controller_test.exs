defmodule PrZeroWeb.AuthControllerTest do
  use PrZeroWeb.ConnCase
  alias ExUnit.CaptureLog
  alias PrZero.Github

  defp setup_with_bypass_and_csrf(%Plug.Conn{} = conn) do
    bypass = Bypass.open()
    TestHelpers.set_github_host(bypass)
    conn = get(conn, Routes.page_path(conn, :index))
    {:ok, bypass: bypass, conn: conn}
  end

  describe "auth_path :index" do
    test "redirects to github", %{conn: conn} do
      TestHelpers.set_github_host(%URI{
        scheme: "https",
        host: "github.com"
      })

      assert %{status: 302, resp_headers: headers} = get(conn, Routes.auth_path(conn, :index))

      assert {:ok, %URI{host: "github.com"}} =
               headers
               |> TestHelpers.get_redirect_uri()
               |> TestHelpers.assert_github_url()
    end
  end

  describe "github_oauthorize_url" do
    setup %{conn: conn} do
      setup_with_bypass_and_csrf(conn)
    end

    test "returns the expected URL as a string", %{bypass: bypass, conn: conn} do
      assert {:ok, %URI{host: "localhost"}} =
               conn
               |> PrZeroWeb.AuthController.github_oauthorize_url("CSRF123456")
               |> URI.parse()
               |> TestHelpers.assert_github_url(bypass)
    end
  end

  def auth_create_path_with_params(conn, code) do
    Routes.auth_path(conn, :create,
      code: code,
      state: PrZeroWeb.AuthController.get_csrf_token(conn)
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
             |> URI.to_string() == Routes.page_path(conn, :index, token: access_token)
    end

    test "shows an error if access token request gets denied", %{conn: conn, bypass: bypass} do
      TestHelpers.bypass_access_token_bad_code(bypass)

      assert %{status: 403, resp_body: body} =
               get(conn, auth_create_path_with_params(conn, "BAD_CODE"))

      assert body =~ "Unable to authenticate with GitHub"
    end

    test "redirects to auth index if code param is missing", %{conn: conn} do
      assert %{status: 302, resp_headers: headers} = get(conn, Routes.auth_path(conn, :create))

      assert headers
             |> TestHelpers.get_redirect_uri()
             |> URI.to_string() == Routes.auth_path(conn, :index)
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
        Github.access_token_endpoint(),
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
