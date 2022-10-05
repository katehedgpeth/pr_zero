defmodule PrZero.Github.Event.PullRequestPayload do
  alias PrZero.Github.Event.Payload
  use Payload, keys: [:action, :before, :number, :pull_request]

  # def new(%{} = payload) do
  #   payload
  #   |> Enum.map(&parse_value/1)
  #   |> __MODULE__.__struct__()
  # end

  # defp parse_value({"", sha}), do: {:before, sha}
end
