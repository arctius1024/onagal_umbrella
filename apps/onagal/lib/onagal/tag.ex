defmodule Onagal.Tag do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tags" do
    field(:name, :string)

    timestamps()

    ## TODO: on_replace may be wrong
    # , on_replace: :delete
    many_to_many(:images, Onagal.Image, join_through: "images_tags")
    # , on_replace: :delete
    many_to_many(:tagsets, Onagal.Tagset, join_through: "tags_tagsets")
  end

  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
