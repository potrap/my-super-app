defmodule MySuperApp.Blog.Picture do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  schema "pictures" do
    field :path, :string
    field :file_name, :string
    field :upload_at, :utc_datetime
    belongs_to :post, MySuperApp.Blog.Post
  end

  @doc false
  def changeset(picture, attrs) do
    picture
    |> cast(attrs, [:file_name, :path, :upload_at, :post_id])
    |> validate_required([:file_name, :path, :upload_at])
  end
end
