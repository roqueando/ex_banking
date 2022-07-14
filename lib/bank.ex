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
        :ets.insert(:users, {normalized_user, [brl: 0.0]})
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

        updated_balances =
          Keyword.update(balances, normalized_currency, amount, fn value ->
            value + amount
          end)

        :ets.insert(:users, {user, updated_balances})
        {:ok, updated_balances[normalized_currency]}
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
