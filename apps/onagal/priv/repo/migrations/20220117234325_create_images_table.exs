defmodule Onagal.Persist.Repo.Migrations.CreateImagesTable do
  use Ecto.Migration

  def change do
    create table(:images) do
      add(:current_name, :string)
      add(:original_name, :string)
      add(:location, :string, size: 512)

      add(:size, :integer)
      add(:digest, :string)

      add(:file_type, :string)

      timestamps()
    end

    # Filenames can be non-uniqe (potentially), but path/filename must be unique
    # This is more for legacy support pre-import, ultimate goal is to
    # fully manage files in a path-optimized way to balance directory access times
    # name first so we can do a quick check if it exists once we're automated without a full index lookup
    create(unique_index(:images, [:current_name, :location]))

    # When importing a new file, we want to verify that the size+digest combination is unique
    # by putting the size field first we can also do a partial index lookup (postgres ftw)
    # to fast-drop files that don't match on size before needing a full digest computation
    create(index(:images, [:size, :digest]))
  end
end
