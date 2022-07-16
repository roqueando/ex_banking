defmodule OperationsTest do
  use ExUnit.Case

  test "insert a operation" do
    Operation.insert("user_a", "deposit")
    operations = Operation.get("user_a")
    operation = List.first(operations)

    assert %{user: "user_a", type: "deposit", status: :pending} = operation
  end

  test "insert a operation wait a second and check if does have nothing" do
    Operation.insert("user_a", "deposit")
    :timer.sleep(1000)
    operations = Operation.get("user_a")

    assert operations == []
  end

  test "insert 10 operations" do
    for _ <- 1..10 do
      Operation.insert("user_a", "deposit")
    end

    operations = Operation.get("user_a")

    assert length(operations) == 10
  end
end
