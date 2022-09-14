defmodule Onagal.Persist.Repo.Migrations.CreateTagsTagsetsTable do
  use Ecto.Migration

  def change do
    create table(:tags_tagsets) do
      add :tag_id, references(:tags, on_delete: :delete_all)
      add :tagset_id, references(:tagsets, on_delete: :delete_all)
    end

    create unique_index(:tags_tagsets, [:tag_id, :tagset_id])
  end
end
