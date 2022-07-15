# ExBanking

Yolo group test

## Running tests

```sh
mix test
```

## Main features

- Create user
```elixir
ExBanking.create_user("User Test")
> :ok
```

- Deposit to an user
```elixir
ExBanking.deposit("User Test", 30.50, "brl")
> {:ok, 30.50}
```

- Withdraw from user
```elixir
ExBanking.withdraw("User Test", 10.00, "brl")
> {:ok, 20.50}
```

- Get Balance from user
```elixir
ExBanking.deposit("User Test", 30.50, "brl")
ExBanking.get_balance("User Test", "brl")
> {:ok, 30.50}
```

- Send from user to another user
```elixir
ExBanking.create_user("User A")
ExBanking.create_user("User B")
ExBanking.deposit("User A", 10.00, "brl")
ExBanking.deposit("User B", 10.00, "brl")
ExBanking.send("User A", "User B", 5.00, "brl")
> {:ok, 5.00, 15.00}
```
