defmodule Test.Core.PadServerTest do
  use Test.SimpleCase

  describe "pid_for_pad_id" do
    test "when there is no GenServer for the pad_id" do
      pid = Core.PadServer.pid_for_pad_id("test123")
      assert is_pid(pid)
      GenServer.stop(pid, :normal)
    end

    test "when there is GenServer for the pad_id" do
      {:ok, server} = start_supervised({Core.PadServer, "test123"})
      pid = Core.PadServer.pid_for_pad_id("test123")

      assert pid == server
    end
  end

  describe "server state" do
    setup do
      {:ok, server} = start_supervised({Core.PadServer, "pad1"})
      [server: server]
    end

    test "starts with empty text", %{server: server} do
      assert Core.PadServer.get_text(server) == ""
    end

    test "sets new text and notifies subscribers", %{server: server} do
      Phoenix.PubSub.subscribe(Core.PubSub, "pad1")

      Core.PadServer.set_text(server, "Test")
      assert Core.PadServer.get_text(server) == "Test"
      assert_receive {:pad_update, "Test"}
    end
  end
end
