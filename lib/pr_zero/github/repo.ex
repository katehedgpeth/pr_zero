defmodule PrZero.Github.Repo do
  require Logger

  use PrZero.Github.ResponseParser,
    keys: [
      :description,
      :events_url,
      :full_name,
      :html_url,
      :id,
      :is_fork?,
      :is_private?,
      :name,
      :node_id,
      :open_issues,
      :owner,
      :pulls_url,
      :pushed_at,
      :url,
      :visibility
    ],
    skip_keys: [
      :allow_forking,
      :archived,
      :created_at,
      :default_branch,
      :disabled,
      :forks,
      :forks_count,
      :is_template,
      :has_downloads,
      :has_issues,
      :has_pages,
      :has_projects,
      :has_wiki,
      :homepage,
      :language,
      :license,
      :open_issues_count,
      :permissions,
      :size,
      :stargazers_count,
      :topics,
      :updated_at,
      :watchers,
      :watchers_count,
      :web_commit_signoff_required
    ]

  def skip_key?({key, _}) when key in ["events_url", "html_url", "pulls_url"], do: false

  def skip_key?({key, val}) do
    super({key, val}) or String.ends_with?(key, "_url")
  end
end
