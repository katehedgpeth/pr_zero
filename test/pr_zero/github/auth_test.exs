defmodule PrZero.AuthTest do
  use PrZero.GithubCase

  @mock_access_token "MOCK_ACCESS_TOKEN_1234567"

  describe "Github.Auth" do
    @tag mock: [User]
    test "get_access_token/1 calls Github and returns an access token", %{bypass: bypass} do
      TestHelpers.bypass_access_token_success(bypass, %{
        code: "CODE_FROM_GITHUB",
        access_token: @mock_access_token
      })

      assert {:ok, %Auth{token: @mock_access_token}} =
               Auth.get_access_token(code: "CODE_FROM_GITHUB", cookie: "COOKIE")
    end

    @tag mock: [User]
    test "get_access_token/1 returns error tuple if verification code is denied",
         %{bypass: bypass} do
      TestHelpers.bypass_access_token_bad_code(bypass)

      assert Auth.get_access_token(code: "BAD_CODE", cookie: "COOKIE") ==
               {:error, {:bad_verification_code, "BAD_CODE"}}
    end

    @tag mock: [User]
    test "get_access_token/1 returns error tuple if service is down", %{bypass: bypass} do
      Bypass.down(bypass)

      assert Auth.get_access_token(code: "CODE_FROM_GITHUB", cookie: "COOKIE") ==
               {:error, %HTTPoison.Error{reason: :econnrefused}}

      Bypass.up(bypass)
    end

    @tag mock: [User]
    test "base_uri/0 returns the base_uri", %{bypass: %Bypass{port: port}} do
      assert Auth.base_auth_uri() == %URI{
               scheme: "http",
               host: "localhost",
               port: port,
               authority: "localhost:#{port}"
             }
    end
  end
end
