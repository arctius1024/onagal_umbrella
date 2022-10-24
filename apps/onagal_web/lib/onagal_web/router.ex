defmodule OnagalWeb.Router do
  use OnagalWeb, :router

  import OnagalWeb.UserAuth

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {OnagalWeb.LayoutView, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(:fetch_current_user)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :graphql do
    # Will be used later
  end

  scope "/", OnagalWeb do
    pipe_through(:browser)

    live_session :default, on_mount: OnagalWeb.RouteAssigns do
      get("/", PageController, :index)
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", OnagalWeb do
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
      pipe_through(:browser)

      live_dashboard("/dashboard", metrics: OnagalWeb.Telemetry)
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through(:browser)

      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end

  ## Authentication routes

  scope "/", OnagalWeb do
    pipe_through([:browser, :redirect_if_user_is_authenticated])

    get("/users/register", UserRegistrationController, :new)
    post("/users/register", UserRegistrationController, :create)
    get("/users/log_in", UserSessionController, :new)
    post("/users/log_in", UserSessionController, :create)
    get("/users/reset_password", UserResetPasswordController, :new)
    post("/users/reset_password", UserResetPasswordController, :create)
    get("/users/reset_password/:token", UserResetPasswordController, :edit)
    put("/users/reset_password/:token", UserResetPasswordController, :update)
  end

  scope "/", OnagalWeb do
    pipe_through([:browser, :require_authenticated_user])

    live_session :user_settings, on_mount: OnagalWeb.RouteAssigns do
      get("/users/settings", UserSettingsController, :edit)
      put("/users/settings", UserSettingsController, :update)
      get("/users/settings/confirm_email/:token", UserSettingsController, :confirm_email)
    end
  end

  scope "/", OnagalWeb do
    pipe_through([:browser])

    delete("/users/log_out", UserSessionController, :delete)
    get("/users/confirm", UserConfirmationController, :new)
    post("/users/confirm", UserConfirmationController, :create)
    get("/users/confirm/:token", UserConfirmationController, :edit)
    post("/users/confirm/:token", UserConfirmationController, :update)
  end

  scope "/gallery", OnagalWeb do
    pipe_through([:browser, :require_authenticated_user])

    live_session :gallery, on_mount: OnagalWeb.RouteAssigns do
      live("/", GalleryLive.Index, :index)
      live("/:id", GalleryLive.Index, :show)

      # live("/show/:id", GalleryLive.Show, :show)
      # live("/:id/info", GalleryLive.Show, :info)
    end
  end

  scope "/api" do
    pipe_through [:graphql, :require_authenticated_user]

    forward "/", Absinthe.Plug, schema: OnagalWeb.Schema
  end

  if Mix.env() == :dev do
    forward "/graphiql", Absinthe.Plug.GraphiQL, schema: OnagalWeb.Schema
  end

  # scope "/admin/settings", OnagalWeb do
  #   pipe_through([:browser, :require_authenticated_user])
  #   #      live_session :admin_settings, on_mount: OnagalWeb.RouteAssigns do
  #   live("/filters", AdminSettingsLive.Index, :filters)
  #   live("/tagsets", AdminSettingsLive.Index, :tagsets)
  #   #      end

  #   scope "/tags", OnagalWeb do
  #     live "/", AdminSettingsLive.TagLive.Index, :index
  #     live "/new", AdminSettingsLive.TagLive.Index, :new
  #     live "/:id/edit", AdminSettingsLive.TagLive.Index, :edit

  #     live "/:id", AdminSettingsLive.TagLive.Show, :show
  #     live "/:id/show/edit", AdminSettingsLive.TagLive.Show, :edit
  #   end
  # end

  scope "/tags", OnagalWeb do
    live "/", TagLive.Index, :index
    live "/new", TagLive.Index, :new
    live "/:id/edit", TagLive.Index, :edit

    live "/:id", TagLive.Show, :show
    live "/:id/show/edit", TagLive.Show, :edit
  end

  scope "/tagsets", OnagalWeb do
    pipe_through([:browser, :require_authenticated_user])

    live_session :tagsets, on_mount: OnagalWeb.RouteAssigns do
      live "/", TagsetLive.Index, :index
      live "/new", TagsetLive.Index, :new
      live "/:id/edit", TagsetLive.Index, :edit

      live "/:id", TagsetLive.Show, :show
      live "/:id/show/edit", TagsetLive.Show, :edit
    end
  end

  scope "/filtersets", OnagalWeb do
    pipe_through([:browser, :require_authenticated_user])

    live_session :filtersets, on_mount: OnagalWeb.RouteAssigns do
      live "/", FiltersetLive.Index, :index
      live "/new", FiltersetLive.Index, :new
      live "/:id/edit", FiltersetLive.Index, :edit

      live "/:id", FiltersetLive.Show, :show
      live "/:id/show/edit", FiltersetLive.Show, :edit
    end
  end
end
