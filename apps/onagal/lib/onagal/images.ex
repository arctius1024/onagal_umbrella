defmodule Onagal.Images do
  @moduledoc """
  Documentation for `Onagal`.
  """

  alias Phoenix.HTML.Tag
  alias Onagal.Repo
  alias Onagal.Images.Image

  import Ecto.Query

  @managed_path System.get_env("MANAGE_DIR")
  @managed_thumb_path System.get_env("THUMB_DIR")

  @managed_web_path "/managed_images"
  @managed_web_thumb_path "/thumbs"

  @doc """
    Returns a list of all images
      This isn't normally used - defer to the pagination system
  """
  def list_images do
    Image |> Repo.all()
  end

  @doc """
    Return a list of images based on the list of ids provided
    Not paginated, prefer that interface for most operations.
  """
  def list_images_by_id(id_list) when is_list(id_list) do
    query =
      from(image in Image,
        where: image.id in ^id_list,
        order_by: image.id
      )

    Repo.all(query)
  end

  def get_image!(id), do: Repo.get!(Image, id)

  def get_first_image(), do: Image |> first() |> Repo.one()

  def get_image_by_name(name) do
    Repo.get_by(Image, current_name: name)
  end

  def get_image_by_original_name(name) do
    Repo.get_by(Image, original_name: name)
  end

  def get_image_by_file_path(path, name) do
    Repo.get_by(Image, location: path, current_name: name)
  end

  ############################################################
  # Updating/adding images
  ############################################################

  def create_image(attrs \\ %{}), do: add_image(attrs)

  def add_image(attrs \\ %{}) do
    %Image{}
    |> Image.changeset(attrs)
    # (on_conflict: :nothing)
    |> Repo.insert()
    |> case do
      {:ok, image} ->
        {:ok, image}

      # If image already exists AND that is the _only_ error, find the existing image
      # and return that instead of creating
      {:error,
       %Ecto.Changeset{
         action: _,
         changes: _,
         errors: [current_name: {_, [constraint: :unique, constraint_name: _]}],
         data: _,
         valid?: false
       }} ->
        {:error, get_image_by_file_path(attrs.location, attrs.current_name)}

      # All other errors (including existing+another error)
      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def change_image(%Image{} = image, attrs \\ %{}) do
    Image.changeset(image, attrs)
  end

  def ui_change_image(%Image{} = image, attrs \\ %{}) do
    Image.ui_edit_changeset(image, attrs)
  end

  def ui_update_image(%Image{} = image, attrs \\ %{}) do
    image
    |> Image.ui_edit_changeset(attrs)
    |> Repo.update()
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

  #########################################################
  # Thumbnails
  #########################################################

  def full_image_path(image) do
    Path.join(image.location, image.current_name)
  end

  def generate_thumbnail(image) do
    Thumbnex.create_thumbnail(
      full_image_path(image),
      system_thumbnail_image_path(image),
      max_width: 120,
      max_height: 120
    )
  end

  @doc """
    Given an image - return the web path for it
  """
  def web_image_path(%Image{} = image) do
    # FIX: handle these paths in a better way
    Regex.replace(~r/^#{@managed_path}/, full_image_path(image), @managed_web_path)
  end

  def web_image_path(_), do: "/images/invalid.png"

  @doc """
    Given an image - return the system path for it's thumbnail
  """
  def system_thumbnail_image_path(%Image{} = image) do
    Regex.replace(~r/^#{@managed_path}/, full_image_path(image), @managed_thumb_path)
  end

  def system_thumbnail_image_path(_), do: "/images/invalid.png"

  @doc """
    Given an image - return the web path for it's thumbnail
  """
  def web_thumbnail_image_path(%Image{} = image) do
    Regex.replace(~r/^#{@managed_path}/, full_image_path(image), @managed_web_thumb_path)
  end

  def web_thumbnail_image_path(_), do: "/images/invalid.png"

  def resolve_thumbnail_path(image) do
    if !File.exists?(system_thumbnail_image_path(image)),
      do: generate_thumbnail(image)

    web_thumbnail_image_path(image)
  end

  ######################################
  # +TAGS
  ######################################

  def get_image_with_tags(id) do
    query =
      from(image in Image,
        where: image.id == ^id,
        preload: [:tags]
      )

    Repo.one(query)
  end

  def list_images_with_tags_from_ids(id_list) when is_list(id_list) do
    query =
      from(image in Image,
        where: image.id in ^id_list,
        preload: [:tags],
        order_by: image.id
      )

    Repo.all(query)
  end

  # def get_first_image_with_tags() do
  #   query =
  #     from i in Image,
  #       preload: [:tags],
  #       order_by: i.id,
  #       limit: 1

  #   Repo.one(query)
  # end

  # def get_last_image_with_tags() do
  #   query =
  #     from i in Image,
  #       preload: [:tags],
  #       order_by: [desc: i.id],
  #       limit: 1

  #   Repo.one(query)
  # end
end
