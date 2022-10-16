defmodule Core.PadServer do
  use GenServer

  defstruct [:pad_id, text: "", cursors: %{}]

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
    {:ok, __struct__(pad_id: pad_id)}
  end

  @impl true
  def handle_call(:get_text, _from, %{text: text} = state) do
    {:reply, text, state}
  end

  @impl true
  def handle_call(:get_cursors, _from, %{cursors: cursors} = state) do
    {:reply, cursors, state}
  end

  @impl true
  def handle_call({:set_text, new_text}, _from, state) do
    Phoenix.PubSub.broadcast(Core.PubSub, state.pad_id, {:pad_update, new_text})
    {:reply, :ok, %{state | text: new_text}}
  end

  @impl true
  def handle_call({:set_cursor, view_pid, offset, node}, _from, state) do
    new_cursors = state.cursors |> Map.put(view_pid, %{offset: offset, node: node})
    Phoenix.PubSub.broadcast(Core.PubSub, state.pad_id, {:cursor_update, new_cursors})

    Process.monitor(view_pid)

    {:reply, :ok, %{state | cursors: new_cursors}}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, pid, _reason}, state) do
    new_cursors = state.cursors |> Map.delete(pid)
    Phoenix.PubSub.broadcast(Core.PubSub, state.pad_id, {:cursor_update, new_cursors})
    {:noreply, %{state | cursors: new_cursors}}
  end
end
