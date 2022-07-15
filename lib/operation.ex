defmodule Operation do
  use GenServer

  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_cast({:insert, {user, type}}, state) do
    # TODO: send a process to remove a operation after one second
    # Process.send_after()
    {:noreply, [%{user: user, type: type, status: :pending} | state]}
  end

  def insert(user, type) do
    GenServer.cast(__MODULE__, {:insert, user, type})
  end
end
