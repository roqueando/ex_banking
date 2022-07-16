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

## Performance test explanation

Every time the system run an operation like deposit, withdraw or send the system should handle 10 or less operations for every individual user. <br>

### So how the operation state works? 

When the user do an operation will be created an operation with the user, the type of operation (deposit, withdraw or send) and with an status. To simulate a queue I put every 1 second will remove one operation from state turning free the user operations to run another one. If the user has 10 operation and try to do another one, the system returns that user has too much requests, and after one second the user can try again because the queue will be free.
