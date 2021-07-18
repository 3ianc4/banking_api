defmodule BankingApi.Accounts.AccountTest do
  use ExUnit.Case, async: true

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(BankingApi.Repo)

    account_params = %{
      "name" => "anna",
      "email" => "anna@mail.com",
      "balance" => 100
    }

    {:ok, account_params: account_params}
  end

  describe "execute/1" do
    test "successfully creates an account when params are valid", ctx do
      assert {:ok, _account} = BankingApi.create_account(ctx.account_params)
    end

    test "fails to create an account when name is invalid", ctx do
      account_params = update!(ctx.account_params, "name", "a")
      assert {:error, _changeset} = BankingApi.create_account(account_params)
    end

    test "fails to create an account when email is invalid", ctx do
      account_params = update!(ctx.account_params, "email", "a")
      assert {:error, _changeset} = BankingApi.create_account(account_params)
    end

    test "fails to create an account when balance is invalid", ctx do
      account_params = update!(ctx.account_params, "balance", -1)
      assert {:error, _changeset} = BankingApi.create_account(account_params)
    end
  end

  describe "withdraw/1" do
    test "succeeds when params are valid", ctx do
      {:ok, account} = BankingApi.create_account(ctx.account_params)

      withdraw_params = %{
        account_id: account.id,
        amount: 30
      }

      {:ok, result} = BankingApi.withdraw(withdraw_params)

      assert 70 == result.balance
    end
  end

  describe "deposit/1" do
    test "succeeds when params are valid", ctx do
      {:ok, account} = BankingApi.create_account(ctx.account_params)

      deposit_params = %{
        account_id: account.id,
        amount: 30
      }

      {:ok, result} = BankingApi.deposit(deposit_params)

      assert 130 == result.balance
    end
  end

  describe "transfer/1" do
    test "succeeds when params are valid", ctx do
      from_account_params = ctx.account_params

      to_account_params = %{
        "name" => "louise",
        "email" => "louise@mail.com",
        "balance" => 100
      }

      {:ok, from_account} = BankingApi.create_account(from_account_params)
      {:ok, to_account} = BankingApi.create_account(to_account_params)

      transfer_params = %{
        from_account_id: from_account.id,
        to_account_id: to_account.id,
        amount: 30
      }

      {:ok, result} = BankingApi.transfer(transfer_params)

      assert 70 == result.balance
    end
  end

  defp update!(model, key, value) do
    model |> Map.replace(key, value)
  end
end
