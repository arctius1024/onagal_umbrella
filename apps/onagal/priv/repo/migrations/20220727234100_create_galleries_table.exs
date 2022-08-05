defmodule Onagal.Persist.Repo.Migrations.CreateGalleriesTable do
  use Ecto.Migration

  def change do
    create table(:galleries) do
      add :name, :string

      timestamps()
    end

    create unique_index(:galleries, :name)
  end
end
