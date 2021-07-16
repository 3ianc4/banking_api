defmodule BankingApi.Accounts.Account do
  @moduledoc """
  Domain functions for the Bank Accounts context
  """

  import Ecto.Query
  alias BankingApi.Accounts.Schemas.Account
  alias BankingApi.Repo

  @doc "Create a new account"
  def execute(params) do
    with %Ecto.Changeset{} = changeset <- Account.changeset(params),
         {:ok, account} <- Repo.insert(changeset) do
      {:ok, account}
    else
      {:error, changeset} -> {:error, changeset}
    end
  end

  def get_account(account_id) do
    account = Repo.get(Account, account_id)

    if is_nil(account) do
      {:error, :not_found}
    else
      {:ok, account}
    end
  end

  def has_sufficient_funds?(account, amount) do
    balance = balance(account)

    if balance > amount do
      true
    else
      false
    end
  end

  def balance(account) do
    from(a in Account, where: a.id == ^account, select: a.balance)
    |> Repo.one()
  end
end
