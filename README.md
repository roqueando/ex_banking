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
