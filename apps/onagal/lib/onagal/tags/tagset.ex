defmodule Onagal.Tags.Tagset do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tagsets" do
    field(:name, :string)
    field(:description, :string)

    timestamps()

    ## TODO: on_replace may be wrong
    # , on_replace: :delete
    many_to_many(:tags, Onagal.Tags.Tag, join_through: "tags_tagsets", on_replace: :delete)
  end

  @valid_params ~w(name description)a

  @doc false
  def changeset(tagset, attrs) do
    IO.puts("tagset :changeset")
    IO.inspect(tagset)
    IO.inspect(attrs)

    tagset =
      tagset
      |> cast(attrs, @valid_params)
      |> validate_required(@valid_params)

    if Map.get(attrs, :tags),
      do: tagset |> put_assoc(:tags, attrs.tags, required: false),
      else: tagset

    if Map.get(attrs, "tags"),
      do: tagset |> put_assoc(:tags, attrs["tags"], required: false),
      else: tagset
  end
end
