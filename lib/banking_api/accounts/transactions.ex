defmodule BankingApi.Accounts.Transactions do
  @moduledoc false

  alias BankingApi.Accounts.Account
  alias BankingApi.Accounts.Schemas.Account, as: Accounts
  alias BankingApi.Repo

  @doc "Withdraws a specific amount from a given bank account"
  @spec withdraw(params :: map()) :: {:ok, Changeset.t()}
  def withdraw(params) do
    with {:ok, account} <- Account.get_account(params.account_id),
         {:valid?, true} <- {:valid?, Account.has_sufficient_funds?(params.account_id, params.amount)} do
      do_withdraw(params, account)
    else
      {:error, error} -> {:error, error}
    end
  end

  @doc "Deposits an amount on an account"
  @spec deposit(params :: map()) :: {:ok, Changeset.t()}
  def deposit(params) do
    with {:ok, account} <- Account.get_account(params.account_id) do
      do_deposit(params, account)
    end
  end

  @doc "Transfers an amount between accounts"
  @spec transfer(params :: map()) :: {:ok, Changeset.t()}
  def transfer(params) do
    with {:ok, from_account} <- Account.get_account(params.from_account_id),
         {:ok, to_account} <- Account.get_account(params.to_account_id) do
      do_transfer(params, from_account, to_account)
    end
  end

  defp do_withdraw(params, account) do
    updated_balance = %{balance: account.balance - params.amount}

    account
    |> Accounts.changeset_update(updated_balance)
    |> Repo.update()
  end

  defp do_deposit(params, account) do
    updated_balance = %{balance: account.balance + params.amount}

    account
    |> Accounts.changeset_update(updated_balance)
    |> Repo.update()
  end

  defp do_transfer(params, from_account, to_account) do
    from = do_withdraw(params, from_account)
    do_deposit(params, to_account)

    from
  end

end
