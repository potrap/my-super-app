defmodule HonestChat.Repo.Migrations.CreateRoomMembers do
  use Ecto.Migration

  def change do
    create table(:chatroom_members) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :chat_room_id, references(:chat_rooms, on_delete: :delete_all), null: false
    end

    create unique_index(:chatroom_members, [:user_id, :chat_room_id])
  end
end
