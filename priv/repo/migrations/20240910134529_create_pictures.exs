defmodule MySuperApp.Repo.Migrations.CreatePictures do
  use Ecto.Migration

  def change do
    create table(:pictures) do
      add :file_name, :string
      add :path, :string
      add :upload_at, :utc_datetime
      add :post_id, references(:posts, on_delete: :delete_all)
    end

    create index(:pictures, [:post_id])
  end
end
