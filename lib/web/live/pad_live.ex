defmodule Web.PadLive do
  use Web, :live_view

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div test-pad-id={@pad_id}>
      <div>this thing: <%= @pad_id %></div>
    </div>
    """
  end

  @impl Phoenix.LiveView
  def mount(%{"pad_id" => pad_id}, _assigns, socket) do
    socket
    |> assign(page_id: "pad", pad_id: pad_id)
    |> ok()
  end
end
