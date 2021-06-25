defmodule BankingApi.Repo.Migrations.CreateAccountsTable do
  use Ecto.Migration

  def change do
    create table(:accounts, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string
      add :email, :string
      add :balance, :integer, default: 0

      timestamps()
    end

    create unique_index(:accounts, [:email])

    create constraint(:accounts, :balance_must_be_greater_than_or_equal_to_zero,
             check: "balance >= 0"
           )
  end
end
