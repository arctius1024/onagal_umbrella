defmodule OnagalWeb.Resolvers.Images do
  alias Onagal.Images

  def list_images(_args, _context) do
    {:ok, Images.list_images()}
  end

  def get_image(%{id: id}, _context) do
    {:ok, Images.get_image!(id)}
  end

  def update_image(%{id: id} = params, _context) do
    case Images.get_image!(id) do
      nil ->
        {:error, "Image not found"}

      %Images.Image{} = image ->
        case Images.ui_update_image(image, params) do
          {:ok, %Images.Image{} = image} -> {:ok, image}
          {:error, changeset} -> {:error, inspect(changeset.errors)}
        end
    end
  end
end
