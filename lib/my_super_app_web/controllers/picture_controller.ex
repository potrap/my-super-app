defmodule MySuperAppWeb.PictureController do
  use MySuperAppWeb, :controller

  alias MySuperApp.Pictures
  alias MySuperApp.Blog.Picture

  action_fallback MySuperAppWeb.FallbackController

  def index(conn, params) do
    pictures = Pictures.list_pictures(params)
    render(conn, :index, paths: pictures)
  end

  def show(conn, %{"id" => id}) do
    case path = Pictures.get_picture(id).path do
      nil -> {:error, :not_found}
      _pic -> render(conn, :show, path: path)
    end
  end

  def create(conn, %{"file" => %Plug.Upload{path: file_path, filename: file_name}}) do
    with {:ok, %Cloudex.UploadedImage{secure_url: url_path}} <- Cloudex.upload(file_path),
         {:ok, picture} <-
           Pictures.create_picture(%{
             "path" => url_path,
             "file_name" => file_name
           }) do
      render(conn, :show, picture: picture)
    else
      _ ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Failed to upload picture to Cloudinary"})
    end
  end

  def update(conn, %{"id" => id} = params) do
    with picture = %Picture{} <- Pictures.get_picture(id),
         {:ok, attrs} <- build_attrs(params),
         {:ok, updated_picture} <- Pictures.update_picture(picture, attrs) do
      render(conn, :show, picture: updated_picture)
    else
      nil ->
        {:error, :not_found}

      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Couldn't update post", reason: reason})
    end
  end

  def delete(conn, %{"id" => id}) do
    with picture = %Picture{} <- Pictures.get_picture(id),
         {:ok, %Picture{}} <- Pictures.delete_picture(picture) do
      conn
      |> put_status(:no_content)
      |> send_resp(:no_content, "")
    else
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Picture with id #{id} not found"})

      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Unable to delete picture", reason: reason})
    end
  end

  defp build_attrs(%{"file" => %Plug.Upload{path: file_path, filename: file_name}} = params) do
    case Cloudex.upload(file_path) do
      {:ok, %Cloudex.UploadedImage{secure_url: url_path}} ->
        {:ok,
         %{
           "path" => url_path,
           "file_name" => format_file_name(file_name),
           "post_id" => params["post_id"]
         }}

      {:error, _} ->
        {:error, :upload_failed}
    end
  end

  defp build_attrs(params) do
    {:ok, Map.take(params, ["file_name", "post_id"])}
  end

  def by_post(conn, %{"post_id" => post_id}) do
    pictures = Pictures.get_pictures_by_post(post_id)
    render(conn, :index, pictures: pictures)
  end

  defp format_file_name(name) do
    name
    |> String.split(".")
    |> List.first()
  end
end
