defmodule MySuperApp.Pictures do
  @moduledoc """
  The Blog context.
  """

  import Ecto.Query, warn: false
  alias MySuperApp.Repo

  alias MySuperApp.Blog.Picture

  @doc """
  Returns the list of pictures.

  ## Examples

      iex> list_pictures()
      [%Picture{}, ...]

  """
  def list_pictures(params \\ %{}) do
    from(p in Picture,
      left_join: post in assoc(p, :post),
      left_join: user in assoc(post, :user),
      select: %{
        id: p.id,
        path: p.path,
        file_name: p.file_name,
        upload_at: p.upload_at,
        post_id: post.id,
        post_title: post.title,
        author: user.username,
        email: user.email
      }
    )
    |> Repo.all()
    |> filter_pictures(params)
  end

  def filter_pictures(pictures, params) do
    pictures
    |> filter_by_date(params["from"], params["to"])
    |> filter_by_author_name(params["author_name"])
    |> filter_by_author_email(params["author_email"])
    |> Enum.sort_by(& &1.upload_at, fn a, b ->
      case sort_order(params["sort_by_date"]) do
        :asc -> DateTime.compare(a, b) == :lt
        _ -> DateTime.compare(a, b) == :gt
      end
    end)
  end

  defp filter_by_author_name(pictures, nil), do: pictures

  defp filter_by_author_name(pictures, name) do
    pictures
    |> Enum.filter(fn picture ->
      (picture.author != nil &&
         String.downcase(picture.author) == String.downcase(name)) || false
    end)
  end

  defp filter_by_author_email(pictures, nil), do: pictures

  defp filter_by_author_email(pictures, email) do
    pictures
    |> Enum.filter(fn picture -> picture.email == email end)
  end

  defp filter_by_date(pictures, nil, nil), do: pictures

  defp filter_by_date(pictures, from, nil) do
    Enum.filter(pictures, fn picture ->
      DateTime.compare(picture.upload_at, format_date(:from, from)) == :gt
    end)
  end

  defp filter_by_date(pictures, nil, to) do
    Enum.filter(pictures, fn picture ->
      DateTime.compare(picture.upload_at, format_date(:to, to)) == :lt
    end)
  end

  defp filter_by_date(pictures, from, to) do
    pictures
    |> filter_by_date(from, nil)
    |> filter_by_date(nil, to)
  end

  defp sort_order(nil), do: :desc
  defp sort_order("asc"), do: :asc
  defp sort_order(_), do: :desc

  defp format_date(:from, date) do
    {:ok, formatted_from, _} = DateTime.from_iso8601(date <> "T00:00:00Z")
    formatted_from
  end

  defp format_date(:to, date) do
    {:ok, formatted_to, _} = DateTime.from_iso8601(date <> "T23:59:59Z")
    formatted_to
  end

  def get_select_pictures do
    from(p in Picture, where: is_nil(p.post_id))
    |> Repo.all()
    |> Enum.map(fn picture ->
      [key: picture.file_name, value: picture.id]
    end)
  end

  @doc """
  Gets a single picture.

  Raises `Ecto.NoResultsError` if the Picture does not exist.

  ## Examples

      iex> get_picture!(123)
      %Picture{}

      iex> get_picture!(456)
      ** (Ecto.NoResultsError)

  """
  def get_picture!(id) do
    Repo.get!(Picture, id)
  end

  def get_picture(id) do
    Repo.get(Picture, id)
  end

  def get_picture_with_post(id) do
    from(p in Picture,
      left_join: post in assoc(p, :post),
      left_join: user in assoc(post, :user),
      where: p.id == ^id,
      select: %{
        id: p.id,
        path: p.path,
        file_name: p.file_name,
        upload_at: p.upload_at,
        post_id: post.id,
        post_title: post.title,
        author_username: user.username,
        author_email: user.email
      }
    )
    |> Repo.one()
  end

  def get_picture_by_post(post_id), do: Repo.get_by(Picture, post_id: post_id)

  def get_pictures_by_post(post_id) do
    Repo.all(from p in Picture, where: p.post_id == ^post_id)
  end

  @doc """
  Creates a picture.

  ## Examples

      iex> create_picture(%{field: value})
      {:ok, %Picture{}}

      iex> create_picture(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_picture(attrs) do
    upload_at =
      NaiveDateTime.utc_now()
      |> NaiveDateTime.add(3 * 60 * 60, :second)
      |> NaiveDateTime.truncate(:second)

    attrs = %{
      "path" => attrs["path"],
      "file_name" =>
        attrs["file_name"]
        |> format_file_name,
      "upload_at" => upload_at
    }

    %Picture{}
    |> Picture.changeset(attrs)
    |> Repo.insert()
  end

  defp format_file_name(name) do
    name
    |> String.split(".")
    |> List.first()
  end

  @doc """
  Updates a picture.

  ## Examples

      iex> update_picture(picture, %{field: new_value})
      {:ok, %Picture{}}

      iex> update_picture(picture, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_picture(picture, attrs) do
    if attrs["post_id"] != nil do
      remove_post_id(picture.id, attrs["post_id"])

      picture
      |> Picture.changeset(attrs)
      |> Repo.update()
    else
      {:error, "Invalid arguments"}
    end
  end

  def remove_post_id(id, post_id) do
    case Repo.get_by(Picture, post_id: post_id) do
      nil ->
        {:error, :not_found}

      record ->
        if record.id != id do
          record
          |> Picture.changeset(%{post_id: nil})
          |> Repo.update()
        end
    end
  end

  @doc """
  Deletes a picture.

  ## Examples

      iex> delete_picture(picture)
      {:ok, %Picture{}}

      iex> delete_picture(picture)
      {:error, %Ecto.Changeset{}}

  """
  def delete_picture(%Picture{} = picture) do
    Repo.delete(picture)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking picture changes.

  ## Examples

      iex> change_picture(picture)
      %Ecto.Changeset{data: %Picture{}}

  """
  def change_picture(%Picture{} = picture, attrs \\ %{}) do
    Picture.changeset(picture, attrs)
  end
end
