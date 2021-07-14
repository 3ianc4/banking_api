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

  describe "PATCH /api/accounts/deposit" do
    test "successfully deposits money to an account when input is valid", %{conn: conn} do
      new_account_params = %{
        "name" => "John Doe",
        "email" => "john@email.com",
        "balance" => 100
      }

      account = Repo.insert!(Accounts.changeset(new_account_params))

      input_for_deposit = %{
        "account_id" => account.id,
        "amount" => 30
      }

      assert %{"account" => %{"balance" => 130, "id" => _}, "message" => "Deposit successful"} =
               conn
               |> patch("/api/accounts/deposit", input_for_deposit)
               |> json_response(200)
    end
  end

  describe "PATCH /api/accounts/transfer" do
    test "successfully transfers between accounts when input is valid", %{conn: conn} do
      from_account_params = %{
        "name" => "John Doe",
        "email" => "john@email.com",
        "balance" => 100
      }

      to_account_params = %{
        "name" => "Johanna Doe",
        "email" => "johanna@email.com",
        "balance" => 100
      }

      from_account = Repo.insert!(Accounts.changeset(from_account_params))
      to_account = Repo.insert!(Accounts.changeset(to_account_params))

      input_for_transfer = %{
        "from_account_id" => from_account.id,
        "to_account_id" => to_account.id,
        "amount" => 30
      }

      assert %{
               "from_account" => %{
                 "balance" => 70,
                 "id" => _
               },
               "message" => "Transfer successful"
             } =
               conn
               |> patch("/api/accounts/transfer", input_for_transfer)
               |> json_response(200)
    end
  end
end
