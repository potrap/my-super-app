defmodule MySuperApp.RightMenu do
  @moduledoc """
  Right menu
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "right_menu" do
    field :title, :string
  end

  def changeset(right_menu, attrs) do
    right_menu
    |> cast(attrs, [:title])
    |> validate_required([:title])
    |> validate_length(:title, min: 4)
  end
end
