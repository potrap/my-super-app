defmodule MySuperAppWeb.PostController do
  use MySuperAppWeb, :controller

  alias MySuperApp.Blog
  alias MySuperApp.Blog.Post
  alias MySuperApp.Accounts
  alias MySuperApp.User

  action_fallback MySuperAppWeb.FallbackController

  def index(conn, params) do
    render(conn, :index, posts: Blog.list_posts(params))
  end

  @spec create(any(), nil | maybe_improper_list() | map()) ::
          {:error, Ecto.Changeset.t()} | Plug.Conn.t()
  def create(conn, params) do
    with %User{} <- Accounts.get_user(params["user_id"]),
         {:ok, %Post{} = post} <-
           Blog.create_post(params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/posts/#{post}")
      |> render(:show, post: post)
    else
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "User with id #{params["user_id"]} not found"})

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def show(conn, %{"id" => id}) do
    case Blog.get_post(id) do
      %Post{} = post ->
        render(conn, :show, post: post)

      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Post with id #{id} not found"})
    end
  end

  def update(conn, params) do
    with %Post{} <- Blog.get_post(params["id"]),
         {:ok, %Post{} = updated_post} <- Blog.update_post(params) do
      render(conn, :show, post: updated_post)
    else
      {:error, :not_found} ->
        {:error, :not_found}

      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Couldn't update post", reason: reason})
    end
  end

  def delete(conn, %{"id" => id}) do
    with %Post{} = post <- Blog.get_post(id),
         {:ok, %Post{}} <- Blog.delete_post(post) do
      conn
      |> put_status(:no_content)
      |> send_resp(:no_content, "")
    else
      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Post with id #{id} not found"})

      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Unable to delete post", reason: reason})
    end
  end
end
