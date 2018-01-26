defmodule StatushqWeb.Router do
  use StatushqWeb, :router
  use Coherence.Router
  use Plug.ErrorHandler
  import StatushqWeb.Loaders
  import WithPro
  with_pro do: require StatushqProWeb.Router

  defp handle_errors(conn, %{kind: kind, reason: reason, stack: stacktrace}) do
    with_pro do: StatushqProWeb.ErrorReporter.report(conn, kind, reason, stacktrace)
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Coherence.Authentication.Session
  end

  pipeline :protected do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Coherence.Authentication.Session, protected: true
    plug :load_my_pages
    plug :load_invitations
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", StatushqWeb do
    pipe_through :browser
    coherence_routes()
  end

  scope "/", StatushqWeb do
    pipe_through :protected
    coherence_routes(:protected)
  end

  scope "/", StatushqWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/privacy", PageController, :privacy
    get "/terms", PageController, :terms
    resources "/status_pages", StatusPageController, except: [:index], param: "subdomain" do
      resources "/incidents", IncidentController
      post "/subscribe", StatusPageController, :subscribe, as: :subscribe
    end
  end

  pipeline :admin_layout do
    plug :put_layout, {StatushqWeb.Admin.LayoutView, :app}
  end

  scope "/admin", StatushqWeb.Admin, as: :admin do
    pipe_through [:protected, :admin_layout]
    get "/", StatusPageController, :index
    get "/profile", UserController, :edit
    get "/auth/request", AuthController, :request
    get "/auth/callback", AuthController, :callback
    with_pro do: StatushqProWeb.Router.private_routes()
    resources "/status_pages", StatusPageController, param: "subdomain" do
      get "/design", StatusPageController, :design, as: :design
      resources "/services", ServiceController
      resources "/members", UserStatusPageController, name: "members" do
        post "/accept_invite", UserStatusPageController, :accept_invite, as: :accept_invite
        post "/decline_invite", UserStatusPageController, :decline_invite, as: :decline_invite
      end

      resources "/incidents", IncidentController do
        resources "/activities", IncidentActivityController, name: "activity"
      end
    end
  end

  if Mix.env == :dev do
    scope "/dev" do
      pipe_through [:browser]

      forward "/mailbox", Plug.Swoosh.MailboxPreview, [base_path: "/dev/mailbox"]
    end
  end

  get "/", PageController, :index
end
