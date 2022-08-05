defmodule Onagal.Persist.Repo.Migrations.CreateImagesTags do
  use Ecto.Migration

  def change do
    create table(:galleries_tags) do
      add :gallery_id, references(:galleries)
      add :tag_id, references(:tags)
    end

    create unique_index(:galleries_tags, [:gallery_id, :tag_id])
  end
end
