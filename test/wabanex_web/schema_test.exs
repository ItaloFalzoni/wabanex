defmodule Wabanex.SchemaTest do
  use WabanexWeb.ConnCase, async: true

  alias Wabanex.User
  alias Wabanex.Users.Create

  describe "users queries" do
    test "when a valid id is given, returns the user", %{conn: conn} do
      params = %{email: "italo@test.com", name: "Italo", password: "123"}

      {:ok, %User{id: user_id}} = Create.call(params)

      query = """
        {
          getUser(id: "#{user_id}"){
            name
            email
          }
        }
      """

      response =
        conn
        |> post("/api/graphql", %{query: query})
        |> json_response(:ok)

      expected_response = %{
        "data" => %{
          "getUser" => %{
            "email" => "italo@test.com",
            "name" => "Italo"
          }
        }
      }

      assert response == expected_response
    end

    test "when a wrong id is given, returns the error", %{conn: conn} do
      params = %{email: "italo@test.com", name: "Italo", password: "123"}

      {:ok, %User{id: user_id}} = Create.call(params)

      query = """
        {
          getUser(id: "09a45dbf-3665-4435-8ec0-fd9e6649e25d"){
            name
            email
          }
        }
      """

      response =
        conn
        |> post("/api/graphql", %{query: query})
        |> json_response(:ok)

      expected_response = %{
        "data" => %{"getUser" => nil},
        "errors" => [
          %{
            "locations" => [%{"column" => 5, "line" => 2}],
            "message" => "User not found",
            "path" => ["getUser"]
          }
        ]
      }

      assert response == expected_response
    end
  end

  describe "users mutations" do
    test "when all params are valid, creates a user", %{conn: conn} do
      mutation = """
        mutation {
          createUser(input: {
            name: "Italo2", email: "italo2@teste.com", password: "123"
          }) {
            id
            name
          }
        }
      """

      response =
        conn
        |> post("/api/graphql", %{query: mutation})
        |> json_response(:ok)

      assert %{"data" => %{"createUser" => %{"id" => _id, "name" => "Italo2"}}} = response
    end
  end
end
