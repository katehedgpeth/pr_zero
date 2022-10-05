defmodule PrZeroWeb.DashboardView do
  use PrZeroWeb, :view

  alias PrZero.Github.{
    Notification,
    Repo
  }

  def render_notification(%Notification{
        subject: %Notification.Subject{title: title, url: subject_url},
        updated_at: last_updated,
        unread?: is_unread?,
        reason: reason,
        repo: %Repo{full_name: repo, urls: %{url: repo_url}}
      }) do
    url = String.replace(subject_url, "api.github", "github")

    ~E"""
    <br />
    <br />
    <br />
    <div><a href="<%= url %>"><%= title %></a></div>
    <div>Repo: <a href="<%= repo_url %>"><%= repo %></a></div>
    <div>Reason: <%= reason %></div>
    <div>Is Unread?: <%= is_unread? %></div>
    <div>Last Updated: <%= last_updated %></div>

    """
  end
end
