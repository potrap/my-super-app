defmodule MySuperApp.Blog.Post do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  @derive {Jason.Encoder, only: [:id, :title, :body, :inserted_at, :updated_at]}

  schema "posts" do
    field :title, :string
    field :body, :string
    field :published_at, :utc_datetime
    belongs_to :user, MySuperApp.User
    has_one :picture, MySuperApp.Blog.Picture

    many_to_many :tags, MySuperApp.Blog.Tag, join_through: "posts_tags", on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :body, :user_id, :published_at])
    |> validate_required([:title, :body])
  end
end
