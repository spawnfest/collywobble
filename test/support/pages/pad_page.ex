defmodule Test.Pages.PadPage do
  import ExUnit.Assertions
  import Moar.Assertions
  alias HtmlQuery, as: Hq
  require Phoenix.LiveViewTest

  @spec visit(Pages.Driver.t(), pad_id: binary) :: Pages.Driver.t()
  def visit(page, pad_id: pad_id),
    do: page |> Pages.visit("/pad/#{pad_id}")

  @spec assert_here(Pages.Driver.t(), id: binary()) :: Pages.Driver.t()
  def assert_here(page, id: pad_id) do
    page
    |> Hq.find!("[data-page]")
    |> Hq.attr("data-page")
    |> assert_eq("pad", returning: page)
    |> Hq.find!("[test-pad-id]")
    |> Hq.attr("test-pad-id")
    |> assert_eq(pad_id, returning: page)
  end

  @spec enter_text(Pages.Driver.t(), binary()) :: Pages.Driver.t()
  def enter_text(page, text) do
    rendered =
      page.live
      |> Phoenix.LiveViewTest.render_hook("edit-pad", %{text: text})

    Pages.Driver.LiveView.new(page.conn, {:ok, page.live, rendered})
  end

  @spec assert_text(Pages.Driver.t(), binary()) :: Pages.Driver.t()
  def assert_text(page, text) do
    page
    |> Hq.find!("#editable-content")
    |> Hq.text()
    |> assert_eq(text, returning: page)
  end

  @spec assert_text_sent_to_client(Pages.Driver.t(), binary()) :: Pages.Driver.t()
  def assert_text_sent_to_client(page, text) do
    page.live
    |> Phoenix.LiveViewTest.assert_push_event("updated-content", %{text: ^text})

    page
  end
end
