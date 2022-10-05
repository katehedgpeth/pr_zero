defmodule PrZero.Github.Event.Payload do
  defmacro __using__(keys: keys) do
    actions = [:opened]
    ref_types = [:branch]
    pusher_types = [:user]

    [
      key_strings,
      action_strings,
      ref_type_strings,
      pusher_type_strings
    ] =
      Enum.map([keys, actions, ref_types, pusher_types], fn list ->
        Enum.map(list, &Atom.to_string/1)
      end)

    quote do
      # the keys that are passed to this macro are used to define the struct for the module.
      defstruct unquote(keys)

      # NOTE:
      # Except for a few values that are converted to known atoms, this macro simply converts
      # the key to an atom and passes the value through, unchanged. If there are special keys for a
      # specific payload that should be parsed, define a parse_value/1 function for that key BEFORE
      # calling `use Payload, keys: [...]`
      def new(%{} = payload) do
        payload
        |> Enum.map(&parse_value/1)
        |> __MODULE__.__struct__()
      end

      # NOTE: The following keys are shared by several payload types. You must still specify the key
      # in the keys argument for it to be included in the struct.
      unquote do
        Enum.map(
          [
            {:action, action_strings},
            {:ref_type, ref_type_strings},
            {:pusher_type, pusher_type_strings}
          ],
          fn {key_atom, value_strings} ->
            quote do
              defp parse_value({unquote(Atom.to_string(key_atom)), value_string})
                   when value_string in unquote(value_strings),
                   do: {unquote(key_atom), String.to_atom(value_string)}
            end
          end
        )
      end

      defp parse_value({"action", value}) when value in unquote(action_strings),
        do: {:action, String.to_atom(value)}

      defp parse_value({"ref_type", ref_type}) when ref_type in unquote(ref_type_strings),
        do: {:ref_type, String.to_atom(ref_type)}

      defp parse_value({key, val})
           when key in unquote(key_strings),
           do: {String.to_atom(key), val}
    end
  end
end
