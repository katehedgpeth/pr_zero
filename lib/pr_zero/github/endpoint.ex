defmodule PrZero.Github.Endpoint do
  alias PrZero.Github

  @type get_return_type ::
          {:ok, list(%{:__struct__ => atom}) | %{:__struct__ => atom}}
          | Github.error_response()
          | {:error, :not_implemented}

  @callback mock_file_path(Map.t()) :: String.t()

  @callback endpoint(Map.t()) :: String.t()

  # &get/1
  @callback get(String.t()) :: get_return_type()
  @callback get(Github.User.t()) :: get_return_type()
  @callback get({:ok, Github.User.t()}) :: get_return_type()
  @callback get(Github.error_response()) :: Github.error_response()

  # &get/2
  @callback get(String.t(), Map.t()) :: get_return_type()
  @callback get(Github.User.t(), Map.t()) :: get_return_type()
  @callback get({:ok, Github.User.t()}, Map.t()) :: get_return_type()
  @callback get(Github.error_response(), Map.t()) :: Github.error_response()

  @optional_callbacks get: 2
end
