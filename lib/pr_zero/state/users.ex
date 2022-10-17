defmodule PrZero.State.Users do
  use Agent
  alias PrZero.State.User

  @spec get(String.t()) :: {:ok, User.t()} | :error
  def get("" <> github_token, name \\ __MODULE__) do
    Agent.get(name, Map, :fetch, [github_token])
  end

  def create("" <> github_token, name \\ __MODULE__) do
    github_token
    |> User.new()
    |> add_user(github_token, name)
  end

  def remove("" <> github_token, name \\ __MODULE__) do
    {:ok, %User{} = user} = get(github_token, name)

    case User.stop(user) do
      :ok -> Agent.update(name, Map, :drop, [[github_token]])
      error -> error
    end
  end

  def add_user({:ok, user}, github_token, name \\ __MODULE__) do
    {Agent.update(name, Map, :put, [github_token, user]), user}
  end

  # API

  def start_link(opts) do
    Agent.start_link(fn -> %{} end, opts)
  end
end
