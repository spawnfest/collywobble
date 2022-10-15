defmodule Web.PadLiveTest do
  use Test.ConnCase, async: true

  setup do: [pad_id: Core.Random.string(10)]

  describe "pad page" do
    @tag page: [:alice, :bob]
    test "shows one user's change to other user", %{pad_id: pad_id, pages: %{alice: alice_page, bob: bob_page}} do
      alice_page
      |> Test.Pages.PadPage.visit(pad_id: pad_id)
      |> Test.Pages.PadPage.assert_here(id: pad_id)
      |> Test.Pages.PadPage.enter_text("Hello Bob")
      |> Pages.rerender()
      |> Test.Pages.PadPage.assert_text("Hello Bob")

      bob_page
      |> Test.Pages.PadPage.visit(pad_id: pad_id)
      |> Test.Pages.PadPage.assert_here(id: pad_id)
      |> Test.Pages.PadPage.assert_text("Hello Bob")
    end
  end
end
