defmodule Onagal.Images.ImageTag do
  use Ecto.Schema
  import Ecto.Changeset

  schema "images_tags" do
    belongs_to :image, Onagal.Images.Image
    belongs_to :tag, Onagal.Tags.Tag
  end

  @required_fields ~w(image tag)a

  # def changeset(record, params) do
  #   record
  #   |> cast(params, @required_fields)
  #   |> unique_constraint(@required_fields)
  #   |> validate_required(@required_fields)
  # end
end
