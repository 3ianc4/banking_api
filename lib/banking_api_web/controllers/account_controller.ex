defmodule BankingApiWeb.AccountController do
  @moduledoc false
  use BankingApiWeb, :controller

  alias BankingApi.Accounts.Account

  @doc false
  def create(conn, params) do
    with {:ok, account} <- Account.create_account(params) do
      response = %{
        message: "Account created successfully",
        account: account
      }

      send_json(conn, 201, response)
    else
      {:error, %Ecto.Changeset{errors: errors}} ->
        message = %{
          type: "Unprocessable Entity",
          description: "Invalid input",
        }

        send_json(conn, 422, message)
    end
  end

  defp send_json(conn, status, response) do
    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(status, Jason.encode!(response))
  end
end
