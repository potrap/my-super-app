defmodule MySuperApp.Repo.Migrations.CreateRooms do
  use Ecto.Migration

  def change do
    create table(:chat_rooms) do
      add :name, :string, null: false
      add :description, :text, null: false
      add :invite_code, :string, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:chat_rooms, [:user_id, :name])
  end
end
