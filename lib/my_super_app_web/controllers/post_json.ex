defmodule MySuperAppWeb.PostJSON do
  alias MySuperApp.Blog.Post
  alias MySuperApp.Blog.Tag

  @doc """
  Renders a list of posts.
  """
  def index(%{posts: posts}) do
    %{data: for(post <- posts, do: data(post))}
  end

  @doc """
  Renders a single post.
  """
  def show(%{post: post}) do
    %{data: data(post)}
  end

  defp data(%Post{} = post) do
    %{
      id: post.id,
      title: post.title,
      body: post.body,
      author: post.user.username,
      tags: for(tag <- post.tags, do: data(tag)),
      created_at: post.inserted_at,
      updated_at: post.updated_at
    }
  end

  defp data(%Tag{} = tag) do
    %{
      name: tag.name
    }
  end

  defp data(_) do
    "Post with such id doesn't exist"
  end
end
