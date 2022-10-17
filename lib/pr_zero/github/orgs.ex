defmodule PrZero.Github.Orgs do
  alias PrZero.Github

  alias Github.{
    Org,
    User
  }

  @endpoint "/user/orgs"
  @mock_file_name :orgs

  def endpoint(_ \\ nil), do: @endpoint

  def mock_file_path() do
    @mock_file_name
    |> Atom.to_string()
    |> Github.mock_file_path()
  end

  def all(%User{token: token}) do
    %URI{path: @endpoint}
    |> Github.get(%{token: token}, @mock_file_name)
    |> parse_response()
  end

  defp parse_response({:ok, orgs}) do
    {:ok, Enum.map(orgs, &Org.new/1)}
  end

  defp parse_response(error), do: error
end
