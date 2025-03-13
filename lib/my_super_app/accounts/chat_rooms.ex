defmodule MySuperApp.Accounts.ChatRooms do
  @moduledoc false

  import Ecto.Query, warn: false
  alias MySuperApp.{Repo, ChatRoom, Accounts, User}
  import Ecto.Changeset

  def get_user_chat_rooms(%User{} = user) do
    user
    |> Repo.preload(:chat_rooms)
    |> Map.get(:chat_rooms)
  end

  def get_chatroom!(id) do
    Repo.get!(ChatRoom, id)
  end

  def create_chatroom(attrs) do
    user = Accounts.get_user!(attrs.user_id)

    %ChatRoom{}
    |> ChatRoom.changeset(attrs)
    |> put_assoc(:members, [user])
    |> Repo.insert()
  end

  def get_chatroom_by!(opts) do
    Repo.get_by!(ChatRoom, opts)
  end

  def join(user, chatroom) do
    chatroom = Repo.preload(chatroom, :members)

    chatroom
    |> ChatRoom.changeset(%{})
    |> put_assoc(:members, [user | chatroom.members])
    |> Repo.update()
  end
end
