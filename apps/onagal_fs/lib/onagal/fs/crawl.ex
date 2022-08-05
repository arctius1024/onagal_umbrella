defmodule Onagal.Fs.Crawl do
  def recurse_path(""), do: []

  def recurse_path(path) when is_binary(path) do
    recurse_paths([path])
  end

  def recurse_path(_), do: []

  def recurse_paths(paths), do: recurse_paths(paths, [])
  def recurse_paths(paths, _) when not is_list(paths), do: []
  def recurse_paths(_, acc) when not is_list(acc), do: []
  def recurse_paths([], acc), do: acc

  def recurse_paths(paths, acc) do
    findings =
      paths
      |> Enum.filter(fn path -> File.dir?(path) end)
      |> Task.async_stream(fn path -> map_files(path) end, timeout: 15000)
      |> Enum.into([], fn {:ok, res} -> res end)
      |> List.flatten()

    # This is the non-concurrency approach. somewhat (but not significantly) slower
    # Enum.flat_map(paths, fn path ->
    #  map_files(path)
    # end)

    {dirs, files} = partition_path_entries(findings)
    recurse_paths(dirs, acc ++ files)
  end

  defp map_files(path) when not is_binary(path), do: []

  defp map_files(path) do
    Enum.map(File.ls!(path), fn file ->
      fpath = Path.join(path, file)
      rstat = File.stat(fpath)

      stat =
        case rstat do
          {:ok, stat} -> stat
          {:error, _} -> nil
        end

      {fpath, stat}
    end)
    |> Enum.filter(fn {_, fstat} ->
      fstat != nil
    end)
  end

  defp partition_path_entries([]), do: {[], []}

  defp partition_path_entries(file_list) do
    {files, nonfiles} =
      file_list
      |> Enum.split_with(fn {_, fstat} ->
        fstat.type == :regular
      end)

    {dirs, _} =
      nonfiles
      |> Enum.split_with(fn {_, fstat} ->
        fstat.type == :directory
      end)

    dirs = dirs |> Enum.map(fn {fpath, _} -> fpath <> "/" end)
    {dirs, files}
  end
end
