defmodule PrZero.Github.User.Urls do
  @type t() :: %__MODULE__{
          events: String.t(),
          following: String.t(),
          orgs: String.t(),
          received_events: String.t()
        }

  defstruct [
    :events,
    :following,
    :orgs,
    :received_events
  ]
end
