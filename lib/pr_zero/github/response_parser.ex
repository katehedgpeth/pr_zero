defmodule PrZero.Github.ResponseParser do
  @callback reject_key?({key :: String.t(), val :: any()}) :: boolean()
  @optional_callbacks [reject_key?: 1]

  use PrZero.Github.Aliases
  # NOTE: The following keys are shared by several payload types. You must still specify the key
  # in the `keys` argument of `use ResponseParser` for the key to be included in the struct.
  @known_values [
    action: [:created],
    author_association: %{
      "CONTRIBUTOR" => :contributor,
      "COLLABORATOR" => :collaborator,
      "FIRST_TIME_CONTRIBUTOR" => :first_time_contributor,
      "MEMBER" => :member,
      "NONE" => :none
    },
    org: &Org.new/1,
    owner: &Owner.new/1,
    pusher_type: [:type],
    reason: [
      :subscribed,
      :comment,
      :mention,
      :review_requested
    ],
    ref_type: [:type],
    type: %{
      # event types
      "CreateEvent" => :create,
      "DeleteEvent" => :delete,
      "IssueCommentEvent" => :issue_comment,
      "PullRequestEvent" => :pull_request,
      "PullRequestReviewCommentEvent" => :pull_request_review_comment,
      "PushEvent" => :push,

      # user types
      "User" => :user,
      "Bot" => :bot,

      # owner types
      "Organization" => :organization,

      # notification subject types
      "PullRequest" => :pull_request,
      "Release" => :release
    },
    state: [:open],
    subject: &Notification.Subject.new/1,
    user: &User.new/1
  ]

  def parse_datetime(nil), do: nil

  def parse_datetime("" <> datetime), do: NaiveDateTime.from_iso8601!(datetime)

  defmacro __using__(args) do
    keys = Keyword.fetch!(args, :keys)

    skipped_keys =
      args
      |> Keyword.get(:skip_keys, [])
      |> Enum.map(&Atom.to_string/1)
      |> MapSet.new()
      |> Macro.escape()

    encoder =
      args
      |> Keyword.get(:encoded_keys)
      |> case do
        [] -> Jason.Encoder
        encoded_keys -> {Jason.Encoder, only: encoded_keys}
      end

    quote do
      @behaviour unquote(__MODULE__)
      @derive unquote(encoder)
      use PrZero.Github.Aliases

      import unquote(__MODULE__), only: [parse_datetime: 1]

      # The keys that are passed to this macro are used to define the struct for the module.
      defstruct unquote(keys)

      def skip_key?({key, _val}) do
        MapSet.member?(unquote(skipped_keys), key)
      end

      def post_new(module), do: module

      defoverridable skip_key?: 1, post_new: 1

      @spec new(Map.t()) :: %__MODULE__{}
      def new(%{} = payload) do
        payload
        |> Enum.reject(&skip_key?/1)
        |> Enum.map(&parse_value/1)
        |> Enum.into(%{})
        |> __MODULE__.__struct__()
        |> post_new()
      end

      defp post_new(%__MODULE__{} = struct), do: struct

      unquote do
        for key_atom <- keys do
          key_string = Atom.to_string(key_atom)

          fetched =
            @known_values
            |> Keyword.fetch(key_atom)
            |> case do
              {:ok, [atom | _] = value_atoms} when is_atom(atom) ->
                {:ok,
                 value_atoms
                 |> Enum.map(&{Atom.to_string(&1), &1})
                 |> Enum.into(%{})}

              fetched_ ->
                fetched_
            end

          configs =
            case {key_atom, String.reverse(key_string), fetched} do
              {:repo, _, _} ->
                [
                  %{key_string: "repo", parser: &Repo.new/1},
                  %{key_string: "repository", parser: &Repo.new/1}
                ]

              {:active_lock_reason, _, _} ->
                # I'm sure this is a known list of values, but I don't know what they are at the moment
                %{value_match: nil, value_atom: nil}

              {_, "?" <> _, _} ->
                %{
                  key_string:
                    key_string
                    |> String.replace_prefix("is_", "")
                    |> String.replace_suffix("?", "")
                }

              # keys ending in _at are always DateTimes
              {_, "ta_" <> _, _} ->
                %{
                  parser: &__MODULE__.parse_datetime/1
                }

              {_, _, {:ok, func}} when is_function(func) ->
                %{parser: func}

              {_, _, {:ok, %{} = mapped_values}} ->
                Enum.map(mapped_values, &%{value_match: elem(&1, 0), value_atom: elem(&1, 1)})

              {_, _, :error} ->
                %{}
            end

          for config <- List.flatten([configs]) do
            %{
              key_string: key_string,
              value_match: nil,
              value_atom: nil,
              parser: nil
            }
            |> Map.merge(config)
            |> case do
              # if the only thing specified is the key_string, then we are simply renaming the key
              # and passing the raw value through.
              %{value_atom: nil, value_match: nil, parser: nil, key_string: "" <> _ = key_string} ->
                quote do
                  defp parse_value({unquote(key_string), raw}), do: {unquote(key_atom), raw}
                end

              %{
                value_atom: nil,
                value_match: nil,
                parser: parser,
                key_string: key_string
              }
              when is_function(parser) ->
                # If there is a parser, then we pass the raw value to the parser.
                quote do
                  defp parse_value({unquote(key_string), raw}),
                    do: {unquote(key_atom), unquote(parser).(raw)}
                end

              %{
                value_match: "" <> value_match,
                value_atom: value_atom,
                parser: nil,
                key_string: key_string
              }
              when is_atom(value_atom) ->
                # if there is specific value we are matching, then it is being turned into a known
                # atom, so there is no parser.
                quote do
                  defp parse_value({unquote(key_string), unquote(value_match)}),
                    do: {unquote(key_atom), unquote(value_atom)}
                end
            end
          end
        end
      end
    end
  end
end
