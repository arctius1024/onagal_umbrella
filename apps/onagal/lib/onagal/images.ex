defmodule Onagal.Images do
  @moduledoc """
  Documentation for `Onagal`.
  """

  alias Onagal.Repo
  alias Onagal.Images.Image
  
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
end
