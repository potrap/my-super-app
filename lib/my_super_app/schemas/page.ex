defmodule MySuperApp.Page do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "pages" do
    field :name, :string

    belongs_to :site, MySuperApp.Site

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :site_id])
    |> validate_required([:name, :site_id])
    |> validate_length(:name, min: 3, max: 25)
    |> assoc_constraint(:site)
  end
end
