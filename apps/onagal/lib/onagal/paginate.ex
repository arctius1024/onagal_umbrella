defmodule Onagal.Paginate do
  @moduledoc """
  Documentation for `Onagal.Paginate`.
  """

  alias Onagal.Images

  def list_images(params), do: Images.paginate_images(params)
  def list_images(params, tags), do: Images.paginate_images(params, tags)

  @doc """
    TODO: code-smell here.
    iterating on this - consider detecting cases and using those to determine next/prev page/image
  """
  def resolve_image_tuples(page, image, params, selected_filters) do
    IO.puts("resolve_image_tuple")

    cond do
      is_very_first_image?(page, image) && is_very_last_image?(page, image) ->
        IO.puts("only image")
        get_image_tuple(:only_image, image, page, params, selected_filters)

      is_very_first_image?(page, image) ->
        IO.puts("very first image")
        get_image_tuple(:first_image, image, page, params, selected_filters)

      is_very_last_image?(page, image) ->
        IO.puts("very last image")
        get_image_tuple(:last_image, image, page, params, selected_filters)

      on_prev_page?(page, image) ->
        IO.puts("prev page image")
        get_image_tuple(:prev_page, image, page, params, selected_filters)

      on_next_page?(page, image) ->
        IO.puts("next page image")
        get_image_tuple(:next_page, image, page, params, selected_filters)

      first_on_page?(page, image) ->
        IO.puts("first on page image")
        get_image_tuple(:prev_boundary, image, page, params, selected_filters)

      last_on_page?(page, image) ->
        IO.puts("last on page image")
        get_image_tuple(:next_boundary, image, page, params, selected_filters)

      true ->
        IO.puts("current page image")
        get_image_tuple(:current, image, page, params, selected_filters)
    end
  end

  defp next_image_on_page(page, image) do
    image_index = Enum.find_index(page.entries, fn img -> img.id == image.id end)
    Enum.at(page.entries, image_index + 1)
  end

  defp prev_image_on_page(page, image) do
    image_index = Enum.find_index(page.entries, fn img -> img.id == image.id end)
    Enum.at(page.entries, image_index - 1)
  end

  defp prev_page(page, params, selected_filters) do
    list_images(Map.merge(params, %{page: page.page_number - 1}), selected_filters)
  end

  defp next_page(page, params, selected_filters) do
    list_images(Map.merge(params, %{page: page.page_number + 1}), selected_filters)
  end

  defp get_image_tuple(:only_image, image, page, _params, _selected_filters) do
    prev_image = image
    next_image = image
    {prev_image, image, next_image, page}
  end

  defp get_image_tuple(:first_image, image, page, _params, _selected_filters) do
    prev_image = image
    next_image = next_image_on_page(page, image)
    {prev_image, image, next_image, page}
  end

  defp get_image_tuple(:last_image, image, page, _params, _selected_filters) do
    prev_image = prev_image_on_page(page, image)
    next_image = image
    {prev_image, image, next_image, page}
  end

  defp get_image_tuple(:prev_page, _image, page, params, selected_filters) do
    next_image = hd(page.entries)
    page = prev_page(page, params, selected_filters)
    image = List.last(page.entries)
    prev_image = prev_image_on_page(page, image)
    {prev_image, image, next_image, page}
  end

  defp get_image_tuple(:next_page, _image, page, params, selected_filters) do
    prev_image = List.last(page.entries)
    page = next_page(page, params, selected_filters)
    image = hd(page.entries)
    next_image = next_image_on_page(page, image)
    {prev_image, image, next_image, page}
  end

  defp get_image_tuple(:prev_boundary, image, page, params, selected_filters) do
    prev_page = prev_page(page, params, selected_filters)
    prev_image = List.last(prev_page.entries)
    next_image = next_image_on_page(page, image)
    {prev_image, image, next_image, page}
  end

  defp get_image_tuple(:next_boundary, image, page, params, selected_filters) do
    next_page = next_page(page, params, selected_filters)
    prev_image = prev_image_on_page(page, image)
    next_image = hd(next_page.entries)
    {prev_image, image, next_image, page}
  end

  defp get_image_tuple(:current, image, page, _params, _selected_filters) do
    prev_image = prev_image_on_page(page, image)
    next_image = next_image_on_page(page, image)
    {prev_image, image, next_image, page}
  end

  defp is_very_first_image?(page, image) do
    page.page_number == 1 && image.id == hd(page.entries).id
  end

  defp is_very_last_image?(page, image) do
    page.page_number == page.total_pages && image.id == List.last(page.entries).id
  end

  defp on_prev_page?(page, image) do
    image.id < hd(page.entries).id
  end

  defp on_next_page?(page, image) do
    image.id > List.last(page.entries).id
  end

  defp first_on_page?(page, image) do
    image.id == hd(page.entries).id
  end

  defp last_on_page?(page, image) do
    image.id == List.last(page.entries).id
  end
end
