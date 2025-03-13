defmodule MySuperApp.Repo.Migrations.CreatePages do
  use Ecto.Migration

  def change do
    create table(:pages) do
      add :name, :string
      add :site_id, references(:sites, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:pages, [:name])
  end
end
