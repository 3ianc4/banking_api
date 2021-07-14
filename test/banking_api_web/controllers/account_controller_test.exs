defmodule BankingApiWeb.AccountControllerTest do
  use BankingApiWeb.ConnCase

  import Ecto.Changeset

  alias BankingApi.Repo
  # alias BankingApi.Accounts.Account
  alias BankingApi.Accounts.Schemas.Account, as: Accounts

  describe "POST /api/accounts/create" do
    setup do
      input = %{
        "name" => "John Doe",
        "email" => "john@email.com"
      }

      {:ok, input: input}
    end

    test "successfully create account when input is valid", ctx do
      assert %{
               "message" => "Account created successfully",
               "account" => %{
                 "balance" => 0,
                 "email" => "john@email.com",
                 "name" => "John Doe"
               }
             } =
               ctx.conn
               |> post("/api/accounts/create", ctx.input)
               |> json_response(201)
    end

    test "fails on creating account when name is invalid", ctx do
      input = %{
        "name" => "Jo",
        "email" => "john@email.com"
      }
      assert %{"reason" => "Invalid name"}
             =
               ctx.conn
               |> post("/api/accounts/create", input)
               |> json_response(422)
    end

    test "fails on creating account when email is invalid", ctx do
      input = %{
        "name" => "John",
        "email" => "johnemail.com"
      }
      assert %{"reason" => "Invalid email"}
             =
               ctx.conn
               |> post("/api/accounts/create", input)
               |> json_response(422)
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

    test "fails withdraw when balance is unsuficient", %{conn: conn} do
      new_account_params = %{
        "name" => "John Doe",
        "email" => "john@email.com",
        "balance" => 100
      }

      account = Repo.insert!(Accounts.changeset(new_account_params))

      input_for_withdrawal = %{
        "account_id" => account.id,
        "amount" => 150
      }

      assert %{"reason" => "Invalid balance"} =
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

    test "fails transfers when balance is insufficient", %{conn: conn} do
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
        "amount" => 200
      }

      assert %{"reason" => "Invalid balance"}
              =
               conn
               |> patch("/api/accounts/transfer", input_for_transfer)
               |> json_response(200)
    end
  end

  # defp update!(model, changes) do
  #   model |> change(changes) |> Repo.update!()
  # end
end
