defmodule MySuperAppWeb.UserControllerTest do
  use MySuperAppWeb.ConnCase

  alias MySuperApp.Accounts

  describe "index/2" do
    test "lists all users", %{conn: conn} do
      user_attrs = %{username: "testuser", email: "test@example.com", password: "password123"}
      {:ok, _user} = Accounts.register_user(user_attrs)

      conn = get(conn, "/api/users")
      assert json_response(conn, 200)["data"] != nil
      assert length(json_response(conn, 200)["data"]) > 0

      assert Enum.any?(json_response(conn, 200)["data"], fn user ->
               user["email"] == "test@example.com"
             end)
    end
  end

  describe "create/2" do
    test "creates a user and renders the user", %{conn: conn} do
      user_attrs = %{username: "testuser", email: "test@example.com", password: "password123"}

      conn = post(conn, "/api/users", user: user_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]
      assert Accounts.get_user(id)
    end

    test "returns error when user is invalid", %{conn: conn} do
      conn = post(conn, "/api/users", user: %{username: ""})
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "show/2" do
    test "shows the user", %{conn: conn} do
      user = %{username: "showuser", email: "show@example.com", password: "password123"}
      {:ok, user} = Accounts.register_user(user)

      conn = get(conn, "/api/users/#{user.id}")
      assert json_response(conn, 200)["data"]["username"] == user.username
    end

    test "returns error for non-existent user", %{conn: conn} do
      conn = get(conn, "/api/users/99999")
      assert json_response(conn, 404)["error"] == "User not found"
    end
  end

  describe "update/2" do
    test "updates the user and renders the user", %{conn: conn} do
      user_attrs = %{username: "updateuser", email: "update@example.com", password: "password123"}
      {:ok, user} = Accounts.register_user(user_attrs)

      conn = put(conn, "/api/users/#{user.id}", user: %{username: "updateduser"})

      assert %{"id" => id} = json_response(conn, 200)["data"]
      assert id == user.id
      assert Accounts.get_user(user.id).username == "updateduser"
    end

    test "returns error for non-existent user", %{conn: conn} do
      conn = put(conn, "/api/users/99999", user: %{username: "willfail"})
      assert json_response(conn, 404)["error"] == "User not found"
    end
  end

  describe "delete/2" do
    test "deletes the user", %{conn: conn} do
      user = %{username: "deleteuser", email: "delete@example.com", password: "password123"}
      {:ok, user} = Accounts.register_user(user)

      conn = delete(conn, "/api/users/#{user.id}")
      assert response(conn, 204)
      refute Accounts.get_user(user.id)
    end

    test "returns error for non-existent user", %{conn: conn} do
      conn = delete(conn, "/api/users/99999")
      assert json_response(conn, 404)["error"] == "User not found"
    end
  end
end
