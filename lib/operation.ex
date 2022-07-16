defmodule Operation do
  use GenServer

  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_cast({:insert, {user, type}}, state) do
    Process.send_after(self(), {:free_operation, user}, 1000)
    {:noreply, [%{user: user, type: type, status: :pending} | state]}
  end

  def handle_info({:free_operation, user}, state) do
    operations = find_operations_by_user(user, state)
    state = List.delete_at(operations, length(operations) - 1)
    {:noreply, state}
  end

  def insert(user, type) do
    GenServer.cast(__MODULE__, {:insert, user, type})
  end

  defp find_operations_by_user(user, operations),
    do: Enum.filter(operations, fn %{user: find_user} -> user == find_user end)
end
