defmodule OnagalWeb.Schema.Image.Types do
  use Absinthe.Schema.Notation

  alias OnagalWeb.Resolvers

  @desc "An image"
  object :image do
    field(:id, :id)
    field(:current_name, :string)
    field(:original_name, :string)
    field(:location, :string)
    field(:digest, :string)
    field(:size, :integer)
    field(:file_type, :string)
    field(:inserted_at, :naive_datetime)
    field(:updated_at, :naive_datetime)
  end

  object :get_images do
    @desc """
    Get a list of images
    """

    field :images, list_of(:image) do
      resolve(&Resolvers.Images.list_images/2)
    end
  end

  object :get_image do
    @desc """
    Get a specific image
    """

    field :image, :image do
      arg(:id, non_null(:id))

      resolve(&Resolvers.Images.get_image/2)
    end
  end

  object :update_image do
    @desc """
    Update an image
    """

    @desc "Update an image"
    field :update_image, :image do
      arg(:id, non_null(:id))
      arg(:original_name, :string)

      resolve(&Resolvers.Images.update_image/2)
    end
  end
end
