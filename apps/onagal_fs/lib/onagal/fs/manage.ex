defmodule Onagal.Fs.Manage do
  @manage_dir Application.get_env(:onagal_fs, Onagal.Fs)[:manage_dir]

  def initialize_management do
    # Cannot run without this so just bail if it doesn't work
    if !File.dir?(@manage_dir) do
      raise "please create #{@manage_dir} before starting the application - or verify ENV[MANAGE_DIR] exists"
    end

    create_managed_dir_structure()
  end

  @doc """
    Given a file path
      if its a regular file
      create a digest of the file contents
      compute a normalized name (digest + extention)
      determine its new path (based on digest)
      move file to new path and name
  """
  def migrate_managed_file(""), do: {:error, :no_such_file}

  # TODO: look at refactoring raise to return {:error, :error_info} instead
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

  @doc """
    Given a (managed) file path
      Check to make sure the file exists in the managed path (no rm -rf / for you!)
      Check to make sure its a regular file (no rm /all_my_pics/ for you!)
      .rm! the file

    NOTE: This does *not* remove the database entry, *only* the file itself
  """
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

  @doc """
    Given a file's digest, compute the subdir it should be stored in
      Currently this is only 1 character deep (16 subdirs - 0-9, a-f).
      If necessary a migration to 2 char (256 subdirs) could be done easily.
  """
  defp find_managed_subdir(digest) when is_binary(digest), do: String.at(digest, 0)

  @doc """
    Ensure the managed subdir structure is in place
      This runs every startup, but as it does nothing if the directories already exists it
      should be harmless.

      Possible error condition - the entry exists but as a file. It won't like that.
  """
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
