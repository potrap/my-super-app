defmodule MySuperApp.Repo.Migrations.CreateSites do
  use Ecto.Migration

  def change do
    create table(:sites) do
      add :name, :string
      add :operator_id, references(:operators, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:sites, [:name])
  end
end
