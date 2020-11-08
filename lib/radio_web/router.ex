defmodule RadioWeb.Router do
  use RadioWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {RadioWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug RadioWeb.Plug.User
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :cdn do
    plug(:accepts, ["*/*"])
  end

  scope "/", RadioWeb do
    pipe_through(:cdn)

    get("/cdn/*key", ProxyController, :image)
  end

  scope "/", RadioWeb do
    pipe_through :browser

    # live "/artists", ArtistLive.Index, :index
    # live "/artists/new", ArtistLive.Index, :new
    # live "/artists/:id/edit", ArtistLive.Index, :edit
    # live "/artists/:id", ArtistLive.Show, :show
    # live "/artists/:id/show/edit", ArtistLive.Show, :edit

    # live "/albums", AlbumLive.Index, :index
    # live "/albums/new", AlbumLive.Index, :new
    # live "/albums/:id/edit", AlbumLive.Index, :edit

    # live "/albums/:id/show/edit", AlbumLive.Show, :edit

    # live "/songs", SongLive.Index, :index
    # live "/songs/new", SongLive.Index, :new
    # live "/songs/:id/edit", SongLive.Index, :edit
    # live "/songs/:id", SongLive.Show, :show
    # live "/songs/:id/show/edit", SongLive.Show, :edit

    live "/", StationLive.Index, :index
    live "/stations/:id/queue", StationLive.Index, :queue
    live "/stations/new", StationLive.Index, :new
    live "/stations/:id/edit", StationLive.Index, :edit
    live "/stations/:id", StationLive.Index, :show

    get "/stations/:id/stream", AudioController, :index

    # These are a hack until the double mount bug is fixed
    live "/albums/:id", StationLive.Index, :album_show
  end

  # Other scopes may use custom stacks.
  # scope "/api", RadioWeb do
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
      live_dashboard "/dashboard", metrics: RadioWeb.Telemetry
    end
  end
end
