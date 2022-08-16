defmodule Onagal.Persist.Repo.Migrations.CreateFiltersetsTable do
  use Ecto.Migration

  def change do
    create table(:filtersets) do
      add :name, :string

      timestamps()
    end

    create unique_index(:filtersets, :name)
  end
end
