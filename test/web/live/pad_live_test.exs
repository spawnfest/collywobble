defmodule Web.PadLiveTest do
  use Test.ConnCase, async: true

  setup do: [pad_id: Core.Random.string(10)]

  describe "copy link" do
    @tag page: :alice
    test "shows a copy link with the current path", %{pad_id: pad_id, pages: %{alice: alice_page}} do
      alice_page
      |> Test.Pages.PadPage.visit(pad_id: pad_id)
      |> Test.Pages.PadPage.assert_copy_link(pad_id: pad_id)
    end
  end

  describe "pad page" do
    @describetag page: [:alice, :bob]
    test "shows one user's change to other user", %{pad_id: pad_id, pages: %{alice: alice_page, bob: bob_page}} do
      alice_page
      |> Test.Pages.PadPage.visit(pad_id: pad_id)
      |> Test.Pages.PadPage.assert_here(id: pad_id)
      |> Test.Pages.PadPage.enter_text("Hello Bob")
      |> Test.Pages.PadPage.assert_text_sent_to_client("Hello Bob")

      bob_page
      |> Test.Pages.PadPage.visit(pad_id: pad_id)
      |> Test.Pages.PadPage.assert_here(id: pad_id)
      |> Test.Pages.PadPage.assert_text("Hello Bob")
    end

    test "sends cursors to the client", %{pad_id: pad_id, pages: %{alice: alice_page, bob: bob_page}} do
      alice_page =
        alice_page
        |> Test.Pages.PadPage.visit(pad_id: pad_id)
        |> Test.Pages.PadPage.assert_cursors_sent_to_client([])
        |> Test.Pages.PadPage.enter_text("Hello Bob")

      bob_page
      |> Test.Pages.PadPage.visit(pad_id: pad_id)
      |> Test.Pages.PadPage.assert_cursors_sent_to_client([])
      |> Test.Pages.PadPage.set_cursor(1, 2, 3, 4)

      alice_page
      |> Test.Pages.PadPage.assert_cursors_sent_to_client([
        %{anchor_offset: 1, focus_offset: 2, anchor_node: 3, focus_node: 4}
      ])
    end

    test "registers w/ the server and gets notified when other users leave", %{
      pad_id: pad_id,
      pages: %{alice: alice_page, bob: bob_page}
    } do
      alice_page =
        alice_page
        |> Test.Pages.PadPage.visit(pad_id: pad_id)
        |> Test.Pages.PadPage.enter_text("Hello Bob")
        |> Test.Pages.PadPage.set_cursor(1, 2, 3, 4)

      bob_page =
        bob_page
        |> Test.Pages.PadPage.visit(pad_id: pad_id)
        |> Test.Pages.PadPage.assert_cursors_sent_to_client([
          %{anchor_offset: 1, focus_offset: 2, anchor_node: 3, focus_node: 4}
        ])

      Process.exit(alice_page.live.pid, :kill)

      bob_page
      |> Test.Pages.PadPage.assert_cursors_sent_to_client([])
    end
  end
end
