defmodule BankingApi.Accounts.AccountTest do
  use ExUnit.Case, async: true

  alias BankingApi.Accounts.Account
  alias BankingApi.Accounts.Schemas.Account, as: Accounts

  describe "create_account/1" do
    setup do
      :ok = Ecto.Adapters.SQL.Sandbox.checkout(BankingApi.Repo)
    end

    test "successfully creates an account when params are valid" do
      account_params = %{
        "name" => "anna",
        "email" => "anna@mail.com",
        "balance" => 1
      }

      assert {:ok, _account} = Account.create_account(account_params)
    end

    test "fails to create an account when name is invalid" do
      account_params = %{
        "name" => "an",
        "email" => "anna@mail.com",
        "balance" => 1
      }

      assert {:error, _changeset} = Account.create_account(account_params)
    end

    test "fails to create an account when email is invalid" do
      account_params = %{
        "name" => "an",
        "email" => "annamail.com",
        "balance" => 1
      }

      assert {:error, _changeset} = Account.create_account(account_params)
    end

    test "fails to create an account when balance is invalid" do
      account_params = %{
        "name" => "an",
        "email" => "anna@mail.com",
        "balance" => -1
      }

      assert {:error, _changeset} = Account.create_account(account_params)
    end
  end

  describe "withdraw/1" do
    setup do
      :ok = Ecto.Adapters.SQL.Sandbox.checkout(BankingApi.Repo)
    end

    test "succeeds when params are valid" do
      account_params = %{
        "name" => "anna",
        "email" => "anna@mail.com",
        "balance" => 100
      }

      {:ok, account} = Account.create_account(account_params)

      withdraw_params = %{
        account_id: account.id,
        amount: 30
      }

      {:ok, result} = Account.withdraw(withdraw_params)

      assert 70 == result.balance
    end
  end
end
