defmodule MySuperAppWeb.Router do
  use MySuperAppWeb, :router

  import MySuperAppWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {MySuperAppWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", MySuperAppWeb do
    pipe_through :api
    resources "/posts", PostController, only: [:create, :index, :show, :update, :delete]
    resources "/pictures", PictureController, only: [:create, :index, :show, :update, :delete]
    resources "/users", UserController, only: [:create, :index, :show, :update, :delete]
    resources "/roles", RoleController, only: [:create, :index, :show, :update, :delete]
    resources "/sites", SiteController, only: [:create, :index, :show, :update, :delete]
    get "/pictures/by_post/:post_id", PictureController, :by_post
  end

  scope "/", MySuperAppWeb do
    pipe_through :browser

    live("/", HomeLive)
    live("/menu", HomeLiveMenu)
    live("/tabs", HomeLiveTab)
    live("/accordion", HomeLiveAccordion)
    live("/contribution", ContributionPage)
  end

  scope "/", MySuperAppWeb do
    pipe_through [:browser, :require_authenticated_user]
    live("/users", UsersPage)
    live("/permission_error", ErrorPermission)
  end

  scope "/", MySuperAppWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :current_user_blog,
      on_mount: [{MySuperAppWeb.UserAuth, :mount_current_user}] do
      live "/rooms/join/:invite_code", Live.JoinChatRoomView
      live("/chatroom", ChatRoomPage)
      live "/posts", PostLive.Index, :index
      live "/posts/new", PostLive.Index, :new
      live "/posts/:id/edit", PostLive.Index, :edit

      live "/posts/:id", PostLive.Show, :show
      live "/posts/:id/show/edit", PostLive.Show, :edit
    end
  end

  scope "/admin" do
    pipe_through [:browser, :require_authenticated_user, :operator_or_role?]
    live("/", MySuperAppWeb.AdminWelcomePage)
    live("/users", MySuperAppWeb.AdminPage)
    live("/blog", MySuperAppWeb.BlogPage)
    live("/pictures", MySuperAppWeb.PicturesPage)

    scope "/" do
      pipe_through :super_admin_or_operator?
      live("/account-managers", MySuperAppWeb.AccountManagersPage)
      live("/policy", MySuperAppWeb.PolicyPage)
      live("/invited-users", MySuperAppWeb.InvitedUsersPage)
      live("/operators", MySuperAppWeb.OperatorsPage)
    end

    scope "/" do
      pipe_through :operator?
      live("/site-configs", MySuperAppWeb.SiteConfigsPage)
      live("/site-configs/site/:id", MySuperAppWeb.SitePage)
      live("/roles", MySuperAppWeb.RolesPage)
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", MySuperAppWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:my_super_app, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: MySuperAppWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", MySuperAppWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{MySuperAppWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", MySuperAppWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{MySuperAppWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", MySuperAppWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{MySuperAppWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
