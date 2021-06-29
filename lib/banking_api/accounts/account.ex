defmodule BankingApi.Accounts.Account do
  @moduledoc """
  false
  """
  alias BankingApi.Accounts.Schemas.Account
  alias BankingApi.Repo

  @doc "Create a new account"
  def create_account(params) do
    with %Ecto.Changeset{} = changeset <- Account.changeset(params),
         {:ok, account} <- Repo.insert(changeset) do
      {:ok, account}
    else
      {:error, changeset} -> {:error, changeset}
    end
  end

  @doc false
  def withdraw(params) do
    with {:ok, account} <- get_account(params.account_id) do
      do_withdraw(params, account)
    end
  end

  defp get_account(account_id) do
    account = Repo.get(Account, account_id)

    if is_nil(account) do
      {:error, :invalid_account}
    else
      {:ok, account}
    end
  end

  defp do_withdraw(params, account) do
    updated_balance = %{balance: account.balance - params.amount}

    account
    |> Account.changeset_update(updated_balance)
    |> Repo.update()
  end

  # defp verify_balance(params) do
  #   balance = Repo.get(Account, :balance)
  #   if balance > params.amount do
  #     :ok
  #   else
  #     {:error, :insufficient_balance}
  #   end
  # end
end
