defmodule Web.PadLive do
  use Web, :live_view

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div test-pad-id={@pad_id}>
      <div>this thing: <%= @pad_id %></div>
      <div id="editable-content" contenteditable="true" phx-update="ignore" phx-hook="ContentEditable"><%= fetch_text(@server) %></div>
      <.link navigate={Routes.home_path(Web.Endpoint, :home)}>go back</.link>
    </div>
    """
  end

  @impl Phoenix.LiveView
  def mount(%{"pad_id" => pad_id}, _assigns, socket) do
    server = Core.PadServer.pid_for_pad_id(pad_id)

    Phoenix.PubSub.subscribe(Core.PubSub, pad_id)

    push_cursors(socket, server)

    socket
    |> assign(local_id: Core.Random.string(4), page_id: "pad", pad_id: pad_id, server: server, text: fetch_text(server))
    |> ok()
  end

  @impl Phoenix.LiveView
  def handle_event("edit-pad", %{"text" => text}, socket) do
    Core.PadServer.set_text(socket.assigns.server, text)

    socket
    |> noreply()
  end

  @impl Phoenix.LiveView
  def handle_event(
        "update-cursor",
        %{"anchor_offset" => anchor_offset, "focus_offset" => focus_offset, "node" => node},
        socket
      ) do
    Core.PadServer.set_cursor(socket.assigns.server, socket.assigns.local_id, anchor_offset, focus_offset, node)

    socket
    |> noreply()
  end

  @impl Phoenix.LiveView
  def handle_info({:pad_update, text}, socket) do
    socket
    |> push_event("updated-content", %{text: text})
    |> noreply()
  end

  @impl Phoenix.LiveView
  def handle_info({:cursor_update, cursors}, socket) do
    other_cursors =
      cursors
      |> Enum.reject(fn {k, _v} -> k == self() end)
      |> Enum.map(fn {_k, v} -> v end)

    socket
    |> push_event("updated-cursors", %{cursors: other_cursors})
    |> noreply()
  end

  ########

  defp fetch_text(server) do
    Core.PadServer.get_text(server)
  end

  defp fetch_cursors(server) do
    Core.PadServer.get_cursors(server)
  end

  defp push_cursors(socket, server) do
    if connected?(socket) do
      send(self(), {:cursor_update, fetch_cursors(server)})
    end
  end
end
