defmodule MySuperApp.ChatRoom do
  @moduledoc """
  Room Page
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "chat_rooms" do
    field :name, :string
    field :description, :string
    field :invite_code, :string

    belongs_to :user, MySuperApp.User

    many_to_many :members, MySuperApp.User, join_through: "chatroom_members"

    timestamps()
  end

  def changeset(room, attrs, opts \\ []) do
    room
    |> cast(attrs, [:name, :description, :invite_code, :user_id])
    |> validate_required([:name, :description, :user_id])
    |> maybe_generate_invite_token(opts)
  end

  defp maybe_generate_invite_token(changeset, opts) do
    generate_invite? = Access.get(opts, :generate_invite?, false)

    room_is_new? =
      changeset
      |> get_field(:id)
      |> is_nil()

    if generate_invite? or room_is_new? do
      put_change(changeset, :invite_code, random_string(10))
    else
      changeset
    end
  end

  defp random_string(num) do
    num
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64()
    |> binary_part(0, num)
  end
end
