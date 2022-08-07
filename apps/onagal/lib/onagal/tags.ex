defmodule Onagal.Tags do
  @moduledoc """
  Documentation for `Onagal`.
  """

  alias Onagal.Repo
  alias Onagal.Tags.{Tag, Tagset, Gallery}

  import Ecto.Query

  def list_tags do
    Repo.all(Tag)
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

  def list_galleries do
    Repo.all(Gallery)
  end

  def get_gallery!(id), do: Repo.get!(Gallery, id)

  def create_gallery(attrs \\ %{}) do
    %Gallery{}
    |> Gallery.changeset(attrs)
    |> Repo.insert()
  end

  def change_gallery(%Gallery{} = gallery, attrs \\ %{}) do
    Gallery.changeset(gallery, attrs)
  end

  def update_gallery(%Gallery{} = gallery, attrs) do
    gallery
    |> Gallery.changeset(attrs)
    |> Repo.update()
  end

  def delete_gallery(%Gallery{} = gallery) do
    Repo.delete(gallery)
  end

  def update_gallery_tags(gallery, tags) do
    gallery
    |> Repo.preload(:tags)
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:tags, tags)
    |> Repo.update()
  end

  def get_gallery_tags(gallery) do
    Repo.all(Ecto.assoc(gallery, :tags))
  end
end
