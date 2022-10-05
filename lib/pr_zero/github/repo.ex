defmodule PrZero.Github.Repo do
  alias PrZero.Github.Owner

  defstruct [
    :description,
    :full_name,
    :id,
    :is_fork?,
    :is_private?,
    :name,
    :node_id,
    :owner,
    :urls
  ]

  def new(%{} = api_response) do
    %__MODULE__{
      description: Map.fetch!(api_response, "description"),
      full_name: Map.fetch!(api_response, "full_name"),
      id: Map.fetch!(api_response, "id"),
      is_fork?: Map.fetch!(api_response, "fork"),
      is_private?: Map.fetch!(api_response, "private"),
      name: Map.fetch!(api_response, "name"),
      node_id: Map.fetch!(api_response, "node_id"),
      owner: api_response |> Map.fetch!("owner") |> Owner.new(),
      urls: __MODULE__.Urls.new(api_response)
    }
  end
end
