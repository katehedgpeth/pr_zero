defmodule PrZero.Github.Orgs do
  alias PrZero.Github

  alias Github.{
    Org,
    User
  }

  @behaviour Github.Endpoint

  @endpoint "/user/orgs"
  @mock_file_name :orgs

  @impl Github.Endpoint
  def endpoint(_ \\ nil), do: @endpoint

  @impl Github.Endpoint
  def mock_file_path(_ \\ nil) do
    @mock_file_name
    |> Atom.to_string()
    |> Github.mock_file_path()
  end

  @impl Github.Endpoint
  def get(%User{token: token}) do
    %URI{path: @endpoint}
    |> Github.get(%{token: token}, @mock_file_name)
    |> parse_response()
  end

  defp parse_response({:ok, orgs}) do
    {:ok, Enum.map(orgs, &Org.new/1)}
  end

  defp parse_response(error), do: error
end
