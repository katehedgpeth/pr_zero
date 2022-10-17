defmodule PrZero.State.Server do
  defmacro __using__(opts) do
    key = Keyword.fetch!(opts, :key)
    endpoint = Keyword.fetch!(opts, :github_endpoint)

    quote do
      use GenServer
      require Logger
      alias PrZero.State.{Users, User, Server}
      alias PrZero.Github

      def add(%{__struct__: _} = resource, "" <> github_token) do
        github_token
        |> get_pid_for_token()
        |> call({:add, resource, github_token})
      end

      def all("" <> github_token) do
        github_token
        |> get_pid_for_token()
        |> call({:all, github_token})
      end

      def start_link(opts) do
        GenServer.start_link(__MODULE__, Enum.into(opts, %{}), [])
      end

      defp call({:ok, pid}, body) when is_pid(pid) do
        GenServer.call(pid, body)
      end

      defp get_pid_for_token(github_token) do
        github_token
        |> Users.get()
        |> case do
          {:ok, %User{} = user} ->
            {:ok, Map.fetch!(user, unquote(key))}

          error ->
            error
        end
      end

      # SERVER
      @impl true
      def init(opts) do
        GenServer.cast(self(), {:fetch, opts})
        {:ok, %{}}
      end

      @impl true
      def handle_call({:all, _token}, _from, state) do
        {:reply, Map.values(state), state}
      end

      @impl true
      def handle_call({:add, %{id: id} = resource}, _from, state) do
        if Map.get(state, id) do
          {:reply, {:error, {:already_exists, id}}, state}
        else
          new_state = Map.put(state, id, resource)
          {:reply, {:ok, state}, new_state}
        end
      end

      @impl true
      def handle_cast({:fetch, opts}, state) do
        fetch(opts, state)
      end

      def fetch(%{token: token}, state) do
        token
        |> unquote(endpoint).get()
        |> do_fetch(state)
      end

      defoverridable fetch: 2

      defp do_fetch({:ok, notifications}, state) do
        new =
          notifications
          |> Enum.map(&{&1.id, &1})
          |> Enum.into(%{})

        {:noreply, Map.merge(state, new)}
      end

      defp do_fetch({:error, error}, state) do
        error
        |> to_string()
        |> Logger.warn()

        {:noreply, state}
      end
    end
  end
end
