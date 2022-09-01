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

  @doc """
    Given a list of file paths:
      filter out items that appear to be non-images
      add image file to database
  """
  def persist_files_info(files) when is_list(files) do
    files
    |> filter_non_images
    |> Enum.each(fn file ->
      persist_file_info(file)
    end)

    {:ok, :persist_complete}
  end

  def persist_files_info(_), do: {:error, :invalid_file_list}

  @doc """
    Given a list of file paths:
      filter out items that are not images
      remove image file record from database
  """
  def remove_files_info(files) when is_list(files) do
    files
    |> filter_non_images
    |> Enum.each(fn file ->
      remove_file_info(file)
    end)

    {:ok, :remove_complete}
  end

  def remove_files_info(_), do: {:error, "invalid file list"}

  @doc """
    Given a list of file paths:any()
      compute digests of each file
      return list of tuples [{path, digest}, ....]
  """
  def compute_digests(file_list) when is_list(file_list) do
    file_list
    |> Enum.map(fn file ->
      {file, compute_digest(file)}
    end)
  end

  @doc """
    Given an image path
      Compute a sha-256 hash of the file data
      Base16 encode hash ([0-9,A-F])
      downcase the resulting hash
  """
  def compute_digest(image_path) when is_binary(image_path) do
    File.stream!(image_path, [], 2048)
    |> Enum.reduce(:crypto.hash_init(:sha256), &:crypto.hash_update(&2, &1))
    |> :crypto.hash_final()
    |> Base.encode16()
    |> String.downcase()
  end

  def compute_digest(_), do: {:error, :invalid_file}

  @doc """
    Given a list of files
      Return a list where all non-images are filtered out
  """
  def filter_non_images(file_list) when is_list(file_list) do
    image_files =
      file_list
      |> Enum.filter(fn {fpath, _, _} -> is_image?(fpath) end)

    image_files
  end

  def filter_non_images(_), do: []

  @doc """
    Given a file
      If the file extension matches a whitelist of supported image (or video media) types
      return true, else return false
  """
  def is_image?(file) when is_binary(file) do
    case simple_type_lookup(file) do
      "application/octet-stream" -> false
      nil -> false
      _ -> true
    end
  end

  def is_image?(_), do: false

  @doc """
    Given a file
      Returns the media type if its a supported image/video type
      otherwise returns generic application/octet-stream
  """
  defp simple_type_lookup(filename) when is_binary(filename) do
    if image_type = @image_types[String.downcase(Path.extname(filename))],
      do: image_type,
      else: "application/octet-stream"
  end

  defp simple_type_lookup(_), do: nil

  @doc """
    Given current file path, original path, and file_stat struct
      create an Onagal.Image.Images compatible %Image{} struct
      attempt to add Image{} struct to database
  """
  defp persist_file_info({path, old_path, file_stat} = fileinfo) when is_tuple(fileinfo) do
    fpath = Path.dirname(path)
    file = String.downcase(Path.basename(path))
    old_name = Path.basename(old_path)

    image_data = %{
      original_name: old_name,
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

  @doc """
    Given current file path in a tuple (other args ignored)
      lookup image record from the database
      attempt to remove image record from the db
  """
  defp remove_file_info({path, _, _} = fileinfo) when is_tuple(fileinfo) do
    fpath = Path.dirname(path)
    file = String.downcase(Path.basename(path))

    image = Onagal.Images.get_image_by_file_path(fpath, file)

    case Onagal.Images.delete_image(image) do
      {:ok, _} -> {:ok, :file_deleted}
      {:error, _} -> {:error, :file_delete_failed}
    end
  end

  defp remove_file_info(_), do: {:error, :invalid_file}
end
