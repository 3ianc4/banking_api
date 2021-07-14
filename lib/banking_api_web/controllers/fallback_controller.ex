defmodule BankingApiWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid Plug.Conn responses.
  """
  use BankingApiWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(BankingApiWeb.ChangesetView)
    |> render("error.json", changeset: changeset)
  end
end
