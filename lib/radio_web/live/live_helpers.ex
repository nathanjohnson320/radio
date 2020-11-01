defmodule RadioWeb.LiveHelpers do
  import Phoenix.LiveView.Helpers

  @doc """
  Renders a component inside the `RadioWeb.ModalComponent` component.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.

  ## Examples

      <%= live_modal @socket, RadioWeb.ArtistLive.FormComponent,
        id: @artist.id || :new,
        action: @live_action,
        artist: @artist,
        return_to: Routes.artist_index_path(@socket, :index) %>
  """
  def live_modal(socket, component, opts) do
    path = Keyword.fetch!(opts, :return_to)
    modal_opts = [id: :modal, return_to: path, component: component, opts: opts]
    live_component(socket, RadioWeb.ModalComponent, modal_opts)
  end
end
