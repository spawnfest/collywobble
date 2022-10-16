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

      Core.PadServer.set_cursor(server, "from-test-process", 1, 2, 3)
      pid = self()

      assert Core.PadServer.get_cursors(server) == %{
               pid => %{id: "from-test-process", anchor_offset: 1, focus_offset: 2, node: 3}
             }

      assert_receive {:cursor_update, %{^pid => %{id: "from-test-process", anchor_offset: 1, focus_offset: 2, node: 3}}}
    end

    test "monitors client processes", %{pad_id: pad_id, server: server} do
      test_pid = self()

      pid =
        spawn(fn ->
          Process.flag(:trap_exit, true)
          Core.PadServer.set_cursor(server, "from-process", 1, 2, 3)
          send(test_pid, :cursors_set)

          receive do
            _ -> :ok
          end
        end)

      assert_receive :cursors_set

      assert Core.PadServer.get_cursors(server) == %{
               pid => %{id: "from-process", anchor_offset: 1, focus_offset: 2, node: 3}
             }

      Phoenix.PubSub.subscribe(Core.PubSub, pad_id)

      Process.monitor(pid)
      Process.exit(pid, :normal)
      assert_receive {:DOWN, _ref, :process, _pid, :normal}

      assert Core.PadServer.get_cursors(server) == %{}
      empty_map = %{}
      assert_receive {:cursor_update, ^empty_map}
    end
  end
end
