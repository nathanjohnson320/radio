# Radio

To start your Phoenix server:

  * Setup plex server with some music
  * [Get a plex token](https://support.plex.tv/articles/204059436-finding-an-authentication-token-x-plex-token/)
  * Set the environment variables
    * `PLEX_BASE_VOLUME` : the actual path of the drive on your plex server where files are put
    * `PLEX_MOUNTPOINT` : the path on your local machine where the drive is mounted (only relevant for network drives)
    * `PLEX_TOKEN` : plex token for sing the api
    * `PLEX_BASE_URL` : url for the plex server
  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `npm install` inside the `assets` directory
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
