defmodule Web.HomeLiveTest do
  use Test.ConnCase, async: true

  describe "home page" do
    @tag page: :alice
    test "show a link to create a new jump pad", %{pages: %{alice: page}} do
      page
      |> Test.Pages.HomePage.visit()
      |> Test.Pages.HomePage.assert_here()
      |> Test.Pages.HomePage.create_new_pad(id: "abc123")
      |> Test.Pages.PadPage.assert_here(id: "abc123")
    end
  end
end
