defmodule PrZeroWeb.Router do
  use PrZeroWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {PrZeroWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    if Mix.env() in [:dev, :test] do
      plug CORSPlug
    end

    plug :accepts, ["json"]
    plug :fetch_session
    plug PrZeroWeb.Plugs.Token
    plug PrZeroWeb.Plugs.User
  end

  scope "/", PrZeroWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/auth", AuthController, :index
    get "/auth/authorized", AuthController, :create
    get "/dashboard", ReactAppController, :index
    post "/dashboard", ReactAppController, :index
  end

  scope "/api", PrZeroWeb do
    pipe_through :api
    get "/notifications", NotificationsController, :index
    options "/*path", PageController, :options
  end

  # Other scopes may use custom stacks.
  # scope "/api", PrZeroWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/liveview_dashboard", metrics: PrZeroWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
