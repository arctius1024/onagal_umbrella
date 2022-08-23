defmodule Onagal.Paginate do
  @moduledoc """
  Documentation for `Onagal.Paginate`.
  """

  alias Onagal.Repo
  alias Onagal.Images

  import Ecto.Query

  @doc """
    Given a list of tags - return the min and max ids associated with that list
    Intentionally ignoring page parameters as we don't care for this
  """
  def get_min_max_image_ids_for_tags(tags) do
    case first_page = Images.paginate_images_with_tags(%{page: 1}, tags) do
      [] ->
        nil

      _ ->
        last_page = Images.paginate_images_with_tags(%{page: first_page.total_pages}, tags)

        min_id = hd(first_page.entries).id
        max_id = List.last(last_page.entries).id
        [min_id, max_id]
    end
  end

  @doc """
    Given current image list, and an image, determine if the image is in the list
  """
  def image_in_page?(images, image) do
    cond do
      image.id < hd(images.entries).id -> false
      image.id > List.last(images.entries).id -> false
      true -> true
    end
  end
end
