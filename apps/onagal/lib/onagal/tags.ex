defmodule Onagal.Tags do
  @moduledoc """
  Documentation for `Onagal`.
  """

  alias Onagal.Repo
  alias Onagal.Tags.{Tag, Tagset, Filterset}

  import Ecto.Query

  def list_tags do
    Repo.all(Tag)
  end

  def list_tags_as_options do
    Enum.map(Repo.all(Tag), fn tag ->
      {String.to_atom(tag.name), tag.name}
    end)
  end

  def get_tag!(id), do: Repo.get!(Tag, id)

  def create_tag(attrs \\ %{}) do
    %Tag{}
    |> Tag.changeset(attrs)
    |> Repo.insert()
  end

  def get_tag_by_name(tag_name) do
    Repo.get_by(Tag, name: tag_name)
  end

  def change_tag(%Tag{} = tag, attrs \\ %{}) do
    Tag.changeset(tag, attrs)
  end

  def update_tag(%Tag{} = tag, attrs) do
    tag
    |> Tag.changeset(attrs)
    |> Repo.update()
  end

  def delete_tag(%Tag{} = tag) do
    Repo.delete(tag)
  end

  def list_tags_by_id(tag_ids) do
    Tag
    |> where([tag], tag.id in ^tag_ids)
    |> Repo.all()
  end

  @spec list_tags_by_name(any) :: any
  def list_tags_by_name(tag_names) when is_list(tag_names) do
    Tag
    |> where([tag], tag.name in ^tag_names)
    |> Repo.all()
  end

  def get_image_tags(image) do
    Repo.all(Ecto.assoc(image, :tags))
  end

  def update_image_tags(image, tags) do
    image
    |> Repo.preload(:tags)
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:tags, tags)
    |> Repo.update()
  end

  def add_tag_to_image(image, tag_id) when is_integer(tag_id),
    do: add_tag_to_image(image, get_tag!(tag_id))

  def add_tag_to_image(image, tag_name) when is_binary(tag_name),
    do: add_tag_to_image(image, get_tag_by_name(tag_name))

  def add_tag_to_image(image, tag) do
    image
    |> Repo.preload(:tags)
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:tags, [tag | image.tags])
    |> Repo.update()
  end

  def clear_image_tags(image), do: update_image_tags(image, [])

  def upsert_image_tags_by_id(image, tag_ids) when is_list(tag_ids) do
    tags = list_tags_by_id(tag_ids)

    with {:ok, _struct} <- update_image_tags(image, tags) do
      {:ok, Onagal.Images.get_image_with_tags(image.id)}
    else
      error ->
        error
    end
  end

  def upsert_image_tags_by_name(image, tag_names) when is_list(tag_names) do
    tags = list_tags_by_name(tag_names)

    with {:ok, _struct} <- update_image_tags(image, tags) do
      {:ok, Onagal.Images.get_image_with_tags(image.id)}
    else
      error ->
        error
    end
  end

  # -------------------------------------------------------------------------------------

  def list_tagsets do
    Repo.all(Tagset)
  end

  def get_tagset!(id), do: Repo.get!(Tagset, id)

  def create_tagset(attrs \\ %{}) do
    %Tagset{}
    |> Tagset.changeset(attrs)
    |> Repo.insert()
  end

  def change_tagset(%Tagset{} = tagset, attrs \\ %{}) do
    Tagset.changeset(tagset, attrs)
  end

  def update_tagset(%Tagset{} = tagset, attrs) do
    tagset
    |> Tagset.changeset(attrs)
    |> Repo.update()
  end

  def delete_tagset(%Tagset{} = tagset) do
    tagset
    |> Onagal.Repo.preload(:tags)
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:tags, [])
    |> Repo.update!()
    |> Repo.delete()
  end

  @spec update_tagset_tags(nil | [%{optional(atom) => any}] | %{optional(atom) => any}, any) ::
          any
  def update_tagset_tags(tagset, tags) do
    tagset
    |> Repo.preload(:tags)
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:tags, tags)
    |> Repo.update()
  end

  def get_tagset_tags(tagset) do
    Repo.all(Ecto.assoc(tagset, :tags))
  end

  # -------------------------------------------------------------------------------------

  def list_filtersets do
    Repo.all(Filterset)
  end

  def get_filterset!(id), do: Repo.get!(Filterset, id)

  def create_filterset(attrs \\ %{}) do
    %Filterset{}
    |> Filterset.changeset(attrs)
    |> Repo.insert()
  end

  def change_filterset(%Filterset{} = filterset, attrs \\ %{}) do
    Filterset.changeset(filterset, attrs)
  end

  def update_filterset(%Filterset{} = filterset, attrs) do
    filterset
    |> Filterset.changeset(attrs)
    |> Repo.update()
  end

  def delete_filterset(%Filterset{} = filterset) do
    Repo.delete(filterset)
  end

  def update_filterset_tags(filterset, tags) do
    filterset
    |> Repo.preload(:tags)
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:tags, tags)
    |> Repo.update()
  end

  def get_filterset_tags(filterset) do
    Repo.all(Ecto.assoc(filterset, :tags))
  end
end
