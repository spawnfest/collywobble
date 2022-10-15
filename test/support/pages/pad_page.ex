defmodule Test.Pages.PadPage do
  import Moar.Assertions
  alias HtmlQuery, as: Hq

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
    page
    |> Pages.update_form("[test-role=pad-form]", :pad, %{text: text})
  end

  @spec assert_text(Pages.Driver.t(), binary()) :: Pages.Driver.t()
  def assert_text(page, text) do
    page
    |> Hq.find!("textarea")
    |> Hq.text()
    |> assert_eq(text, returning: page)
  end
end
