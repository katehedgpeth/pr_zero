defmodule PrZero.Github.Repo.Urls do
  @type t() :: %__MODULE__{}

  defstruct [
    :archive,
    :assignees,
    :blobs,
    :branches,
    :contributors,
    :collaborators,
    :comments,
    :commits,
    :contents,
    :contributors,
    :compare,
    :deployments,
    :downloads,
    :events,
    :forks,
    :git_commits,
    :git_refs,
    :git_tags,
    :hooks,
    :html,
    :issue_comment,
    :issue_events,
    :issues,
    :keys,
    :labels,
    :languages,
    :merges,
    :milestones,
    :notifications,
    :pulls,
    :releases,
    :stargazers,
    :statuses,
    :subscribers,
    :subscription,
    :tags,
    :teams,
    :trees,
    :url
  ]

  @spec new(Map.t()) :: t()
  def new(%{} = api_response) do
    Kernel.struct!(
      __MODULE__,
      api_response
      |> Enum.reduce([], &keep_if_url_key/2)
      |> Enum.into(%{})
      |> build_kvs_from_api_response()
    )
  end

  defp keep_if_url_key({"url", val}, acc), do: [{"url", val} | acc]

  defp keep_if_url_key({key, val}, acc) do
    if String.ends_with?(key, "_url"), do: [{key, val} | acc], else: acc
  end

  @spec build_kvs_from_api_response(Map.t()) :: Keyword.t()
  def build_kvs_from_api_response(%{} = api_response) do
    %__MODULE__{}
    |> Map.from_struct()
    |> Map.keys()
    |> Enum.reduce({[], api_response}, &get_url/2)
    |> do_build_kvs_from_api_response()
  end

  defp do_build_kvs_from_api_response({keys_vals, %{}}), do: keys_vals

  defp make_api_key(:url), do: "url"

  defp make_api_key(struct_key) when is_atom(struct_key),
    do:
      struct_key
      |> Atom.to_string()
      |> Kernel.<>("_url")

  @spec get_url(atom(), {Keyword.t(), Map.t()}) :: {Keyword.t(), Map.t()}
  defp get_url(key, {acc, %{} = data}) when is_list(acc) do
    data
    |> Map.pop!(make_api_key(key))
    |> do_get_url(key, acc)
  end

  defp do_get_url({value, data}, key, acc), do: {[{key, value} | acc], data}
end
