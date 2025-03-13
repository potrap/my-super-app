defmodule MySuperApp.Blog.Tag do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  schema "tags" do
    field :name, :string

    many_to_many :posts, MySuperApp.Blog.Post, join_through: "posts_tags"

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
