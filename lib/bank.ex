defmodule Bank do
  use GenServer

  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(_) do
    :ets.new(:users, [:set, :public, :named_table])
    {:ok, "Generated tables in-memory"}
  end

  @doc """
    Insert user into ets in-memory table
    if user exists, return tuple error
  """
  def create_user(user) do
    case get_user(user) do
      nil ->
        normalized_user = normalize_user(user)
        :ets.insert(:users, {normalized_user, %{brl: 0.0}})
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
    case get_user(user) do
      nil ->
        {:error, :user_does_not_exist}

      {user, balances} ->
        normalized_currency = normalize_currency(currency)

        apply_deposit(user, balances, normalized_currency, amount)
    end
  end

  @doc """
    Withdraw a value into user
    if user does not exists will return a tuple error
    if user has no not_enough_money will return a tuple error
  """
  def withdraw(user, amount, currency) do
    case get_user(user) do
      nil ->
        {:error, :user_does_not_exist}

      {user, balances} ->
        normalized_currency = normalize_currency(currency)

        apply_withdraw(user, balances, normalized_currency, amount)
    end
  end

  defp apply_deposit(user, balances, currency, amount) do
    case Map.get(balances, currency) do
      nil ->
        updated_balances = Map.put(balances, currency, amount)
        :ets.insert(:users, {user, updated_balances})
        {:ok, Map.get(updated_balances, currency)}

      current_amount ->
        updated_balances = Map.put(balances, currency, amount + current_amount)

        :ets.insert(:users, {user, updated_balances})
        {:ok, Map.get(updated_balances, currency)}
    end
  end

  defp apply_withdraw(user, balances, currency, amount) do
    case Map.get(balances, currency) do
      balance when balance <= 0.0 ->
        {:error, :not_enough_money}

      current_amount ->
        updated_balances = Map.put(balances, currency, current_amount - amount)

        :ets.insert(:users, {user, updated_balances})
        {:ok, Map.get(updated_balances, currency)}
    end
  end

  def get_user(""), do: nil
  def get_user(nil), do: nil

  def get_user(user) do
    :ets.lookup(:users, normalize_user(user)) |> List.first()
  end

  defp normalize_user(user),
    do: String.trim(user) |> String.downcase() |> String.replace(" ", "_")

  defp normalize_currency(currency),
    do: String.trim(currency) |> String.downcase() |> String.to_atom()
end
