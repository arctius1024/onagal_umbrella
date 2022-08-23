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
      image_in_prev_page?(images, image) -> false
      image_in_next_page?(images, image) -> false
      true -> true
    end
  end

  def image_in_prev_page?(images, image) do
    image.id < hd(images.entries).id
  end

  def image_in_next_page?(images, image) do
    image.id > List.last(images.entries).id
  end

  @doc """
    Given a page of images, filter tags and a starting image, determine which page the image is in
  """
  def find_image_page(images, tags, image) do
    IO.puts("paginate find_image_page")

    params = %{page: images.page_number, page_size: images.page_size}

    cond do
      image_in_page?(images, image) ->
        {images.page_number, images}

      image_in_prev_page?(images, image) ->
        IO.puts("prev_page")

        find_image_page(
          Images.paginate_images(
            Map.merge(params, %{page: images.page_number - 1}),
            tags
          ),
          tags,
          image
        )

      image_in_next_page?(images, image) ->
        IO.puts("next_page")

        find_image_page(
          Images.paginate_images(
            Map.merge(params, %{page: images.page_number + 1}),
            tags
          ),
          tags,
          image
        )
    end
  end

  @doc """
   Find prev image - including if its in the prev page of images
  """
  def get_prev_image(params, tag_filter, images, image) do
    case check_for_prev_image(images, image) do
      {:ok, prev_image} ->
        {:ok, prev_image}

      {:error, :start_boundary} ->
        {:ok, image}

      {:error, :page_boundary} ->
        prev_images =
          Images.paginate_images(Map.merge(params, %{page: images.page_number - 1}), tag_filter)

        {:ok, List.last(prev_images.entries)}

      {:error, :next_page} ->
        {:error, :next_page}

      {:error, :prev_page} ->
        {:error, :prev_page}
    end
  end

  def check_for_prev_image(images, image) do
    IO.puts("check_for_prev_image")

    cond do
      image.id < hd(images.entries).id ->
        {:error, :prev_page}

      image.id > List.last(images.entries).id ->
        {:error, :next_page}

      image.id == hd(images.entries).id && images.page_number == 1 ->
        {:error, :start_boundary}

      image.id == hd(images.entries).id ->
        {:error, :page_boundary}

      true ->
        image_index = Enum.find_index(images.entries, fn img -> img.id == image.id end)
        {:ok, Enum.at(images.entries, image_index - 1)}
    end
  end

  @doc """
   Find next image - including if its in the next page of images
  """
  def get_next_image(params, tag_filter, images, image) do
    IO.puts("get_next_image")

    case check_for_next_image(images, image) do
      {:ok, next_image} ->
        {:ok, next_image}

      {:error, :end_boundary} ->
        {:ok, image}

      {:error, :page_boundary} ->
        next_images =
          Images.paginate_images(Map.merge(params, %{page: images.page_number + 1}), tag_filter)

        {:ok, hd(next_images.entries)}

      {:error, :next_page} ->
        {:error, :next_page}

      {:error, :prev_page} ->
        {:error, :prev_page}
    end
  end

  def check_for_next_image(images, image) do
    IO.puts("check_for_next_image")

    cond do
      image.id < hd(images.entries).id ->
        {:error, :prev_page}

      image.id > List.last(images.entries).id ->
        {:error, :next_page}

      image.id == List.last(images.entries).id && images.total_pages == images.page_number ->
        {:error, :end_boundary}

      image.id == List.last(images.entries).id ->
        {:error, :page_boundary}

      true ->
        image_index = Enum.find_index(images.entries, fn img -> img.id == image.id end)
        {:ok, Enum.at(images.entries, image_index + 1)}
    end
  end
end
