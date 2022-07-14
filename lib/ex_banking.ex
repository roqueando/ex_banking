defmodule ExBanking do
  @moduledoc """
  Documentation for `ExBanking`.
  """

  @spec create_user(String.t()) :: :ok | {:error, :wrong_arguments | :user_already_exists}
  def create_user(nil), do: {:error, :wrong_arguments}
  def create_user(""), do: {:error, :wrong_arguments}

  def create_user(user) do
    case Bank.create_user(user) do
      {:error, :user_already_exists} ->
        {:error, :user_already_exists}

      _user ->
        :ok
    end
  end

  @spec deposit(String.t(), number(), String.t()) ::
          {:ok, number()}
          | {:error, :wrong_arguments | :user_does_not_exists | :too_many_requests_to_user}

  def deposit(nil, _amount, _currency), do: {:error, :wrong_arguments}
  def deposit(_user, nil, _currency), do: {:error, :wrong_arguments}
  def deposit(_user, _amount, nil), do: {:error, :wrong_arguments}
  def deposit(nil, nil, nil), do: {:error, :wrong_arguments}
  def deposit(_, amount, _currency) when amount < 0, do: {:error, :wrong_arguments}

  def deposit(user, amount, currency) do
    case Bank.deposit(user, amount, currency) do
      {:error, :user_does_not_exist} ->
        {:error, :user_does_not_exist}

      {:error, :too_many_requests_to_user} ->
        {:error, :too_many_requests_to_user}

      {:ok, new_balance} ->
        {:ok, new_balance}
    end
  end

  def get_user(user), do: GenServer.call(Bank, {:get_user, user})

  def normalize_user(%{user: user}), do: String.capitalize(user) |> String.replace("_", " ")
end
