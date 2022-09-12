defmodule Onagal.Repo.Migrations.CreateUsersAuthTables do
  use Ecto.Migration

  def change do
    create index(:images_tags, :image_id)
    create index(:filtersets_tags, :tag_id)
    create index(:tags_tagsets, :tagset_id)
  end
end
