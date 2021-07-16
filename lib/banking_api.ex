defmodule BankingApi do
  @moduledoc """
  BankingApi keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  alias BankingApi.Accounts.Account
  alias BankingApi.Accounts.Transactions

  defdelegate create_account(params), to: Account, as: :execute
  defdelegate deposit(params), to: Transactions, as: :deposit
  defdelegate withdraw(params), to: Transactions, as: :withdraw
  defdelegate transfer(params), to: Transactions, as: :transfer
end
