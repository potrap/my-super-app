defmodule MySuperApp.Repo.Migrations.AddPostsTags do
  use Ecto.Migration

  def change do
    create table(:posts_tags, primary_key: false) do
      add :post_id, references(:posts)
      add :tag_id, references(:tags)
    end

    create unique_index(:posts_tags, [:post_id, :tag_id])
  end
end
