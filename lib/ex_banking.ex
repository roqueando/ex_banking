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

  @spec withdraw(String.t(), number(), String.t()) ::
          {:ok, number()}
          | {:error,
             :wrong_arguments
             | :user_does_not_exists
             | :not_enough_money
             | :too_many_requests_to_user}
  def withdraw(nil, _amount, _currency), do: {:error, :wrong_arguments}
  def withdraw(_user, nil, _currency), do: {:error, :wrong_arguments}
  def withdraw(_user, _amount, nil), do: {:error, :wrong_arguments}
  def withdraw(nil, nil, nil), do: {:error, :wrong_arguments}
  def withdraw(_, amount, _currency) when amount < 0, do: {:error, :wrong_arguments}

  def withdraw(user, amount, currency) do
    case Bank.withdraw(user, amount, currency) do
      {:error, :user_does_not_exist} ->
        {:error, :user_does_not_exist}

      {:error, :not_enough_money} ->
        {:error, :not_enough_money}

      {:error, :too_many_requests_to_user} ->
        {:error, :too_many_requests_to_user}

      {:ok, new_balance} ->
        {:ok, new_balance}
    end
  end

  @spec get_balance(String.t(), String.t()) ::
          {:ok, number()}
          | {:error, :wrong_arguments | :user_does_not_exists | :too_many_requests_to_user}
  def get_balance(nil, _currency), do: {:error, :wrong_arguments}
  def get_balance("", _currency), do: {:error, :wrong_arguments}
  def get_balance(_, currency) when currency <= 0, do: {:error, :wrong_arguments}

  def get_balance(user, currency) do
    case Bank.get_balance(user, currency) do
      {:error, :user_does_not_exist} ->
        {:error, :user_does_not_exist}

      {:error, :too_many_requests_to_user} ->
        {:error, :too_many_requests_to_user}

      {:ok, balance} ->
        {:ok, balance}
    end
  end

  @spec send(String.t(), String.t(), number(), String.t()) ::
          {:ok, number(), number()}
          | {:error,
             :wrong_arguments
             | :not_enough_money
             | :sender_does_not_exist
             | :receiver_does_not_exist
             | :too_many_requests_to_sender
             | :too_many_requests_to_receiver}

  def send(from_user, to_user, _amount, _currency) when is_nil(from_user) or is_nil(to_user),
    do: {:error, :wrong_arguments}

  def send(_from_user, _to_user, amount, _currency) when is_nil(amount) or amount <= 0,
    do: {:error, :wrong_arguments}

  def send(_from_user, _to_user, _amount, nil), do: {:error, :wrong_arguments}
  def send(_from_user, _to_user, _amount, ""), do: {:error, :wrong_arguments}

  def send(from_user, to_user, amount, currency) do
    case Bank.send(from_user, to_user, amount, currency) do
      {:error, :sender_does_not_exist} ->
        {:error, :sender_does_not_exist}

      {:error, :receiver_does_not_exist} ->
        {:error, :receiver_does_not_exist}

      {:error, :too_many_requests_to_sender} ->
        {:error, :too_many_requests_to_sender}

      {:error, :too_many_requests_to_receiver} ->
        {:error, :too_many_requests_to_receiver}

      {:ok, from_user_balance, to_user_balance} ->
        {:ok, from_user_balance, to_user_balance}
    end
  end
end
