defmodule PrZero.State.Server do
  defmacro __using__(opts) do
    key = Keyword.fetch!(opts, :key)

    quote do
      use GenServer
      alias PrZero.State.{Users, User, Server}

      def add(%{__struct__: _} = resource, "" <> github_token) do
        github_token
        |> get_pid_for_token()
        |> call({:add, resource})
      end

      def all("" <> github_token) do
        github_token
        |> get_pid_for_token()
        |> call(:all)
      end

      def start_link([]) do
        GenServer.start_link(__MODULE__, %{}, [])
      end

      defp call({:ok, pid}, body) do
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
      def init(%{} = initial_value) do
        {:ok, initial_value}
      end

      def handle_call(:all, state) do
        {:reply, state, state}
      end

      def handle_call({:add, %{id: id} = resource}, state) do
        if Map.get(state, id) do
          {:reply, {:error, {:already_exists, id}}, state}
        else
          new_state = Map.put(state, id, resource)
          {:reply, {:ok, new_state}, new_state}
        end
      end
    end
  end
end
