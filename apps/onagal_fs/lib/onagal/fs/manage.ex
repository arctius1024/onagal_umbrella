defmodule Onagal.Fs.Manage do
  @manage_dir Application.get_env(:onagal_fs, Onagal.Fs)[:manage_dir]

  def initialize_management do
    # Cannot run without this so just bail if it doesn't work
    if !File.dir?(@manage_dir) do
      raise "please create #{@manage_dir} before starting the application - or verify ENV[MANAGE_DIR] exists"
    end

    create_managed_dir_structure()
  end

  def migrate_managed_file(""), do: {:error, :no_such_file}

  def migrate_managed_file(fpath) when is_binary(fpath) do
    if !File.regular?(fpath) do
      raise "error: #{fpath} is not a regular path - cannot be put under management"
    end

    digest = Onagal.Fs.Persist.compute_digest(fpath)
    new_filename = digest <> Path.extname(fpath)
    new_path = Path.join([@manage_dir, find_managed_subdir(digest), new_filename])

    if File.exists?(new_path) do
      raise "error: #{new_path} already exists - which should never happen"
    end

    # File rename should /never/ fail - if it does let's not try to handle it gracefully
    {File.rename!(fpath, new_path), new_path}
  end

  def migrate_managed_file(_), do: {:error, :file_rename_error}

  def remove_managed_file(""), do: {:error, :no_such_file}

  def remove_managed_file(fpath) when is_binary(fpath) do
    with true <- Path.dirname(fpath) =~ @manage_dir,
         true <- File.regular?(fpath) do
      File.rm!(fpath)
      {:ok, :remove_success}
    else
      _ -> {:error, :remove_failed}
    end
  end

  def remove_managed_file(_), do: {:error, :invalid_file}

  defp find_managed_subdir(digest) when is_binary(digest), do: String.at(digest, 0)

  defp create_managed_dir_structure do
    (Enum.to_list(0..9) ++ ['a', 'b', 'c', 'd', 'e', 'f', "broken"])
    |> Enum.map(fn hv ->
      path_suffix = to_string(hv)
      full_path = Path.join(@manage_dir, path_suffix)

      if !File.dir?(full_path), do: File.mkdir_p!(full_path)
    end)

    {:ok, :success}
  end
end
