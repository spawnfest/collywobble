defmodule Web.PadLiveTest do
  use Test.ConnCase, async: true

  describe "pad page" do
    @tag page: [:alice, :bob]
    test "shows one user's change to other user", %{pages: %{alice: alice_page, bob: bob_page}} do
      alice_page
      |> Test.Pages.PadPage.visit(pad_id: "abc123")
      |> Test.Pages.PadPage.assert_here(id: "abc123")
      |> Test.Pages.PadPage.enter_text("Hello Bob")
      |> Pages.rerender()
      |> Test.Pages.PadPage.assert_text("Hello Bob")

      bob_page
      |> Test.Pages.PadPage.visit(pad_id: "abc123")
      |> Test.Pages.PadPage.assert_here(id: "abc123")
      |> Test.Pages.PadPage.assert_text("Hello Bob")
    end
  end
end
