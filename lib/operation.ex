defmodule Operation do
  use GenServer

  alias Bank.Helpers

  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_cast({:insert, {user, type}}, state) do
    normalized_user = Helpers.normalize_user(user)
    Process.send_after(self(), {:free_operation, normalized_user}, 1000)
    {:noreply, [%{user: normalized_user, type: type, status: :pending} | state]}
  end

  def handle_call({:get_operations, user}, _from, state) do
    operations = find_operations_by_user(Bank.Helpers.normalize_user(user), state)
    {:reply, operations, state}
  end

  def handle_info({:free_operation, user}, state) do
    operations = find_operations_by_user(user, state)
    state = List.delete_at(operations, length(operations) - 1)
    {:noreply, state}
  end

  def insert(user, type), do: GenServer.cast(__MODULE__, {:insert, {user, type}})

  def get(user), do: GenServer.call(__MODULE__, {:get_operations, user})

  defp find_operations_by_user(user, operations),
    do: Enum.filter(operations, fn %{user: find_user} -> user == find_user end)
end
