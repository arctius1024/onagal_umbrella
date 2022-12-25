defmodule Onagal.Paginate do
  @moduledoc """
  Documentation for `Onagal.Paginate`.
  """
  import Ecto.Query

  alias Onagal.Repo
  alias Onagal.Images
  alias Onagal.Images.Image
  alias Onagal.Tags

  # def list_images(params), do: #paginate_images(params)
  # def list_images(params, tags), do: paginate_images(params, tags)

  @doc """
    TODO: code-smell here.
    iterating on this - consider detecting cases and using those to determine next/prev page/image
  """

  # def resolve_image_tuples(page, image, params, selected_filters) do
  #   IO.puts("resolve_image_tuple")

  #   cond do
  #     is_very_first_image?(page, image) && is_very_last_image?(page, image) ->
  #       get_image_tuple(:only_image, image, page, params, selected_filters)

  #     is_very_first_image?(page, image) ->
  #       get_image_tuple(:first_image, image, page, params, selected_filters)

  #     is_very_last_image?(page, image) ->
  #       get_image_tuple(:last_image, image, page, params, selected_filters)

  #     on_prev_page?(page, image) ->
  #       get_image_tuple(:prev_page, image, page, params, selected_filters)

  #     on_next_page?(page, image) ->
  #       get_image_tuple(:next_page, image, page, params, selected_filters)

  #     first_on_page?(page, image) ->
  #       get_image_tuple(:prev_boundary, image, page, params, selected_filters)

  #     last_on_page?(page, image) ->
  #       get_image_tuple(:next_boundary, image, page, params, selected_filters)

  #     true ->
  #       get_image_tuple(:current, image, page, params, selected_filters)
  #   end
  # end

  # defp next_image_on_page(page, image) do
  #   image_index = Enum.find_index(page.entries, fn img -> img.id == image.id end)
  #   Enum.at(page.entries, image_index + 1)
  # end

  # defp prev_image_on_page(page, image) do
  #   image_index = Enum.find_index(page.entries, fn img -> img.id == image.id end)
  #   Enum.at(page.entries, image_index - 1)
  # end

  # defp prev_page(page, params, selected_filters) do
  #   list_images(Map.merge(params, %{page: page.page_number - 1}), selected_filters)
  # end

  # defp next_page(page, params, selected_filters) do
  #   list_images(Map.merge(params, %{page: page.page_number + 1}), selected_filters)
  # end

  # defp get_image_tuple(:only_image, image, page, _params, _selected_filters) do
  #   prev_image = image
  #   next_image = image
  #   {prev_image, image, next_image, page}
  # end

  # defp get_image_tuple(:first_image, image, page, _params, _selected_filters) do
  #   prev_image = image
  #   next_image = next_image_on_page(page, image)
  #   {prev_image, image, next_image, page}
  # end

  # defp get_image_tuple(:last_image, image, page, _params, _selected_filters) do
  #   prev_image = prev_image_on_page(page, image)
  #   next_image = image
  #   {prev_image, image, next_image, page}
  # end

  # defp get_image_tuple(:prev_page, _image, page, params, selected_filters) do
  #   next_image = hd(page.entries)
  #   page = prev_page(page, params, selected_filters)
  #   image = List.last(page.entries)
  #   prev_image = prev_image_on_page(page, image)
  #   {prev_image, image, next_image, page}
  # end

  # defp get_image_tuple(:next_page, _image, page, params, selected_filters) do
  #   prev_image = List.last(page.entries)
  #   page = next_page(page, params, selected_filters)
  #   image = hd(page.entries)
  #   next_image = next_image_on_page(page, image)
  #   {prev_image, image, next_image, page}
  # end

  # defp get_image_tuple(:prev_boundary, image, page, params, selected_filters) do
  #   prev_page = prev_page(page, params, selected_filters)
  #   prev_image = List.last(prev_page.entries)
  #   next_image = next_image_on_page(page, image)
  #   {prev_image, image, next_image, page}
  # end

  # defp get_image_tuple(:next_boundary, image, page, params, selected_filters) do
  #   next_page = next_page(page, params, selected_filters)
  #   prev_image = prev_image_on_page(page, image)
  #   next_image = hd(next_page.entries)
  #   {prev_image, image, next_image, page}
  # end

  # defp get_image_tuple(:current, image, page, _params, _selected_filters) do
  #   prev_image = prev_image_on_page(page, image)
  #   next_image = next_image_on_page(page, image)
  #   {prev_image, image, next_image, page}
  # end

  # defp is_very_first_image?(page, image) do
  #   page.page_number == 1 && image.id == hd(page.entries).id
  # end

  # defp is_very_last_image?(page, image) do
  #   page.page_number == page.total_pages && image.id == List.last(page.entries).id
  # end

  # defp on_prev_page?(page, image) do
  #   image.id < hd(page.entries).id
  # end

  # defp on_next_page?(page, image) do
  #   image.id > List.last(page.entries).id
  # end

  # defp first_on_page?(page, image) do
  #   image.id == hd(page.entries).id
  # end

  # defp last_on_page?(page, image) do
  #   image.id == List.last(page.entries).id
  # end

  #######################

  def normalize_params(params) do
    Keyword.merge(
      [limit: 24, cursor_fields: [:id], preload: [], include_total_count: false],
      params
    )
  end

  def join_tag_match(tag_list) when is_integer(hd(tag_list)) do
    dynamic([i, it, t], t.id == it.tag_id and t.id in ^tag_list)
  end

  def join_tag_match(tag_list) when is_binary(hd(tag_list)) do
    dynamic([i, it, t], t.id == it.tag_id and t.name in ^tag_list)
  end

  defp images_matching_tags_query(tag_id_list, params \\ []) do
    Onagal.Images.Image
    |> join(:inner, [i], it in Onagal.Images.ImageTag, on: it.image_id == i.id, as: :images_tags)
    |> join(:inner, [i, it], t in Onagal.Tags.Tag,
      on: ^join_tag_match(tag_id_list),
      as: :tags
    )
    |> select([i], i)
    |> group_by([i], i.id)
    |> order_by([i], i.id)
    |> preload(^Keyword.get(params, :preload))
    |> having(count() == ^length(tag_id_list))
  end

  def images_matching_tags(tag_id_list, params \\ []) do
    params = normalize_params(params)

    images_matching_tags_query(tag_id_list, params)
    |> Repo.paginate(params)
  end

  def images_next_page(page, tag_id_list, params \\ []) do
    params = Keyword.merge(normalize_params(params), after: page.metadata.after)

    images_matching_tags_query(tag_id_list, params)
    |> Repo.paginate(params)
  end

  def images_prev_page(page, tag_id_list, params \\ []) do
    params = Keyword.merge(normalize_params(params), before: page.metadata.before)

    images_matching_tags_query(tag_id_list, params)
    |> Repo.paginate(params)
  end
end
