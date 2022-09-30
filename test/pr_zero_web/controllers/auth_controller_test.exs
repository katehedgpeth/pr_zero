defmodule PrZeroWeb.AuthControllerTest do
  use PrZeroWeb.ConnCase

  import PrZero.GithubFixtures

  alias PrZero.Github.Auth

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create auth" do
    test "renders auth when data is valid", %{conn: conn} do
      conn = post(conn, Routes.auth_path(conn, :create), auth: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.auth_path(conn, :show, id))

      assert %{
               "id" => ^id
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.auth_path(conn, :create), auth: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete auth" do
    setup [:create_auth]

    test "deletes chosen auth", %{conn: conn, auth: auth} do
      conn = delete(conn, Routes.auth_path(conn, :delete, auth))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.auth_path(conn, :show, auth))
      end
    end
  end

  defp create_auth(_) do
    auth = auth_fixture()
    %{auth: auth}
  end
end
