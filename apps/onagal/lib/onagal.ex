defmodule Onagal do
  @moduledoc """
  Documentation for `Onagal`.
  """

  alias Onagal.{Repo, Image, Tag, Tagset, Gallery}
  import Ecto.Query

  def list_images do
    Image |> Repo.all()
  end

  def images_summary do
    from(t in Image, select: {t.current_path, t.location})
    |> Repo.all()
  end

  def get_image!(id), do: Repo.get!(Image, id)

  def get_image_by_file_path(path, name) do
    # query =
    #   from(i in Image,
    #     where: i.location == ^path and i.current_name == ^name
    #   )

    # Repo.one!(query)
    Repo.get_by(Image, location: path, current_name: name)
  end

  def add_image(attrs \\ %{}) do
    %Image{}
    |> Image.changeset(attrs)
    # (on_conflict: :nothing)
    |> Repo.insert()
    |> case do
      {:ok, image} ->
        {:ok, image}

      {:error, _} ->
        {:error,
         Repo.get_by!(Onagal.Image,
           current_name: attrs.current_name,
           location: attrs.location
         )}
    end
  end

  def update_image(%Image{} = image, attrs) do
    image
    |> Image.changeset(attrs)
    |> Repo.update()
  end

  def delete_image(nil), do: {:error, :no_such_object}

  def delete_image(%Image{} = image) do
    Repo.delete(image)
  end

  def get_image_with_tags(id) do
    query =
      from(image in Image,
        where: image.id == ^id,
        preload: [:tags],
        join: tag in assoc(image, :tags),
        group_by: image.id
      )

    Repo.all(query)
  end

  def match_image(size, digest) do
    Repo.get_by(Image, size: size, digest: digest)
  end

  # -------------------------------------------------------------------------------------

  def list_tags do
    Repo.all(Tag)
  end

  def get_tag!(id), do: Repo.get!(Tag, id)

  def create_tag(attrs \\ %{}) do
    %Tag{}
    |> Tag.changeset(attrs)
    |> Repo.insert()
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
      {:ok, get_image_with_tags(image.id)}
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
