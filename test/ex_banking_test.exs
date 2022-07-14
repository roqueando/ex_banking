defmodule ExBankingTest do
  use ExUnit.Case
  doctest ExBanking

  test "create_user/1" do
    user = ExBanking.create_user("User One")
    assert :ok = user
  end

  setup_all do
    withdraw_name = "User Withdraw"
    deposit_name = "User Deposit"
    ExBanking.create_user(deposit_name)
    ExBanking.create_user(withdraw_name)
    ExBanking.deposit(deposit_name, 0.0, "brl")
    ExBanking.deposit(withdraw_name, 30.50, "brl")
    {deposit_user, deposit_balances} = Bank.get_user(deposit_name)
    {withdraw_user, withdraw_balances} = Bank.get_user(withdraw_name)

    %{
      deposit_user: deposit_user,
      deposit_balances: deposit_balances,
      withdraw_user: withdraw_user,
      withdraw_balances: withdraw_balances
    }
  end

  describe "deposit/3" do
    test "should deposit an amount with another currency", %{deposit_user: user} do
      assert {:ok, brl_balance} = ExBanking.deposit(user, 30.50, "brl")
      assert brl_balance == 30.50
      assert {:ok, balance} = ExBanking.deposit(user, 15.50, "usd")
      assert balance == 15.50
      {_user, balances} = Bank.get_user(user)
      assert %{brl: 30.50, usd: 15.50} = balances
    end

    test "should give and error when passing wrong arguments" do
      assert {:error, :wrong_arguments} = ExBanking.deposit(nil, 30.50, "brl")
      assert {:error, :wrong_arguments} = ExBanking.deposit("user_deposit", nil, "brl")
      assert {:error, :wrong_arguments} = ExBanking.deposit("user_deposit", 30.50, nil)
      assert {:error, :wrong_arguments} = ExBanking.deposit(nil, nil, nil)
      assert {:error, :wrong_arguments} = ExBanking.deposit("user_deposit", -12, "brl")
    end
  end

  describe "withdraw/3" do
    test "should withdraw an amount with currency", %{withdraw_user: user} do
      assert {:ok, balance} = ExBanking.withdraw(user, 10.00, "brl")
      assert balance == 20.50
      assert {"user_withdraw", %{brl: 20.50}} = Bank.get_user(user)
    end

    test "should give and error when passing wrong arguments" do
      assert {:error, :wrong_arguments} = ExBanking.withdraw(nil, 30.50, "brl")
      assert {:error, :wrong_arguments} = ExBanking.withdraw("user_withdraw", nil, "brl")
      assert {:error, :wrong_arguments} = ExBanking.withdraw("user_withdraw", 30.50, nil)
      assert {:error, :wrong_arguments} = ExBanking.withdraw(nil, nil, nil)
      assert {:error, :wrong_arguments} = ExBanking.withdraw("user_withdraw", -12, "brl")
    end
  end

  describe "get_balance/2" do
    test "should return the balance from deposit user" do
      name = "User DepositB"
      ExBanking.create_user(name)
      ExBanking.deposit(name, 10.0, "brl")
      {:ok, balance} = ExBanking.get_balance(name, "brl")
      assert balance != 0.0
    end
  end

  describe "send/4" do
    test "should send 10 brl from user_a to user_b" do
      user_a = "User A"
      user_b = "User B"
      ExBanking.create_user(user_a)
      ExBanking.create_user(user_b)
      ExBanking.deposit(user_a, 10.0, "brl")
      ExBanking.deposit(user_b, 10.0, "brl")

      {:ok, from_user_balance, to_user_balance} = ExBanking.send(user_a, user_b, 5.0, "brl")
      assert from_user_balance == 5.0
      assert to_user_balance == 15.0
    end

    test "should send error if user_a does not exist" do
      user_b2 = "User B2"
      ExBanking.create_user(user_b2)
      ExBanking.deposit(user_b2, 10.0, "brl")

      assert {:error, :sender_does_not_exist} = ExBanking.send("User A2", user_b2, 5.0, "brl")
    end
  end
end
