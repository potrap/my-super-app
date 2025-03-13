defmodule MySuperAppWeb.UserController do
  use MySuperAppWeb, :controller

  alias MySuperApp.Accounts
  alias MySuperApp.User

  action_fallback MySuperAppWeb.FallbackController

  def index(conn, %{"email" => email}) do
    case Accounts.get_user_by_email(email) do
      %{} = user ->
        render(conn, :show, user: user)

      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "User not found"})
    end
  end

  def index(conn, %{"username" => username}) do
    case Accounts.get_user_by_name(username) do
      %{} = user ->
        render(conn, :show, user: user)

      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "User not found"})
    end
  end

  def index(conn, %{"role_id" => role_id}) do
    case Accounts.get_user_by_role_id(role_id) do
      %{} = user ->
        render(conn, :show, user: user)

      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "User not found"})
    end
  end

  def index(conn, _params) do
    users = Accounts.get_all_users_by_id()
    render(conn, :index, users: users)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, %User{} = user} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", ~p"/api/users/#{user.id}")
        |> render(:show, user: user)

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def show(conn, %{"id" => id}) do
    case Accounts.get_user(id) do
      %{} = user ->
        render(conn, :show, user: user)

      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "User not found"})
    end
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    case Accounts.update_user(id, user_params) do
      {:ok, user} ->
        render(conn, :show, user: user)

      {:error, "Couldn't update superadmin!"} ->
        conn
        |> put_status(:forbidden)
        |> json(%{error: "Couldn't update superadmin!"})

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "User not found"})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: changeset})
    end
  end

  def delete(conn, %{"id" => id}) do
    with %{} = user <- Accounts.get_user(id),
         {:ok, %User{}} <- Accounts.delete_user(user) do
      send_resp(conn, :no_content, "")
    else
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "User not found"})

      {:error, reason} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: reason})
    end
  end
end
