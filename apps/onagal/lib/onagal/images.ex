defmodule Onagal.Images do
  @moduledoc """
  Documentation for `Onagal`.
  """

  alias Onagal.Repo
  alias Onagal.Images.Image

  import Ecto.Query

  @managed_path System.get_env("MANAGE_DIR")
  @managed_thumb_path System.get_env("THUMB_DIR")

  @managed_web_path "/managed_images"
  @managed_web_thumb_path "/thumbs"

  def list_images do
    Image |> Repo.all()
  end

  @doc """
    params: used for skrivener
    tags: list of tags to return paginated image list
  """
  def paginate_images_with_tags(params, tags) do
    # page =
    #   from(image in Image,
    #     preload: [:tags],
    #     join: tag in assoc(image, :tags),
    #     on: tag.name in ^tags,
    #     group_by: image.id
    #   )
    images_matching_tag_list(params, tags)
  end

  def paginate_images(params) do
    Repo.paginate(Image, params)
  end

  def images_summary do
    from(t in Image, select: {t.current_path, t.location})
    |> Repo.all()
  end

  def get_image!(id), do: Repo.get!(Image, id)

  @spec get_prev_image(integer, map) :: any
  def get_prev_image(id, %{"tags" => ""} = filter) do
    query =
      from i in Image,
        where: i.id < ^id,
        order_by: [desc: i.id],
        limit: 1

    Repo.one(query) || get_last_image()
  end

  @doc """
    FIX: This needs to be refactored to share query basics with the normal index image tag
    fiter. Yes this does not handle wrap arounds.
  """
  def get_prev_image(id, %{"tags" => tags} = filter) do
    image_ids = image_ids_matching_tags(tags)

    query =
      from(image in Image,
        where: image.id in ^image_ids and image.id < ^id,
        preload: [:tags],
        # join: tag in assoc(image, :tags),
        order_by: [desc: image.id],
        group_by: image.id,
        limit: 1
      )

    Repo.one(query) || get_last_image()
  end

  def get_next_image(id, %{"tags" => ""} = filter) do
    query =
      from i in Image,
        where: i.id > ^id,
        preload: [:tags],
        order_by: i.id,
        limit: 1

    Repo.one(query) || get_first_image()
  end

  @doc """
    FIX: This needs to be refactored to share query basics with the normal index image tag
    fiter. Yes this does not handle wrap arounds.
  """
  def get_next_image(id, %{"tags" => tags} = filter) do
    image_ids = image_ids_matching_tags(tags)

    query =
      from(image in Image,
        where: image.id in ^image_ids and image.id > ^id,
        preload: [:tags],
        # join: tag in assoc(image, :tags),
        order_by: image.id,
        group_by: image.id,
        limit: 1
      )

    Repo.one(query) || get_first_image()
  end

  def get_first_image() do
    query =
      from i in Image,
        preload: [:tags],
        order_by: i.id,
        limit: 1

    Repo.one(query)
  end

  def get_last_image() do
    query =
      from i in Image,
        preload: [:tags],
        order_by: [desc: i.id],
        limit: 1

    Repo.one(query)
  end

  def get_image_by_file_path(path, name) do
    # query =
    #   from(i in Image,
    #     where: i.location == ^path and i.current_name == ^name
    #   )

    # Repo.one!(query)
    Repo.get_by(Image, location: path, current_name: name)
  end

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
        {:error,
         Repo.get_by!(Onagal.Images.Image,
           current_name: attrs.current_name,
           location: attrs.location
         )}

      # All other errors (including existing+another error)
      {:error, changeset} ->
        {:error, changeset}
    end
  end

  # defp image_exists?({:image, {_, [constraint: :unique, constraint_name: _]}}), do: true
  # defp image_exists?(_), do: false

  def change_image(%Image{} = image, attrs \\ %{}) do
    Image.changeset(image, attrs)
  end

  def ui_change_image(%Image{} = image, attrs \\ %{}) do
    Image.ui_edit_changeset(image, attrs)
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
        # join: tag in assoc(image, :tags),
        group_by: image.id
      )

    Repo.all(query)
  end

  def match_image(size, digest) do
    Repo.get_by(Image, size: size, digest: digest)
  end

  def full_image_path(image) do
    Path.join(image.location, image.current_name)
  end

  def generate_thumbnail(image) do
    Thumbnex.create_thumbnail(
      full_image_path(image),
      system_thumbnail_image_path(image),
      max_width: 160,
      max_height: 160
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

  @doc """
    params: used for skrivener
    tags: list of tags to return paginated image list
  """
  def images_matching_tag_list(_, []), do: []

  def images_matching_tag_list(params, tag_name_list) when is_list(tag_name_list) do
    image_ids = image_ids_matching_tags(tag_name_list)

    query =
      from(image in Image,
        where: image.id in ^image_ids,
        preload: [:tags],
        # join: tag in assoc(image, :tags),
        group_by: image.id
      )

    Repo.paginate(query, params)
  end

  def images_matching_tag_list(_, _), do: []

  @doc """
    given a list of tags, return a list of image ids that are associated with ALL
    the tags in the list (not just any/one/some)
    tags: list of tags
  """
  defp image_ids_matching_tags(tag_name_list) do
    sql_safe_tag_name_list = "'" <> Enum.join(tag_name_list, "','") <> "'"

    {:ok, %Postgrex.Result{rows: rows} = _} =
      Onagal.Repo.query(
        "SELECT * FROM images_with_all_tag_names(array[#{sql_safe_tag_name_list}]);"
      )

    Enum.flat_map(rows, fn v -> v end)
  end
end
