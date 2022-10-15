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
      <.form :let={f} for={:pad} phx-change="edit-pad" test-role="pad-form">
        <%= textarea f, :text, value: @text %>
      </.form>
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
  def handle_event("edit-pad", %{"pad" => %{"text" => text}}, socket) do
    Core.PadServer.set_text(socket.assigns.server, text)

    socket
    |> noreply()
  end

  @impl Phoenix.LiveView
  def handle_info({:pad_update, text}, socket) do
    socket
    |> assign(text: text)
    |> noreply()
  end
end
