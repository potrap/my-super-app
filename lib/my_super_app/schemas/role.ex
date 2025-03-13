defmodule MySuperApp.Role do
  @moduledoc """
  Role page
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "roles" do
    field :name, :string
    belongs_to :operator, MySuperApp.Operator
    has_many :users, MySuperApp.User

    timestamps()
  end

  def changeset(role, attrs) do
    role
    |> cast(attrs, [:name, :operator_id])
    |> validate_required([:name])
    |> validate_length(:name, min: 3, max: 25)
    |> unique_constraint(:name)
  end
end
