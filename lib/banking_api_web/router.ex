defmodule BankingApiWeb.Router do
  use BankingApiWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", BankingApiWeb do
    pipe_through :api

    post "/accounts/create", AccountController, :create

    get "/accounts/show", AccountController, :show

    patch "/accounts/deposit", AccountController, :deposit
    patch "/accounts/withdraw", AccountController, :withdraw
    patch "/accounts/transfer", AccountController, :transfer
  end
end
