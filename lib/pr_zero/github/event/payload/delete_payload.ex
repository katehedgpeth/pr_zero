defmodule PrZero.Github.Event.DeletePayload do
  use PrZero.Github.ResponseParser, keys: [:ref, :pusher_type, :ref_type]
end
