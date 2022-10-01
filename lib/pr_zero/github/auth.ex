defmodule PrZero.Github.Auth do
  @type token() :: String.t()
  @type t() :: %__MODULE__{token: token()}
  defstruct [
    :token
  ]
end
