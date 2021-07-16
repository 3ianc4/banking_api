defmodule BankingApiWeb.AccountController do
  @moduledoc false
  use BankingApiWeb, :controller

  alias BankingApi.Accounts.Account
  alias BankingApi.Accounts.Inputs.{Deposit, Transfer, Withdraw}
  alias BankingApi.Accounts.Transactions

  action_fallback BankingApiWeb.FallbackController

  @doc "Create a new account"
  @spec create(conn :: Plug.Conn.t(), params :: map()) :: Plug.Conn.t()
  def create(conn, params) do
    with {:ok, account} <- BankingApi.create_account(params) do
      response = %{
        message: "Account created successfully",
        account: account
      }

      send_json(conn, 201, response)
    else
      {:error, %Ecto.Changeset{errors: [name: _]}} ->
        message = %{
          reason: "Invalid name"
        }

        send_json(conn, 422, message)

      {:error, %Ecto.Changeset{errors: [email: _]}} ->
        message = %{
          reason: "Invalid email"
        }

        send_json(conn, 422, message)
    end
  end

  def show(conn, %{"id" => account_id}) do
    with balance <- Account.balance(account_id) do
      send_json(conn, 200, %{description: "Your current balance is #{balance}"})
    else
      {:error, :not_found} ->
        send_json(conn, 404, %{type: "not_found", description: "Account not found"})
    end
  end

  @doc "Withdraw money from an account"
  @spec withdraw(conn :: Plug.Conn.t(), params :: map()) :: Plug.Conn.t()
  def withdraw(conn, params) do
    with {:ok, validated} <- validate_transaction(params, Withdraw),
         {:ok, account} <- BankingApi.withdraw(validated) do
      response = %{
        message: "Withdrawal successful",
        account: %{
          id: account.id,
          balance: account.balance
        }
      }

      send_json(conn, 200, response)
    else
      {:error, %Ecto.Changeset{errors: [balance: _]} = changeset} ->
        {:error, changeset}

      {:error, :insufficient_funds} ->
        {:error, :insufficient_funds}

        send_json(conn, 200, "{:error, :inssuficient_balance}")
    end
  end

  @doc "Deposit money to an account"
  @spec deposit(conn :: Plug.Conn.t(), params :: map()) :: Plug.Conn.t()
  def deposit(conn, params) do
    with {:ok, validated} <- validate_transaction(params, Deposit),
         {:ok, account} <- BankingApi.deposit(validated) do
      response = %{
        message: "Deposit successful",
        account: %{
          id: account.id,
          balance: account.balance
        }
      }

      send_json(conn, 200, response)
    end
  end

  @doc "Transfers money from an account to another"
  @spec transfer(conn :: Plug.Conn.t(), params :: map()) :: Plug.Conn.t()
  def transfer(conn, params) do
    with {:ok, validated} <- validate_transaction(params, Transfer),
         {:ok, from_account} <- BankingApi.transfer(validated) do
      response = %{
        message: "Transfer successful",
        from_account: %{
          id: from_account.id,
          balance: from_account.balance
        }
      }

      send_json(conn, 200, response)
    else
      {:error, %Ecto.Changeset{errors: [balance: _]}} ->
        message = %{
          reason: "Invalid balance"
        }

        send_json(conn, 200, message)
    end
  end

  defp send_json(conn, status, response) do
    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(status, Jason.encode!(response))
  end

  # defp cast_and_apply(params) do
  #  changeset = Withdraw.changeset(params)
  #  {:ok, changeset}
  # end

  defp validate_transaction(params, module) do
    case module.changeset(params) do
      %Ecto.Changeset{valid?: true} = changeset ->
        {:ok, Ecto.Changeset.apply_changes(changeset)}

      changeset ->
        {:error, changeset}
    end
  end
end
