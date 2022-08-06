# field :current_name, :string
# field :original_name, :string
# field :location, :string
# field :digest, :string
# field :size, :integer
# field :file_type, :string
# timestamps()

defmodule Onagal.Fs.Persist do
  @image_types %{
    ".jpg" => "image/jpeg",
    ".jpeg" => "image/jpeg",
    ".gif" => "image/gif",
    ".png" => "image/png",
    ".webp" => "image/webp",
    ".webm" => "video/webm",
    ".mp4" => "video/mp4",
    ".mpeg" => "video/mpeg",
    ".avi" => "video/x-msvideo"
  }

  def persist_files_info(files) when is_list(files) do
    files
    |> filter_non_images
    |> Enum.each(fn file ->
      persist_file_info(file)
    end)

    {:ok, :persist_complete}
  end

  def persist_files_info(_), do: {:error, :invalid_file_list}

  def remove_files_info(files) when is_list(files) do
    files
    |> filter_non_images
    |> Enum.each(fn file ->
      remove_file_info(file)
    end)

    {:ok, :remove_complete}
  end

  def remove_files_info(_), do: {:error, "invalid file list"}

  def compute_digest(image_path) when is_binary(image_path) do
    File.stream!(image_path, [], 2048)
    |> Enum.reduce(:crypto.hash_init(:sha256), &:crypto.hash_update(&2, &1))
    |> :crypto.hash_final()
    |> Base.encode16()
    |> String.downcase()
  end

  def compute_digest(_), do: {:error, :invalid_file}

  def filter_non_images(file_list) when is_list(file_list) do
    image_files =
      file_list
      |> Enum.filter(fn {fpath, _} -> is_image?(fpath) end)

    image_files
  end

  def filter_non_images(_), do: []

  def is_image?(file) when is_binary(file) do
    case simple_type_lookup(file) do
      "application/octet-stream" -> false
      nil -> false
      _ -> true
    end
  end

  def is_image?(_), do: false

  defp persist_file_info({path, file_stat} = fileinfo) when is_tuple(fileinfo) do
    fpath = Path.dirname(path)
    file = Path.basename(path)

    image_data = %{
      original_name: file,
      current_name: file,
      location: fpath,
      size: file_stat.size,
      file_type: simple_type_lookup(file),
      digest: compute_digest(path)
    }

    case Onagal.Images.add_image(image_data) do
      {:ok, _} -> {:ok, :persisted}
      {:error, _} -> {:error, :not_persisted}
    end
  end

  defp persist_file_info(_), do: {:error, :invalid_file_data}

  defp remove_file_info({path, _} = fileinfo) when is_tuple(fileinfo) do
    fpath = Path.dirname(path)
    file = Path.basename(path)

    image = Onagal.Images.get_image_by_file_path(fpath, file)

    case Onagal.Images.delete_image(image) do
      {:ok, _} -> {:ok, :file_deleted}
      {:error, _} -> {:error, :file_delete_failed}
    end
  end

  defp remove_file_info(_), do: {:error, :invalid_file}

  defp simple_type_lookup(filename) when is_binary(filename) do
    if image_type = @image_types[Path.extname(filename)] do
      image_type
    else
      "application/octet-stream"
    end
  end

  defp simple_type_lookup(_), do: nil
end
