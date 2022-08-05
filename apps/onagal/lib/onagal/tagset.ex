defmodule Onagal.Tagset do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tagsets" do
    field(:name, :string)
    field(:description, :string)

    timestamps()

    ## TODO: on_replace may be wrong
    # , on_replace: :delete
    many_to_many(:tags, Onagal.Tag, join_through: "tags_tagsets")
  end

  @valid_params ~w(name description)a

  @doc false
  def changeset(tagset, attrs) do
    tagset
    |> cast(attrs, @valid_params)
    |> validate_required(@valid_params)
  end
end
