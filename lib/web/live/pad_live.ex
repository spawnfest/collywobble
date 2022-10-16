defmodule Web.PadLive do
  use Web, :live_view

  def fetch_text(server) do
    Core.PadServer.get_text(server)
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div test-pad-id={@pad_id}>
      <div>this thing: <%= @pad_id %></div>
      <div id="editable-content" contenteditable="true" phx-update="ignore" phx-hook="ContentEditable"><%= fetch_text(@server) %></div>
    </div>
    """
  end

  @impl Phoenix.LiveView
  def mount(%{"pad_id" => pad_id}, _assigns, socket) do
    server = Core.PadServer.pid_for_pad_id(pad_id)

    Phoenix.PubSub.subscribe(Core.PubSub, pad_id)

    socket
    |> assign(page_id: "pad", pad_id: pad_id, server: server, text: fetch_text(server))
    |> ok()
  end

  @impl Phoenix.LiveView
  def handle_event("edit-pad", %{"text" => text}, socket) do
    Core.PadServer.set_text(socket.assigns.server, text)

    socket
    |> noreply()
  end

  @impl Phoenix.LiveView
  def handle_event("update-cursor", %{"offset" => offset, "node" => node}, socket) do
    Core.PadServer.set_cursor(socket.assigns.server, offset, node)

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
end
