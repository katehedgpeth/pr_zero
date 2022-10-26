defmodule PrZero.State.Server do
  defstruct next_fetch: Timex.now(), subscribers: [], data: %{}

  @type t() :: %__MODULE__{
          next_fetch: DateTime.t(),
          subscribers: list(pid),
          data: Map.t()
        }

  @type id :: String.t()
  @type token :: String.t()
  @type fetch_opts :: %{:token => String.t(), :repos_pid => pid}

  @callback add(Map.t(), String.t()) :: {:ok, t()} | {:error, {:already_exists, String.t()}}
  @callback subscribe(pid) :: :ok
  @callback subscribers(pid) :: list(pid)
  @callback all(String.t()) :: {:ok, list(struct)} | {:error, {:not_found, token}}
  @callback find(id, token) :: {:ok, struct} | :error
  @callback fetch(fetch_opts, t()) :: t()
  @callback notify_subscribers(t()) :: t()
  @callback get_interval() :: Timex.shift_options()
  @callback start_link([{:token, String.t()} | {atom, any}]) :: GenServer.on_start()

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

      @overrideable fetch: 2, start_link: 1

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
        |> Keyword.get(__MODULE__, hours: 1)
      end

      @impl Server
      def start_link([{:token, _} | _] = opts) do
        GenServer.start_link(__MODULE__, Enum.into(opts, %{}), [])
      end

      def call({:ok, pid}, body, _token) when is_pid(pid) do
        case GenServer.call(pid, body) do
          {:ok, %{} = response} -> {:ok, response}
          {:ok, response} when is_list(response) -> {:ok, response}
          {:error, error} -> error
          :ok -> :ok
          :error -> :error
          %{} = response -> {:ok, response}
          response when is_list(response) -> {:ok, response}
        end
      end

      def call(:error, _body, token) do
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
        {:reply, Map.values(state.data), state}
      end

      def handle_call(:subscribe, {pid, _}, state) do
        {:reply, :ok, Map.update!(state, :subscribers, &[pid | &1])}
      end

      def handle_call(:subscribers, _from, state) do
        {:reply, state.subscribers, state}
      end

      def handle_call({:find, id}, _from, state) do
        response =
          state
          |> Map.fetch!(:data)
          |> Map.fetch(id)

        {:reply, response, state}
      end

      def handle_call({:add, %{id: id} = resource}, _from, state) do
        if Map.get(state.data, id) do
          {:reply, {:error, {:already_exists, id}}, state}
        else
          state = put_in(state, [:data, id], resource)
          {:reply, {:ok, state.data}, state}
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

      @impl Server
      def fetch(%{token: token}, %Server{} = state) do
        token
        |> unquote(endpoint).get()
        |> do_fetch(state)
        |> Map.update!(:next_fetch, &next_fetch_time/1)
      end

      @spec do_fetch({:ok, list(struct)} | {:error, any()}, Server.t()) :: Server.t()
      defp do_fetch({:ok, new_data}, state) when is_list(new_data) do
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
