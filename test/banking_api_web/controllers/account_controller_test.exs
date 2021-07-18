defmodule BankingApiWeb.AccountControllerTest do
  use BankingApiWeb.ConnCase

  alias BankingApi.Accounts.Schemas.Account, as: Accounts
  alias BankingApi.Repo

  setup do
    account_input = %{
      "name" => "Ana Maria",
      "email" => "anamaria@email.com",
      "balance" => 100
    }

    {:ok, account_input: account_input}
  end

  describe "POST /api/accounts/create" do
    test "successfully create account when input is valid", ctx do
      assert %{
               "message" => "Account created successfully",
               "account" => %{
                 "balance" => 100,
                 "email" => "anamaria@email.com",
                 "name" => "Ana Maria"
               }
             } =
               ctx.conn
               |> post("/api/accounts/create", ctx.account_input)
               |> json_response(201)
    end

    test "fails on creating account when name is invalid", ctx do
      account_input = update!(ctx.account_input, "name", "Jo")

      assert %{"reason" => "Invalid name"} =
               ctx.conn
               |> post("/api/accounts/create", account_input)
               |> json_response(422)
    end

    test "fails on creating account when email is invalid", ctx do
      account_input = update!(ctx.account_input, "email", "aaaa")

      assert %{"reason" => "Invalid email"} =
               ctx.conn
               |> post("/api/accounts/create", account_input)
               |> json_response(422)
    end
  end

  describe "POST /api/accounts/show" do
    test "successfully shows account's balance", ctx do
      {:ok, account} = BankingApi.create_account(ctx.account_input)

      assert "{\"description\":\"Your current balance is 100\"}" =
               ctx.conn
               |> get("/api/accounts/show", %{"id" => account.id})
               |> response(200)
    end
  end

  describe "PATCH /api/accounts/withdraw" do
    test "successfully withdraw money from an account when input is valid", ctx do
      account = Repo.insert!(Accounts.changeset(ctx.account_input))

      input_for_withdraw = %{
        "account_id" => account.id,
        "amount" => 30
      }

      assert %{"account" => %{"balance" => 70, "id" => _}, "message" => "Withdraw successful"} =
               ctx.conn
               |> patch("/api/accounts/withdraw", input_for_withdraw)
               |> json_response(200)
    end

    test "withdrawal fails when balance is insufficient", ctx do
        account = Repo.insert!(Accounts.changeset(ctx.account_input))

      input_for_withdraw = %{
        "account_id" => account.id,
        "amount" => 150
      }

      assert "{:error, :insufficient_funds}" =
               ctx.conn
               |> patch("/api/accounts/withdraw", input_for_withdraw)
               |> json_response(200)
    end
  end

  describe "PATCH /api/accounts/deposit" do
    test "successfully deposits money to an account when input is valid", ctx do
      account = Repo.insert!(Accounts.changeset(ctx.account_input))

      input_for_deposit = %{
        "account_id" => account.id,
        "amount" => 30
      }

      assert %{"account" => %{"balance" => 130, "id" => _}, "message" => "Deposit successful"} =
               ctx.conn
               |> patch("/api/accounts/deposit", input_for_deposit)
               |> json_response(200)
    end
  end

  describe "PATCH /api/accounts/transfer" do
    test "successfully transfers between accounts when input is valid", ctx do
      from_account_params = ctx.account_input

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
               ctx.conn
               |> patch("/api/accounts/transfer", input_for_transfer)
               |> json_response(200)
    end

    test "fails transfers when balance is insufficient", ctx do
      from_account_params = ctx.account_input

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
        "amount" => 200
      }

      assert %{"reason" => "Invalid balance"} =
               ctx.conn
               |> patch("/api/accounts/transfer", input_for_transfer)
               |> json_response(200)
    end
  end

  defp update!(model, key, value) do
    model |> Map.replace(key, value)
  end
end
