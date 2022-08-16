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

  def upsert_image_tags(image, tag_ids) when is_list(tag_ids) do
    tags = list_tags_by_id(tag_ids)

    with {:ok, _struct} <-
           image
           |> update_image_tags(tags) do
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
    Repo.delete(tagset)
  end

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
