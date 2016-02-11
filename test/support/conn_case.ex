defmodule Fyler.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  imports other functionality to make it easier
  to build and query models.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest

      alias Fyler.Repo
      import Ecto
      import Ecto.Changeset
      import Ecto.Query, only: [from: 1, from: 2]

      import Fyler.Router.Helpers
      import Fyler.ConnCase
      import Fyler.Factory

      # The default endpoint for testing
      @endpoint Fyler.Endpoint
    end
  end

  setup tags do
    unless tags[:async] do
      Ecto.Adapters.SQL.restart_test_transaction(Fyler.Repo, [])
    end

    {:ok, conn: Phoenix.ConnTest.conn()}
  end

  def api_conn() do
    Phoenix.ConnTest.conn()
  end

  def api_conn(token, realm \\ "Bearer") do
    Phoenix.ConnTest.conn()
    |> Phoenix.ConnTest.put_req_header("authorization", realm <> " " <> token)
  end
end
