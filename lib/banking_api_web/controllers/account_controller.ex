defmodule BankingApiWeb.AccountController do
  @moduledoc false
  use BankingApiWeb, :controller

  alias BankingApi.Accounts.Account
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
      {:error, %Ecto.Changeset{errors: _errors}} ->
        message = %{
          type: "Unprocessable Entity",
          description: "Invalid input"
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
