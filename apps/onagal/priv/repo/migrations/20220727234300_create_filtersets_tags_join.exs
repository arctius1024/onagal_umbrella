defmodule Onagal.Persist.Repo.Migrations.CreateFiltersetsTags do
  use Ecto.Migration

  def change do
    create table(:filtersets_tags) do
      add :filterset_id, references(:filtersets, on_delete: :delete_all)
      add :tag_id, references(:tags, on_delete: :delete_all)
    end

    create unique_index(:filtersets_tags, [:filterset_id, :tag_id])
  end
end
