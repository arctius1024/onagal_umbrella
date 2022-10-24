defmodule OnagalWeb.Resolvers.Tags do
  alias Onagal.Tags

  def list_tags(_args, _context) do
    {:ok, Tags.list_tags()}
  end

  def get_tag(%{id: id}, _context) do
    {:ok, Tags.get_tag!(id)}
  end

  def create_tag(args, _context) do
    case Tags.create_tag(args) do
      {:ok, %Tags.Tag{} = tag} -> {:ok, tag}
      {:error, changeset} -> {:error, inspect(changeset.errors)}
    end
  end
end
