defmodule PrZero.State.Users do
  use Agent
  alias PrZero.Github
  alias PrZero.State.User

  @spec get(String.t()) :: {:ok, User.t()} | :error
  def get("" <> github_token, name \\ __MODULE__) do
    Agent.get(name, Map, :fetch, [github_token])
  end

  def create(user, name \\ __MODULE__)
  def create({:ok, %Github.User{} = user}, name), do: create(user, name)

  def create(%Github.User{} = user, name) do
    user
    |> User.new()
    |> add_user(name)
  end

  def remove("" <> github_token, name \\ __MODULE__) do
    {:ok, %User{} = user} = get(github_token, name)

    case User.stop(user) do
      :ok -> Agent.update(name, Map, :drop, [[github_token]])
      error -> error
    end
  end

  def add_user({:ok, %User{} = user}, name \\ __MODULE__) do
    {Agent.update(name, Map, :put, [user.user_data.token, user]), user}
  end

  # API

  def start_link(opts) do
    Agent.start_link(fn -> %{} end, opts)
  end
end
