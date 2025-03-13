defmodule MySuperApp.Site do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "sites" do
    field :name, :string
    field :key, :string
    field :value, :integer
    field :status, :string
    field :image, :string
    has_many :pages, MySuperApp.Page
    belongs_to :operator, MySuperApp.Operator

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :key, :value, :status, :operator_id, :image])
    |> validate_required([:name, :key, :value, :status])
    |> validate_length(:name, min: 3, max: 50)
  end
end
