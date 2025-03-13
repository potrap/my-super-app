defmodule MySuperApp.Repo.Migrations.CreateUsersAssoc do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :operator_id, references(:operators, on_delete: :nilify_all)
      add :role_id, references(:roles, on_delete: :nilify_all)
    end
  end
end
