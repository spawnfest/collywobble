defmodule Test.Pages.PadPage do
  import Moar.Assertions
  alias HtmlQuery, as: Hq

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
end
