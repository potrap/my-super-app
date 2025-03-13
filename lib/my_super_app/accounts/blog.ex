defmodule MySuperApp.Blog do
  @moduledoc """
  The Blog context.
  """

  import Ecto.Query, warn: false
  alias MySuperApp.Accounts
  alias MySuperApp.{Repo, User}

  alias MySuperApp.Blog.{Post, Tag, Picture}

  def get_user_by_name(name) do
    Repo.get_by(User, username: name)
  end

  def authors_name() do
    posts = Repo.all(from u in Post, select: u.user_id)

    authors =
      for post <- posts do
        user = Accounts.get_user(post)
        user.username
      end

    Enum.uniq(authors)
  end

  def get_all_posts_by_id() do
    Post
    |> Repo.all()
    |> Repo.preload(:tags)
    |> Enum.map(&Map.from_struct(&1))
    |> Enum.sort_by(& &1.id, :asc)
  end

  def get_all_posts_by_published_at() do
    Post
    |> Repo.all()
    |> Repo.preload(:tags)
    |> Enum.map(&Map.from_struct(&1))
    |> Enum.sort_by(
      fn post ->
        {post.published_at || :infinity,
         if post.published_at == nil do
           post.id
         else
           -post.id
         end}
      end,
      :asc
    )
  end

  def get_all_posts_by_author(id) do
    Post
    |> Repo.all()
    |> Enum.map(&Map.from_struct(&1))
    |> Enum.filter(fn x -> x.user_id == id end)
    |> Enum.sort_by(& &1.id, :asc)
  end

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  def list_posts(params \\ %{}) do
    Post
    |> Repo.all()
    |> Repo.preload([:user, :tags])
    |> filter_posts(params)
  end

  def posts_for_select do
    Repo.all(Post)
    |> Enum.map(fn post ->
      [key: post.title, value: post.id]
    end)
  end

  def get_posts_without_pictures do
    from(p in Post, left_join: pic in Picture, on: pic.post_id == p.id, where: is_nil(pic.id))
    |> Repo.all()
    |> Enum.map(fn post ->
      [key: post.title, value: post.id]
    end)
  end

  def filter_posts(posts, params) do
    posts
    |> filter_by_user(params["user"])
    |> filter_by_tags(params["tags"])
    |> filter_by_date(params["from"], params["to"])
    |> Enum.sort_by(& &1.inserted_at, sort_order(params["sort_by_date"]))
  end

  defp filter_by_user(posts, nil), do: posts

  defp filter_by_user(posts, username) do
    Enum.filter(posts, fn post ->
      post.user.username == username
    end)
  end

  defp filter_by_tags(posts, nil), do: posts

  defp filter_by_tags(posts, tags) when is_list(tags) do
    tags = Enum.map(tags, &String.trim(&1, "\""))

    Enum.filter(posts, fn post ->
      tag_names = Enum.map(post.tags, & &1.name)
      Enum.all?(tags, &(&1 in tag_names))
    end)
  end

  defp filter_by_tags(posts, _), do: posts

  defp filter_by_date(posts, nil, nil), do: posts

  defp filter_by_date(posts, from, nil) do
    Enum.filter(posts, fn post ->
      DateTime.compare(post.inserted_at, format_date(:from, from)) == :gt
    end)
  end

  defp filter_by_date(posts, nil, to) do
    Enum.filter(posts, fn post ->
      DateTime.compare(post.inserted_at, format_date(:to, to)) == :lt
    end)
  end

  defp filter_by_date(posts, from, to) do
    posts
    |> filter_by_date(from, nil)
    |> filter_by_date(nil, to)
  end

  defp sort_order(nil), do: :asc
  defp sort_order("desc"), do: :desc
  defp sort_order(_), do: :asc

  defp format_date(:from, date) do
    {:ok, formatted_from, _} = DateTime.from_iso8601(date <> "T00:00:00Z")
    formatted_from
  end

  defp format_date(:to, date) do
    {:ok, formatted_to, _} = DateTime.from_iso8601(date <> "T23:59:59Z")
    formatted_to
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(id), do: Repo.get!(Post, id)

  def get_post(id) do
    case Repo.get(Post, id) do
      nil -> {:error, :not_found}
      post -> Repo.preload(post, [:user, :tags])
    end
  end

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{field: value})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_post(attrs) do
    post_tags = attrs["post_tags"] || []
    tags = Repo.all(from t in Tag, where: t.name in ^post_tags)
    attrs = Map.delete(attrs, "post_tags")

    changeset =
      %Post{}
      |> Post.changeset(attrs)
      |> Ecto.Changeset.put_assoc(:tags, tags)

    case Repo.insert(changeset) do
      {:ok, %Post{} = post} ->
        {:ok, get_post(post.id)}

      {:error, changeset_error} ->
        {:error, changeset_error}
    end
  end

  @doc """
  Updates a post.

  ## Examples

      iex> update_post(post, %{field: new_value})
      {:ok, %Post{}}

      iex> update_post(post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_post(attrs) do
    post = get_post(attrs["id"])

    changeset =
      if attrs["post_tags"] != nil do
        tags = Repo.all(from t in Tag, where: t.name in ^attrs["post_tags"])

        post
        |> Post.changeset(attrs)
        |> Ecto.Changeset.put_assoc(:tags, tags)
      else
        post
        |> Post.changeset(attrs)
      end

    case Repo.update(changeset) do
      {:ok, _post} ->
        {:ok, get_post(attrs["id"])}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Deletes a post.

  ## Examples

      iex> delete_post(post)
      {:ok, %Post{}}

      iex> delete_post(post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_post(%Post{} = post) do
    {:ok, post_result} =
      Repo.transaction(fn ->
        from(pt in "posts_tags", where: pt.post_id == ^post.id)
        |> Repo.delete_all()

        Repo.delete(post)
      end)

    post_result
  end

  def delete_post(nil), do: {:error, :not_found}

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{data: %Post{}}

  """
  def change_post(%Post{} = post, attrs \\ %{}) do
    Post.changeset(post, attrs)
  end

  def create_tag(attrs \\ %{}) do
    %Tag{}
    |> Tag.changeset(attrs)
    |> Repo.insert()
  end

  def list_tags() do
    Tag
    |> Repo.all()
  end

  def get_tag_by_name(name) do
    Repo.get_by(Tag, name: name)
  end
end
