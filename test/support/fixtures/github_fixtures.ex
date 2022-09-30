defmodule PrZero.GithubFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PrZero.Github` context.
  """

  @doc """
  Generate a auth.
  """
  def auth_fixture(attrs \\ %{}) do
    {:ok, auth} =
      attrs
      |> Enum.into(%{

      })
      |> PrZero.Github.create_auth()

    auth
  end
end
