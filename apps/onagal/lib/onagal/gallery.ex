defmodule Onagal.Gallery do
  use Ecto.Schema
  import Ecto.Changeset

  schema "galleries" do
    field(:name, :string)

    timestamps()

    ## TODO: on_replace may be wrong
    # , on_replace: :delete
    many_to_many(:tags, Onagal.Tag, join_through: "galleries_tags")
  end

  @valid_params ~w(name)a

  @doc false
  def changeset(tagset, attrs) do
    tagset
    |> cast(attrs, @valid_params)
    |> validate_required(@valid_params)
  end
end
