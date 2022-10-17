defmodule PrZero.Github.Repos do
  use PrZero.Github.Aliases

  @mock_file_name_string "repos"

  def mock_file_name("" <> org) do
    [@mock_file_name_string, org]
    |> Enum.join("_")
    |> String.to_atom()
  end

  def mock_file_path() do
    @mock_file_name_string
    |> Github.mock_file_path()
  end

  def mock_file_path("" <> org) do
    org
    |> mock_file_name()
    |> Atom.to_string()
    |> Github.mock_file_path()
  end

  def get("" <> token) do
    get(%User{token: token})
  end

  def get({:ok, %User{} = user}) do
    get(user)
  end

  def get(%User{} = user) do
    user
    |> Orgs.all()
    |> case do
      {:ok, orgs} -> get_org_repos(orgs, {:ok, []}, user)
      {:error, error} -> {:error, error}
    end
  end

  defp get_org_repos([], {:ok, acc}, %User{}), do: {:ok, List.flatten(acc)}

  defp get_org_repos([org | rest], {:ok, acc}, %User{} = user) do
    case do_get_org_repos(org, user) do
      {:ok, repos} -> get_org_repos(rest, {:ok, [repos | acc]}, user)
      {:error, error} -> {:error, error}
    end
  end

  def do_get_org_repos(%Org{repos_url: repos_url, login: name}, %User{} = user) do
    %URI{path: path} = URI.parse(repos_url)

    %URI{path: path}
    |> Github.get(user, mock_file_name(name))
    |> parse_response()
  end

  defp parse_response({:ok, raw}) do
    {:ok, Enum.map(raw, &Repo.new/1)}
  end

  defp parse_response({:error, _} = error) do
    error
  end
end
