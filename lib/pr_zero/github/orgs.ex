defmodule PrZero.Github.Orgs do
  alias PrZero.Github

  alias Github.{
    Org,
    User
  }

  @endpoint "/user/orgs"

  def all(%User{token: token}) do
    %URI{path: @endpoint}
    |> Github.get(%{token: token})
    |> parse_response()
  end

  defp parse_response({:ok, orgs}) do
    {:ok, Enum.map(orgs, &Org.new/1)}
  end

  defp parse_response(error), do: error
end
