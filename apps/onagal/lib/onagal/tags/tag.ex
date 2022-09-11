defmodule Onagal.Tags.Tag do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tags" do
    field(:name, :string)

    timestamps()

    ## TODO: on_replace may be wrong
    # , on_replace: :delete
    many_to_many(:images, Onagal.Images.Image, join_through: "images_tags", on_replace: :delete)
    # , on_replace: :delete
    many_to_many(:tagsets, Onagal.Tags.Tagset, join_through: "tags_tagsets", on_replace: :delete)
  end

  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
