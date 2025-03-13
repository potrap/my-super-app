defmodule MySuperApp.Repo.Migrations.CreateRoles do
  use Ecto.Migration

  def change do
    create table(:roles) do
      add :name, :string
      add :operator_id, references(:operators, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:roles, [:name])
  end
end
