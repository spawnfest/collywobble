defmodule Core.PadServer do
  use GenServer

  def start_link(pad_id) do
    GenServer.start_link(__MODULE__, pad_id, name: {:via, Registry, {Registry.Pads, pad_id}})
  end

  def pid_for_pad_id(pad_id) do
    case Registry.lookup(Registry.Pads, pad_id) do
      [{server, _}] ->
        server

      [] ->
        {:ok, pid} = start_link(pad_id)
        pid
    end
  end

  def get_text(pid) do
    GenServer.call(pid, :get_text)
  end

  def get_cursors(pid) do
    GenServer.call(pid, :get_cursors)
  end

  def set_text(pid, text) do
    GenServer.call(pid, {:set_text, text})
  end

  def set_cursor(pid, offset, node) do
    GenServer.call(pid, {:set_cursor, self(), offset, node})
  end

  ## Callbacks

  @impl true
  def init(pad_id) do
    Registry.register(Registry.Pads, pad_id, nil)
    {:ok, {pad_id, "", %{}}}
  end

  @impl true
  def handle_call(:get_text, _from, {pad_id, text, cursors}) do
    {:reply, text, {pad_id, text, cursors}}
  end

  @impl true
  def handle_call(:get_cursors, _from, {pad_id, text, cursors}) do
    {:reply, cursors, {pad_id, text, cursors}}
  end

  @impl true
  def handle_call({:set_text, new_text}, _from, {pad_id, _text, cursors}) do
    Phoenix.PubSub.broadcast(Core.PubSub, pad_id, {:pad_update, new_text})
    {:reply, :ok, {pad_id, new_text, cursors}}
  end

  @impl true
  def handle_call({:set_cursor, view_pid, offset, node}, _from, {pad_id, text, cursors}) do
    new_cursors = cursors |> Map.put(view_pid, %{offset: offset, node: node})
    Phoenix.PubSub.broadcast(Core.PubSub, pad_id, {:cursor_update, new_cursors})
    {:reply, :ok, {pad_id, text, new_cursors}}
  end
end
