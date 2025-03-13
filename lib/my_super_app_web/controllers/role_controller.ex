defmodule MySuperAppWeb.RoleController do
  use MySuperAppWeb, :controller

  alias MySuperApp.{CasinosAdmins, Accounts}
  alias MySuperApp.Role

  action_fallback MySuperAppWeb.FallbackController

  def index(conn, %{"user_id" => user_id}) do
    case Accounts.get_user_role(user_id) do
      {:ok, role} ->
        render(conn, :show, role: role)

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "User not found"})

      {:error, :no_role_assigned} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "User has no role assigned"})
    end
  end

  def index(conn, %{"name" => name}) do
    case CasinosAdmins.get_role_by_name(name) do
      {:ok, role} ->
        render(conn, :show, role: role)

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Role not found"})
    end
  end

  def index(conn, _params) do
    roles = CasinosAdmins.get_all_roles_by_id()
    render(conn, :index, roles: roles)
  end

  def create(conn, %{"role" => role_params}) do
    case CasinosAdmins.create_role(role_params) do
      {:ok, %Role{} = role} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", ~p"/api/roles/#{role.id}")
        |> render(:show, role: role)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: changeset})
    end
  end

  def show(conn, %{"id" => id}) do
    case CasinosAdmins.get_role(id) do
      %{} = role ->
        render(conn, :show, role: role)

      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Role not found"})
    end
  end

  def update(conn, %{"id" => id, "role" => role_params}) do
    case CasinosAdmins.update_role(id, role_params) do
      {:ok, %Role{} = role} ->
        render(conn, :show, role: role)

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Role not found"})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: changeset})
    end
  end

  def delete(conn, %{"id" => id}) do
    case CasinosAdmins.delete_role(id) do
      {:ok, %Role{}} ->
        send_resp(conn, :no_content, "")

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Role not found"})
    end
  end
end
