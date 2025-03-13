defmodule MySuperApp.Operator do
  @moduledoc """
  Operator Page
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "operators" do
    field :name, :string
    has_many :roles, MySuperApp.Role
    has_many :users, MySuperApp.User
    has_many :sites, MySuperApp.Site

    timestamps(type: :utc_datetime)
  end

  def changeset(operator, attrs) do
    operator
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate_length(:name, min: 3, max: 25)
    |> unique_constraint(:name)
  end
end
