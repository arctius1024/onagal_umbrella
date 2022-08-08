defmodule Onagal.Fs do
  @moduledoc """
  Documentation for `Onagal.Fs`.
  """
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(args) do
    {:ok, watcher_pid} = FileSystem.start_link(args)
    FileSystem.subscribe(watcher_pid)
    {:ok, %{watcher_pid: watcher_pid}}
  end

  @doc """
    - possible events: :created, :moved_to, :moved_from, :deleted, :modified, ... ?
  """
  def handle_info({:file_event, watcher_pid, {path, events}}, %{watcher_pid: watcher_pid} = state) do
    IO.puts("file event received for #{path}")

    if Enum.member?(events, :created) or Enum.member?(events, :moved_to), do: file_added(path)
    if Enum.member?(events, :deleted), do: file_removed(path)

    {:noreply, state}
  end

  def handle_info({:file_event, watcher_pid, :stop}, %{watcher_pid: watcher_pid} = state) do
    IO.puts("Ending run")
    {:noreply, state}
  end

  # This is called from Onagal.Fs.Crawl rather than file_system
  # GenServer.cast(Onagal.Fs, {:bulk_file_event, "/path"})
  def handle_cast({:bulk_file_add_event, path}, state) do
    IO.puts("file added #{path}")

    file_added(path)

    {:noreply, state}
  end

  def handle_cast({:bulk_file_remove_event, path}, state) do
    IO.puts("file added #{path}")

    {fpath, _} = File.stat(path)

    file_removed(fpath)

    {:noreply, state}
  end

  def cleanup_file(fpath) when is_binary(fpath) do
    IO.puts("handling file removed event for #{fpath}")

    with {:ok, _} <- Onagal.Fs.Persist.remove_files_info([{fpath, nil, nil}]),
         {:ok, _} <- Onagal.Fs.Manage.remove_managed_file(fpath) do
      IO.puts("file #{fpath} removed")
      {:ok, :file_removed}
    else
      {:error, _} -> {:error, :file_remove_failed}
    end
  end

  def cleanup_file(_), do: false

  defp file_added(fpath) when is_binary(fpath) do
    IO.puts("handling file added event for #{fpath}")

    with true <- Onagal.Fs.Persist.is_image?(fpath),
         {:ok, fstat} <- File.stat(fpath),
         {:ok, new_path} <- Onagal.Fs.Manage.migrate_managed_file(fpath),
         {:ok, _} <- Onagal.Fs.Persist.persist_files_info([{new_path, fpath, fstat}]) do
      IO.puts("file_added(#{fpath}) / #{new_path}")
      {:ok, :file_added}
    else
      {:error, _} -> {:error, :file_add_failed}
      false -> {:error, :invalid_file_type}
    end
  end

  defp file_added(_), do: false

  defp file_removed(fpath) when is_binary(fpath) do
    IO.puts("handling file removed event for #{fpath}")

    if Onagal.Fs.Persist.is_image?(fpath), do: Onagal.Fs.Persist.remove_files_info([{fpath, nil}])
  end

  defp file_removed(_), do: false
end
