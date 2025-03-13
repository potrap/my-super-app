defmodule MySuperAppWeb.RoleControllerTest do
  use MySuperAppWeb.ConnCase

  alias MySuperApp.{Accounts, Role, Repo}

  @valid_role_attrs %{name: "Admin123"}

  setup do
    {:ok, user} =
      Accounts.register_user(%{
        username: "Super_Admin",
        email: "superadmin@gmail.com",
        password: "123456789"
      })

    {:ok, role} =
      %Role{}
      |> Role.changeset(%{name: "Admin", permissions: ["read", "write"]})
      |> Repo.insert()

    {:ok, user: user, role: role}
  end

  describe "index/2" do
    test "lists all roles", %{conn: conn} do
      conn = get(conn, ~p"/api/roles")
      assert json_response(conn, 200)["data"] != []
    end

    test "shows the role for a valid user_id", %{conn: conn, user: user, role: role} do
      Accounts.update_user(user.id, %{"role_id" => role.id})

      conn = get(conn, ~p"/api/roles", %{"user_id" => user.id})
      assert %{"name" => "Admin"} = json_response(conn, 200)["data"]
    end

    test "returns error if no role is assigned to user", %{conn: conn, user: user} do
      conn = get(conn, ~p"/api/roles", %{"user_id" => user.id})
      assert json_response(conn, 404)["error"] == "User has no role assigned"
    end
  end

  describe "create/2" do
    test "creates role with valid data", %{conn: conn} do
      conn = post(conn, ~p"/api/roles", role: @valid_role_attrs)
      assert %{"name" => "Admin123"} = json_response(conn, 201)["data"]
    end
  end

  describe "show/2" do
    test "shows the role by id", %{conn: conn, role: role} do
      conn = get(conn, ~p"/api/roles/#{role.id}")
      assert %{"name" => "Admin"} = json_response(conn, 200)["data"]
    end

    test "returns error when role is not found", %{conn: conn} do
      conn = get(conn, ~p"/api/roles/-1")
      assert json_response(conn, 404)["error"] == "Role not found"
    end
  end

  describe "update/2" do
    test "updates role with valid data", %{conn: conn, role: role} do
      conn = put(conn, ~p"/api/roles/#{role.id}", role: %{name: "SuperAdmin"})
      assert %{"name" => "SuperAdmin"} = json_response(conn, 200)["data"]
    end
  end

  describe "delete/2" do
    test "deletes a role", %{conn: conn, role: role} do
      conn = delete(conn, ~p"/api/roles/#{role.id}")
      assert response(conn, 204)
    end

    test "returns error when role is not found", %{conn: conn} do
      conn = delete(conn, ~p"/api/roles/-1")
      assert json_response(conn, 404)["error"] == "Role not found"
    end
  end
end
