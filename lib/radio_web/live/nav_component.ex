defmodule RadioWeb.NavComponent do
  use RadioWeb, :live_component

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:open, false)}
  end

  @impl true
  def handle_event("toggle_menu", _, socket) do
    {:noreply, socket |> assign(open: not socket.assigns.open)}
  end

  def menu_class(true), do: "block"
  def menu_class(false), do: "hidden"
end
