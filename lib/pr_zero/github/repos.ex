defmodule PrZero.Github.Repos do
  alias PrZero.Github

  alias Github.{
    Orgs,
    Org,
    Repo,
    User
  }

  def all({:ok, %User{} = user}), do: all(user)

  def all(%User{id: user_id, token: token}) do
    %URI{path: endpoint(user_id), query: URI.encode_query(%{type: "member"})}
    |> Github.get(%{token: token})
    |> parse_response()
  end

  def orgs_repos(%User{} = user) do
    user
    |> Orgs.all()
    |> case do
      {:ok, orgs} -> do_orgs_repos(orgs, {:ok, []}, user)
      {:error, error} -> {:error, error}
    end
  end

  defp do_orgs_repos([], {:ok, acc}, %User{}), do: {:ok, List.flatten(acc)}

  defp do_orgs_repos([org | rest], {:ok, acc}, %User{} = user) do
    case org_repos(org, user) do
      {:ok, repos} -> do_orgs_repos(rest, {:ok, [repos | acc]}, user)
      {:error, error} -> {:error, error}
    end
  end

  def org_repos(%Org{repos_url: repos_url}, %User{} = user) do
    repos_url
    |> URI.parse()
    |> Github.get(user)
    |> parse_response()
  end

  defp endpoint(user_id) when is_integer(user_id) do
    "/users/#{user_id}/repos"
  end

  defp parse_response({:ok, raw}) do
    {:ok, Enum.map(raw, &Repo.new/1)}
  end

  defp parse_response({:error, _} = error) do
    error
  end
end
