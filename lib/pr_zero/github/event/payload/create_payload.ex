defmodule PrZero.Github.Event.CreatePayload do
  use PrZero.Github.ResponseParser,
    keys: [:description, :master_branch, :pusher_type, :ref, :ref_type]
end
