defmodule PrZero.Github.Event.CreatePayload do
  alias PrZero.Github.Event.Payload

  use Payload, keys: [:description, :master_branch, :pusher_type, :ref, :ref_type]

  # def new(%{} = payload) do
  #   payload
  #   |> Enum.map(&parse_value/1)
  #   |> __MODULE__.__struct__()
  # end

  # defp parse_value({"description", description}), do: {:description, description}
end
