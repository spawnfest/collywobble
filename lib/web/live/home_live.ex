defmodule Web.HomeLive do
  use Web, :live_view

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <.form :let={f} for={:new_pad} phx-submit="create-pad" test-role="new-pad-form">
      <label>
        Create new jump pad with id:
        <%= text_input f, :pad_id %>
      </label>
      <%= submit "Create" %>
    </.form>
    """
  end

  @impl Phoenix.LiveView
  def mount(_params, _assigns, socket) do
    socket
    |> assign(page_id: "home")
    |> ok()
  end

  @impl Phoenix.LiveView
  def handle_event("create-pad", %{"new_pad" => %{"pad_id" => pad_id}}, socket) do
    socket
    |> push_navigate(to: Routes.pad_path(Web.Endpoint, :pad, pad_id))
    |> noreply()
  end
end
