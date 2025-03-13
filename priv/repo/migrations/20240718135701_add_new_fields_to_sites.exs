defmodule MySuperApp.Repo.Migrations.AddNewFieldsToSites do
  use Ecto.Migration

  def change do
    alter table(:sites) do
      add :key, :string
      add :value, :integer
      add :status, :string
      add :image, :string
    end
  end
end
