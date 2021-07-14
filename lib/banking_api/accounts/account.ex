defmodule BankingApi.Accounts.Account do
  @moduledoc """
  Domain functions for the Bank Accounts context
  """

  import Ecto.Query
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

  # @doc """
  # Returns user's current balance
  # """
  # @spec balance(integer()) :: Money.t()
  # def balance(user_id) do
  #   Transaction
  #   |> where([t], t.user_id == ^user_id)
  #   |> group_by([t], t.type)
  #   |> select([t], {t.type, sum(t.amount)})
  #   |> Repo.all()
  #   |> compute_balance()
  # end

  @doc "Withdraws a specific amount from a given bank account"
  @spec withdraw(params :: map()) :: {:ok, Changeset.t()}
  def withdraw(params) do
    with {:ok, account} <- get_account(params.account_id),
         {:valid?, true} <- {:valid?, has_sufficient_funds?(params.account_id, params.amount)} do
      do_withdraw(params, account)
    else
      {:error, error} -> {:error, error}
    end
  end

  @doc "Deposits an amount on an account"
  @spec deposit(params :: map()) :: {:ok, Changeset.t()}
  def deposit(params) do
    with {:ok, account} <- get_account(params.account_id) do
      do_deposit(params, account)
    end
  end

  @doc "Transfers an amount between accounts"
  @spec transfer(params :: map()) :: {:ok, Changeset.t()}
  def transfer(params) do
    with {:ok, from_account} <- get_account(params.from_account_id),
         {:ok, to_account} <- get_account(params.to_account_id) do
      do_transfer(params, from_account, to_account)
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

  defp do_deposit(params, account) do
    updated_balance = %{balance: account.balance + params.amount}

    account
    |> Account.changeset_update(updated_balance)
    |> Repo.update()
  end

  defp do_transfer(params, from_account, to_account) do
    from = do_withdraw(params, from_account)
    do_deposit(params, to_account)

    from
  end

  defp has_sufficient_funds?(account, amount) do
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

  # defp verify_balance(params) do
  #   balance = Repo.get(Account, :balance)
  #   if balance > params.amount do
  #     :ok
  #   else
  #     {:error, :insufficient_balance}
  #   end
  # end
end
