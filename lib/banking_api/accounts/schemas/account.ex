defmodule BankingApi.Accounts.Schemas.Account do
  @moduledoc """
  false
  """
  use Ecto.Schema

  import Ecto.Changeset

  @derive {Jason.Encoder, except: [:__meta__]}

  @primary_key {:id, :binary_id, autogenerate: true}
  @required [:name, :email]
  @optional [:balance]

  @email_regex ~r/^[A-Za-z0-9\._%+\-+']+@[A-Za-z0-9\.\-]+\.[A-Za-z]{2,4}$/

  schema "accounts" do
    field :name, :string
    field :email, :string
    field :balance, :integer, default: 0

    timestamps()
  end

  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
    |> validate_length(:name, min: 3)
    |> validate_format(:email, @email_regex)
    |> validate_number(:balance, greater_than_or_equal_to: 0)
    |> unique_constraint(:email)
  end

  @doc false
  def changeset_update(account, params) do
    account
    |> cast(params, [:balance])
    |> validate_number(:balance, greater_than_or_equal_to: 0)
  end
end
