defmodule Onagal.Images.Image do
  use Ecto.Schema
  import Ecto.Changeset

  schema "images" do
    field(:current_name, :string)
    field(:original_name, :string)
    field(:location, :string)
    field(:digest, :string)
    field(:size, :integer)
    field(:file_type, :string)

    timestamps()

    ## TODO: on_replace may be wrong
    # , on_replace: :delete
    many_to_many(:tags, Onagal.Tags.Tag, join_through: "images_tags")
  end

  @required_fields ~w(current_name original_name location)a
  @optional_fields ~w(digest size file_type)a
  # @allowed_file_types

  def changeset(record, params \\ :empty) do
    record
    |> cast(params, @required_fields ++ @optional_fields)
    |> unique_constraint([:current_name, :location])
    |> unique_constraint([:size, :digest])
    |> validate_required(@required_fields)
  end
end
