defmodule Onagal.Paginate do
  @moduledoc """
  Documentation for `Onagal.Paginate`.
  """
  import Ecto.Query

  alias Onagal.Repo
  # alias Onagal.Images
  # alias Onagal.Images.Image
  # alias Onagal.Tags

  def prev_image(page, image, params, selected_filters) do
    cond do
      image.id == hd(page.entries).id ->
        case page.metadata.before do
          nil ->
            {page, image}

          _ ->
            prev_page = images_prev_page(page, selected_filters, params)
            {prev_page, List.last(prev_page.entries)}
        end

      true ->
        image_index = Enum.find_index(page.entries, fn img -> img.id == image.id end)
        image = Enum.at(page.entries, image_index - 1)
        {page, image}
    end
  end

  def next_image(page, image, params, selected_filters) do
    cond do
      image.id == List.last(page.entries).id ->
        case page.metadata.after do
          nil ->
            {page, image}

          _ ->
            next_page = images_next_page(page, selected_filters, params)
            {next_page, hd(next_page.entries)}
        end

      true ->
        image_index = Enum.find_index(page.entries, fn img -> img.id == image.id end)
        image = Enum.at(page.entries, image_index + 1)
        {page, image}
    end
  end

  def image_on_current_page(page, image) do
    image.id >= hd(page.entries).id && image.id <= List.last(page.entries).id
  end

  def image_on_prior_page(page, image) do
    image.id < hd(page.entries).id
  end

  def image_on_future_page(page, image) do
    image.id > List.last(page.entries).id
  end

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

  def where_match_at_id(image_id) when is_integer(image_id) do
    dynamic([i], i.id >= ^image_id)
  end

  def where_match_at_id(_), do: true

  defp images_query(params \\ []) do
    Onagal.Images.Image
    |> where(^where_match_at_id(Keyword.get(params, :id)))
    |> select([i], i)
    |> group_by([i], i.id)
    |> order_by([i], i.id)
    |> preload(^Keyword.get(params, :preload))
  end

  defp images_matching_tags_query(tag_id_list, params \\ []) do
    Onagal.Images.Image
    |> where(^where_match_at_id(Keyword.get(params, :id)))
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

  def paginate_images(tag_id_list, params \\ [])

  def paginate_images([], params) do
    params = normalize_params(params)

    images_query(params)
    |> Repo.paginate(params)
  end

  def paginate_images(tag_id_list, params) do
    params = normalize_params(params)

    images_matching_tags_query(tag_id_list, params)
    |> Repo.paginate(params)
  end

  def images_next_page(page, tag_id_list, params \\ []) do
    params =
      Keyword.merge(normalize_params(params), after: page.metadata.after)
      |> Keyword.drop([:id])

    paginate_images(tag_id_list, params)
  end

  def images_prev_page(page, tag_id_list, params \\ []) do
    params =
      Keyword.merge(normalize_params(params), before: page.metadata.before)
      |> Keyword.drop([:id])

    paginate_images(tag_id_list, params)
  end
end
