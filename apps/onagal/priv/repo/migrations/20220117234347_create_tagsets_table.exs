defmodule Onagal.Persist.Repo.Migrations.CreateTagsetsTable do
  use Ecto.Migration

  def change do
    create table(:tagsets) do
      add :name, :string
      add :description, :string

      timestamps()
    end

    create unique_index(:tagsets, :name)
  end
end
