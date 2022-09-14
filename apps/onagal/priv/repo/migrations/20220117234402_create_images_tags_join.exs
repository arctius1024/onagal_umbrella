defmodule Onagal.Persist.Repo.Migrations.CreateImagesTagsTable do
  use Ecto.Migration

  def change do
    create table(:images_tags) do
      add :tag_id, references(:tags, on_delete: :delete_all)
      add :image_id, references(:images, on_delete: :delete_all)
    end

    create unique_index(:images_tags, [:tag_id, :image_id])
  end
end
