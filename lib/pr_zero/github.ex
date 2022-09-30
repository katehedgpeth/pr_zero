defmodule PrZero.Github do
  @moduledoc """
  The Github context.
  """

  alias __MODULE__.Auth

  @doc """
  Returns the list of auth.

  ## Examples

      iex> list_auth()
      [%Auth{}, ...]

  """
  def list_auth do
    :not_implemented
  end

  @doc """
  Gets a single auth.

  Raises if the Auth does not exist.

  ## Examples

      iex> get_auth!(123)
      %Auth{}

  """
  def get_auth!(_id), do: :not_implemented

  @doc """
  Creates a auth.

  ## Examples

      iex> create_auth(%{field: value})
      {:ok, %Auth{}}

      iex> create_auth(%{field: bad_value})
      {:error, ...}

  """
  def create_auth(%{} = _attrs) do
    :not_implemented
  end

  @doc """
  Deletes a Auth.

  ## Examples

      iex> delete_auth(auth)
      {:ok, %Auth{}}

      iex> delete_auth(auth)
      {:error, ...}

  """
  def delete_auth(%Auth{}) do
    :not_implemented
  end
end
