# Banking Api

API that allows to deposit, withdraw and transfer money between accounts.

## You need
- Elixir
- Docker
- This repo cloned
```
# Enter the command below to clone the repository
git clone https://github.com/biancaguzenski/banking_api
```

## Running this project
```
docker-compose up -d

mix deps.get

mix setup

mix phx.server
```

## Running tests
```
mix test
```