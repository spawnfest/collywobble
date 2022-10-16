defmodule Test.Core.PadServerTest do
  use Test.SimpleCase

  setup do: [pad_id: Core.Random.string(10)]

  describe "pid_for_pad_id" do
    test "when there is no GenServer for the pad_id", %{pad_id: pad_id} do
      pid = Core.PadServer.pid_for_pad_id(pad_id)
      assert is_pid(pid)
      GenServer.stop(pid, :normal)
    end

    test "when there is GenServer for the pad_id", %{pad_id: pad_id} do
      {:ok, server} = start_supervised({Core.PadServer, pad_id})
      pid = Core.PadServer.pid_for_pad_id(pad_id)

      assert pid == server
    end
  end

  describe "server state" do
    setup %{pad_id: pad_id} do
      {:ok, server} = start_supervised({Core.PadServer, pad_id})
      [server: server]
    end

    test "starts with empty text", %{server: server} do
      assert Core.PadServer.get_text(server) == ""
    end

    test "starts with empty cursors map", %{server: server} do
      assert Core.PadServer.get_cursors(server) == %{}
    end

    test "sets new text and notifies subscribers", %{pad_id: pad_id, server: server} do
      Phoenix.PubSub.subscribe(Core.PubSub, pad_id)

      Core.PadServer.set_text(server, "Test")
      assert Core.PadServer.get_text(server) == "Test"
      assert_receive {:pad_update, "Test"}
    end

    test "sets new cursor position and notifies subscriber", %{pad_id: pad_id, server: server} do
      Phoenix.PubSub.subscribe(Core.PubSub, pad_id)

      Core.PadServer.set_cursor(server, 1, 2)
      pid = self()
      assert Core.PadServer.get_cursors(server) == %{pid => %{offset: 1, node: 2}}
      assert_receive {:cursor_update, %{^pid => %{offset: 1, node: 2}}}
    end
  end
end
