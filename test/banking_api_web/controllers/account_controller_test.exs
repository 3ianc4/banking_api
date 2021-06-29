defmodule BankingApiWeb.AccountControllerTest do
  use BankingApiWeb.ConnCase

  alias BankingApi.Repo
  # alias BankingApi.Accounts.Account
  alias BankingApi.Accounts.Schemas.Account, as: Accounts

  describe "POST /api/accounts/create" do
    test "successfully create account when input is valid", %{conn: conn} do
      input = %{
        "name" => "John Doe",
        "email" => "john@email.com"
      }

      assert %{
               "message" => "Account created successfully",
               "account" => %{
                 "balance" => 0,
                 "email" => "john@email.com",
                 "name" => "John Doe"
               }
             } =
               conn
               |> post("/api/accounts/create", input)
               |> json_response(201)
    end
  end

  describe "PATCH /api/accounts/withdraw" do
    test "successfully withdraw money from an account when input is valid", %{conn: conn} do
      new_account_params = %{
        "name" => "John Doe",
        "email" => "john@email.com",
        "balance" => 100
      }

      account = Repo.insert!(Accounts.changeset(new_account_params))

      input_for_withdrawal = %{
        "account_id" => account.id,
        "amount" => 30
      }

      assert %{"account" => %{"balance" => 70, "id" => _}, "message" => "Withdrawal successful"} =
               conn
               |> patch("/api/accounts/withdraw", input_for_withdrawal)
               |> json_response(200)
    end
  end
end
