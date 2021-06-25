defmodule BankingApiWeb.AccountControllerTest do
  use BankingApiWeb.ConnCase

  #alias BankingApi.Repo
  #alias BankingApi.Accounts.Account

  describe "POST /api/accounts" do
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
              |> post("/api/accounts", input)
              |> json_response(201)
    end
  end
end
