defmodule Bank.Helpers do
  def get_user(""), do: nil
  def get_user(nil), do: nil

  def get_user(user) do
    :ets.lookup(:users, normalize_user(user))
    |> List.first()
  end

  def normalize_user(user),
    do: String.trim(user) |> String.downcase() |> String.replace(" ", "_")

  def normalize_currency(currency),
    do: String.trim(currency) |> String.downcase() |> String.to_atom()

  def normalize_amount(amount), do: Float.round(amount, 2)
end
