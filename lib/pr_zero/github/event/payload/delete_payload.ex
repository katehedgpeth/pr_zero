defmodule PrZero.Github.Event.DeletePayload do
  use PrZero.Github.Event.Payload, keys: [:ref, :pusher_type, :ref_type]
end
