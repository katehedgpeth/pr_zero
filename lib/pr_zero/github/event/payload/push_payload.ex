defmodule PrZero.Github.Event.PushPayload do
  use PrZero.Github.ResponseParser,
    keys: [:commits, :before, :distinct_size, :head, :push_id, :ref, :size]
end
