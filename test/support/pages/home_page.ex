defmodule Test.Pages.HomePage do
  import Moar.Assertions
  alias HtmlQuery, as: Hq

  @spec assert_here(Pages.Driver.t()) :: Pages.Driver.t()
  def assert_here(page) do
    page
    |> Hq.find!("[data-page]")
    |> Hq.attr("data-page")
    |> assert_eq("home", returning: page)
  end

  @spec create_new_pad(Pages.Driver.t(), id: binary()) :: Pages.Driver.t()
  def create_new_pad(page, id: pad_id) do
    page
    |> Pages.submit_form([test_role: "new-pad-form"], :new_pad, %{
      pad_id: pad_id
    })
  end

  @spec visit(Pages.Driver.t()) :: Pages.Driver.t()
  def visit(page),
    do: page |> Pages.visit("/")
end
