defmodule Bank do
  use GenServer

  alias Bank.Helpers

  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(_) do
    :ets.new(:users, [:set, :public, :named_table])
    :ets.new(:operations, [:duplicate_bag, :public, :named_table])
    {:ok, "Generated tables in-memory"}
  end

  @doc """
    Insert user into ets in-memory table
    if user exists, return tuple error
  """
  def create_user(user) do
    case get_user(user) do
      nil ->
        normalized_user = Helpers.normalize_user(user)
        :ets.insert(:users, {normalized_user, %{brl: Helpers.normalize_amount(0.0)}})
        get_user(normalized_user)

      _ ->
        {:error, :user_already_exists}
    end
  end

  @doc """
    Deposit a value into user
    if user does not exists will return a tuple error
  """
  def deposit(user, amount, currency) do
    case {get_user(user), check_operations(user, :normal)} do
      {nil, 0} ->
        {:error, :user_does_not_exist}

      {_, operations} when operations >= 10 ->
        {:error, :too_many_requests_to_user}

      {{user, balances}, operations} when operations < 10 ->
        normalized_currency = Helpers.normalize_currency(currency)

        Operation.insert(user, "deposit")
        apply_deposit(user, balances, normalized_currency, amount)
    end
  end

  @doc """
    Withdraw a value into user
    if user does not exists will return a tuple error
    if user has no not_enough_money will return a tuple error
  """
  def withdraw(user, amount, currency) do
    case {get_user(user), check_operations(user, :normal)} do
      {nil, 0} ->
        {:error, :user_does_not_exist}

      {_, operations} when operations >= 10 ->
        {:error, :too_many_requests_to_user}

      {{user, balances}, operations} when operations < 10 ->
        normalized_currency = Helpers.normalize_currency(currency)

        Operation.insert(user, "withdraw")
        apply_withdraw(user, balances, normalized_currency, amount)
    end
  end

  @doc """
    Get the user balance
    if user does not exist will return a tuple error
  """
  def get_balance(user, currency) do
    case {get_user(user), check_operations(user, :normal)} do
      {nil, 0} ->
        {:error, :user_does_not_exist}

      {_, operations} when operations >= 10 ->
        {:error, :too_many_requests_to_user}

      {{_user, balances}, operations} when operations < 10 ->
        normalized_currency = Helpers.normalize_currency(currency)
        Operation.insert(user, "get_balance")
        {:ok, Map.get(balances, normalized_currency, 0) |> Helpers.normalize_amount()}
    end
  end

  @doc """
    Send an amount in currency from an user to another
  """
  def send(from_user, to_user, amount, currency) do
    case {get_user(from_user), get_user(to_user)} do
      {nil, _} ->
        {:error, :sender_does_not_exist}

      {_, nil} ->
        {:error, :receiver_does_not_exist}

      {_, _} ->
        apply_transfer(from_user, to_user, amount, currency)
    end
  end

  defp apply_transfer(from_user, to_user, amount, currency) do
    case withdraw(from_user, amount, currency) do
      {:error, :too_many_requests_to_user} ->
        {:error, :too_many_requests_to_sender}

      {:error, :not_enough_money} ->
        {:error, :not_enough_money}

      {:ok, from_user_balance} ->
        deposit_to_receiver(from_user_balance, to_user, amount, currency)
    end
  end

  defp deposit_to_receiver(from_user_balance, user, amount, currency) do
    case deposit(user, amount, currency) do
      {:error, :too_many_requests_to_user} ->
        {:error, :too_many_requests_to_receiver}

      {:ok, to_user_balance} ->
        {:ok, from_user_balance, to_user_balance}
    end
  end

  defp apply_deposit(user, balances, currency, amount) do
    case Map.get(balances, currency) do
      nil ->
        updated_balances = Map.put(balances, currency, amount)
        :ets.insert(:users, {user, updated_balances})
        {:ok, Map.get(updated_balances, currency) |> Helpers.normalize_amount()}

      current_amount ->
        updated_balances = Map.put(balances, currency, amount + current_amount)

        :ets.insert(:users, {user, updated_balances})
        {:ok, Map.get(updated_balances, currency) |> Helpers.normalize_amount()}
    end
  end

  defp apply_withdraw(user, balances, currency, amount) do
    case Map.get(balances, currency) do
      balance when balance <= 0.0 ->
        {:error, :not_enough_money}

      balance when amount > balance ->
        {:error, :not_enough_money}

      current_amount ->
        updated_balances = Map.put(balances, currency, current_amount - amount)

        :ets.insert(:users, {user, updated_balances})
        {:ok, Map.get(updated_balances, currency) |> Helpers.normalize_amount()}
    end
  end

  def get_user(""), do: nil
  def get_user(nil), do: nil

  def get_user(user) do
    :ets.lookup(:users, Helpers.normalize_user(user))
    |> List.first()
  end

  def check_operations(user, :normal), do: Operation.get(user) |> length()
end
