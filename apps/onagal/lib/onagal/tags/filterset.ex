defmodule Onagal.Tags.Filterset do
  use Ecto.Schema
  import Ecto.Changeset

  schema "filtersets" do
    field(:name, :string)
    field(:description, :string)

    timestamps()

    ## TODO: on_replace may be wrong
    # , on_replace: :delete
    many_to_many(:tags, Onagal.Tags.Tag, join_through: "filtersets_tags", on_replace: :delete)
  end

  @valid_params ~w(name description)a

  @doc false
  def changeset(filterset, attrs) do
    IO.puts("filterset :changeset")

    filterset =
      filterset
      |> cast(attrs, @valid_params)
      |> validate_required(@valid_params)

    if Map.get(attrs, :tags),
      do: filterset |> put_assoc(:tags, attrs.tags, required: false),
      else: filterset

    if Map.get(attrs, "tags"),
      do: filterset |> put_assoc(:tags, attrs["tags"], required: false),
      else: filterset
  end
end
