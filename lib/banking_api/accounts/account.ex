defmodule BankingApi.Accounts.Account do
  @moduledoc """
  false
  """
  alias BankingApi.Repo
  alias BankingApi.Accounts.Schemas.Account

  @doc "Create a new account"
  def create_account(params) do
    with %Ecto.Changeset{} = changeset <- Account.changeset(params),
         {:ok, account} <- Repo.insert(changeset) do
      {:ok, account}
    else
      {:error, changeset} -> {:error, changeset}
    end
  end
end
