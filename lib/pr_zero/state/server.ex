defmodule PrZero.State.Server do
  defstruct next_fetch: Timex.now(), subscribers: [], data: %{}

  @type t() :: %__MODULE__{
          next_fetch: DateTime.t(),
          subscribers: list(pid),
          data: Map.t()
        }

  @type id :: String.t()
  @type token :: String.t()

  @callback add(Map.t(), String.t()) :: {:ok, t()} | {:error, {:already_exists, String.t()}}
  @callback subscribe(pid) :: :ok
  @callback subscribers(pid) :: list(pid)
  @callback all(String.t()) :: {:ok, list(struct)} | {:error, {:not_found, token}}
  @callback find(id, token) :: {:ok, struct} | :error
  @callback fetch(Map.t(), t()) :: t()
  @callback notify_subscribers(t()) :: t()
  @callback get_interval() :: Timex.shift_options()

  defmacro __using__(opts) do
    key = Keyword.fetch!(opts, :key)
    endpoint = Keyword.fetch!(opts, :github_endpoint)

    quote do
      use GenServer
      require Logger
      alias PrZero.State.{Users, User, Server}
      alias PrZero.Github

      @behaviour Server

      @fetch_interval hours: 1

      @overrideable fetch: 2

      @impl Server
      def add(%{__struct__: _} = resource, "" <> github_token) do
        github_token
        |> get_pid_for_token()
        |> call({:add, resource}, github_token)
      end

      @impl Server
      def all("" <> github_token) do
        github_token
        |> get_pid_for_token()
        |> call(:all, github_token)
      end

      @impl Server
      def find(id, "" <> github_token) do
        github_token
        |> get_pid_for_token()
        |> call({:find, id}, github_token)
      end

      @impl Server
      def subscribe(pid) when is_pid(pid) do
        GenServer.call(pid, :subscribe)
      end

      @impl Server
      def subscribers(pid) when is_pid(pid) do
        GenServer.call(pid, :subscribers)
      end

      @impl Server
      def get_interval() do
        :pr_zero
        |> Application.get_env(:fetch_intervals)
        |> Keyword.fetch!(__MODULE__)
      end

      def start_link(opts) do
        GenServer.start_link(__MODULE__, Enum.into(opts, %{}), [])
      end

      defp call({:ok, pid}, body, _token) when is_pid(pid) do
        {:ok, GenServer.call(pid, body)}
      end

      defp call(:error, _body, token) do
        {:error, {:not_found, token}}
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

      defp next_fetch_time(%DateTime{} = previous) do
        previous
        |> Timex.shift(get_interval())
      end

      ######################################################
      ######################################################
      # GENSERVER
      @impl GenServer
      def init(opts) do
        GenServer.cast(self(), {:fetch, opts})

        {:ok, %PrZero.State.Server{}}
      end

      @impl GenServer
      def handle_call(:all, _from, state) do
        {:reply, Map.values(state), state}
      end

      def handle_call(:subscribe, {pid, _}, state) do
        {:reply, :ok, Map.update!(state, :subscribers, &[pid | &1])}
      end

      def handle_call(:subscribers, _from, state) do
        {:reply, state.subscribers, state}
      end

      def handle_call({:find, id}, _from, state) do
        {:reply, Map.fetch(state, id), state}
      end

      def handle_call({:add, %{id: id} = resource}, _from, state) do
        if Map.get(state, id) do
          {:reply, {:error, {:already_exists, id}}, state}
        else
          new_state = Map.put(state, id, resource)
          {:reply, {:ok, state}, new_state}
        end
      end

      @impl GenServer
      def handle_cast({:fetch, opts}, state) do
        updated_state =
          case DateTime.compare(Timex.now(), state.next_fetch) do
            :lt ->
              state

            _ ->
              opts
              |> fetch(state)
              |> notify_subscribers()
          end

        GenServer.cast(self(), {:fetch, opts})

        {:noreply, updated_state}
      end

      @impl Server
      def notify_subscribers(%Server{} = state) do
        Enum.each(state.subscribers, &send(&1, {:updated_data, Map.values(state.data)}))
        state
      end

      ######################################################
      ######################################################
      # OVERRIDEABLE FUNCTIONS

      @spec fetch(Map.t(), Server.t()) :: Server.t()
      @impl Server
      def fetch(%{token: token}, %Server{} = state) do
        token
        |> unquote(endpoint).get()
        |> do_fetch(state)
        |> Map.update!(:next_fetch, &next_fetch_time/1)
      end

      @spec do_fetch({:ok, list(struct)} | {:error, any()}, Server.t()) :: Server.t()
      defp do_fetch({:ok, new_data}, state) do
        Map.update!(state, :data, fn old_data ->
          Map.merge(
            old_data,
            new_data
            |> Enum.map(&{&1.id, &1})
            |> Enum.into(%{})
          )
        end)
      end

      defp do_fetch({:error, error}, state) do
        error
        |> to_string()
        |> Logger.warn()

        state
      end

      defoverridable @overrideable
    end
  end
end
