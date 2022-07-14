defmodule ExBankingTest do
  use ExUnit.Case
  doctest ExBanking

  test "create_user/1" do
    user = ExBanking.create_user("User One")
    assert :ok = user
  end

  describe "deposit/3" do
    setup do
      ExBanking.create_user("User Deposit")
      {user, balances} = Bank.get_user("User Deposit")
      %{user: user, balances: balances}
    end

    test "should deposit an amount with currency", %{user: user} do
      assert {:ok, balance} = ExBanking.deposit(user, 30.50, "brl")
      assert balance == 30.50
      assert {"user_deposit", brl: 30.50} = Bank.get_user(user)
    end

    test "should give and error when passing wrong arguments" do
      assert {:error, :wrong_arguments} = ExBanking.deposit(nil, 30.50, "brl")
      assert {:error, :wrong_arguments} = ExBanking.deposit("user_deposit", nil, "brl")
      assert {:error, :wrong_arguments} = ExBanking.deposit("user_deposit", 30.50, nil)
      assert {:error, :wrong_arguments} = ExBanking.deposit(nil, nil, nil)
      assert {:error, :wrong_arguments} = ExBanking.deposit("user_deposit", -12, "brl")
    end
  end
end
