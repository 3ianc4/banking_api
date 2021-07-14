defmodule BankingApiWeb.AccountController do
  @moduledoc false
  use BankingApiWeb, :controller

  alias BankingApi.Accounts.Account
  alias BankingApi.Accounts.Inputs.Deposit
  alias BankingApi.Accounts.Inputs.Transfer
  alias BankingApi.Accounts.Inputs.Withdraw

  @doc false
  def create(conn, params) do
    with {:ok, account} <- Account.create_account(params) do
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

  def withdraw(conn, params) do
    with {:ok, validated} <- validate_transaction(params, Withdraw),
         {:ok, account} <- Account.withdraw(validated) do
      response = %{
        message: "Withdrawal successful",
        account: %{
          id: account.id,
          balance: account.balance
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

  def deposit(conn, params) do
    with {:ok, validated} <- validate_transaction(params, Deposit),
         {:ok, account} <- Account.deposit(validated) do
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

  def transfer(conn, params) do
    with {:ok, validated} <- validate_transaction(params, Transfer),
         {:ok, from_account} <- Account.transfer(validated) do
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
