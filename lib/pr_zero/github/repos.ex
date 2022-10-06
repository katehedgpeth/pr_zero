defmodule PrZero.Github.Repos do
  use PrZero.Github.Aliases

  def all(%User{} = user) do
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

  def do_get_org_repos(%Org{repos_url: repos_url}, %User{} = user) do
    repos_url
    |> URI.parse()
    |> Github.get(user)
    |> parse_response()
  end

  defp parse_response({:ok, raw}) do
    {:ok, Enum.map(raw, &Repo.new/1)}
  end

  defp parse_response({:error, _} = error) do
    error
  end
end
