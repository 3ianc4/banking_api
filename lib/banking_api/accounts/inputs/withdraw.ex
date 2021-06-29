defmodule BankingApi.Accounts.Inputs.Withdraw do
  @moduledoc """
  false
  """
  use Ecto.Schema

  import Ecto.Changeset

  @required [:account_id, :amount]

  embedded_schema do
    field :account_id, Ecto.UUID
    field :amount, :integer
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, @required)
    |> validate_required(@required)
    |> validate_number(:amount, greater_than: 0)
  end
end
