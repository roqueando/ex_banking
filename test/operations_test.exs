defmodule OperationsTest do
  use ExUnit.Case

  setup do
    user = "user_operation_test_a"
    %{user: user}
  end

  test "insert a operation", %{user: user} do
    Operation.insert(user, "deposit")
    operations = Operation.get(user)
    operation = List.first(operations)

    assert %{user: ^user, type: "deposit", status: :pending} = operation
  end

  test "insert a operation wait a second and check if does have nothing", %{user: user} do
    Operation.insert(user, "deposit")
    :timer.sleep(1000)
    operations = Operation.get(user)

    assert operations == []
  end

  test "insert 10 operations" do
    new_user = "New User"

    for _ <- 1..10 do
      Operation.insert(new_user, "deposit")
    end

    operations = Operation.get(new_user)

    assert length(operations) == 10
  end
end
