defmodule PrZero.Github.NotificationsTest do
  use ExUnit.Case

  alias PrZero.Github.{
    User,
    Notifications,
    Notification,
    Owner,
    Repo,
    Notification.Subject
  }

  describe "Notifications.get/1" do
    setup do
      TestHelpers.set_github_host(:github)
      {:ok, token: TestHelpers.get_test_token()}
    end

    test "returns a list of notifications", %{token: token} do
      {:ok, user} = User.get(token: token)
      assert {:ok, notifications} = Notifications.get(user)
      assert length(notifications) == 50
      Enum.each(notifications, &validate_notification/1)
    end

    defp validate_notification(%Notification{
           id: id,
           last_read_at: last_read_at,
           reason: reason,
           repo: repo,
           subject: subject,
           subscription_url: subscription_url,
           unread?: unread?,
           updated_at: updated_at,
           url: url
         }) do
      assert String.to_integer(id)
      validate_last_read_at(last_read_at)
      validate_reason(reason)

      assert is_url?({:subscription_url, subscription_url})

      assert is_boolean(unread?)
      assert %NaiveDateTime{} = updated_at
      assert is_url?({:url, url})

      validate_repo(repo)
      validate_subject(subject)
    end

    defp validate_last_read_at(nil), do: true
    defp validate_last_read_at(%NaiveDateTime{}), do: true

    defp validate_reason(:subscribed), do: true
    defp validate_reason(:comment), do: true

    defp validate_subject(%Subject{
           latest_comment_url: latest_comment_url,
           title: "" <> _,
           type: type,
           url: url
         }) do
      assert is_optional_url?({:latest_comment_url, latest_comment_url})
      assert is_url?({:url, url})
      assert validate_subject_type(type)
    end

    defp validate_subject_type(:pull_request), do: true

    defp validate_repo(
           %Repo{
             full_name: full_name,
             id: id,
             is_fork?: is_fork?,
             is_private?: is_private?,
             name: "" <> _ = name,
             node_id: "" <> _,
             owner: owner,
             urls: urls
           } = repo
         )
         when is_integer(id) and is_boolean(is_fork?) and is_boolean(is_private?) do
      assert [_, ^name] = String.split(full_name, "/")
      validate_repo_owner(owner)

      validate_repo_description(repo)
      validate_repo_urls(urls)
    end

    defp validate_repo_description(%Repo{description: nil}), do: true
    defp validate_repo_description(%Repo{description: "" <> _}), do: true

    defp validate_repo_urls(%Repo.Urls{} = urls) do
      assert urls
             |> Map.from_struct()
             |> Enum.all?(&is_url?/1)
    end

    defp validate_repo_owner(%Owner{
           avatar_url: "https://" <> _,
           events_url: "https://" <> _,
           followers_url: "https://" <> _,
           following_url: "https://" <> _,
           gists_url: "https://" <> _,
           gravatar_id: "" <> _,
           html_url: "https://" <> _,
           id: id,
           login: "" <> _,
           node_id: "" <> _,
           organizations_url: "https://" <> _,
           received_events_url: "https://" <> _,
           is_site_admin?: false,
           repos_url: "https://" <> _,
           starred_url: "https://" <> _,
           subscriptions_url: "https://" <> _,
           type: type,
           url: "https://" <> _
         })
         when is_integer(id) do
      validate_organization_type(type)
      true
    end

    defp validate_organization_type(:org), do: true

    defp is_url?({key, "https://api.github.com/" <> _}) when is_atom(key), do: true
    defp is_url?({key, "https://github.com/" <> _}) when is_atom(key), do: true

    defp is_optional_url?({key, nil}) when is_atom(key), do: true
    defp is_optional_url?(tuple), do: is_url?(tuple)
  end
end
