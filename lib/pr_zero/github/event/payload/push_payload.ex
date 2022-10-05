defmodule PrZero.Github.Event.PushPayload do
  use PrZero.Github.Event.Payload,
    keys: [:commits, :before, :distinct_size, :head, :push_id, :ref, :size]
end
