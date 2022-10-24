defmodule OnagalWeb.Schema.Tag.Types do
  use Absinthe.Schema.Notation

  alias OnagalWeb.Resolvers

  @desc "A tag"
  object :tag do
    field(:id, :id)
    field(:name, :string)
    field(:inserted_at, :naive_datetime)
    field(:updated_at, :naive_datetime)
  end

  object :get_tags do
    @desc """
    Get a list of tags
    """

    field :tag, list_of(:tag) do
      resolve(&Resolvers.Tags.list_tags/2)
    end
  end

  object :get_tag do
    @desc """
    Get a specific tag
    """

    field :tag, :tag do
      arg(:id, non_null(:id))

      resolve(&Resolvers.Tags.get_tag/2)
    end
  end

  object :create_tag do
    @desc """
    Create a tag
    """

    @desc "Create a tag"
    field :create_tag, :tag do
      arg(:name, :string)

      resolve(&Resolvers.Tags.create_tag/2)
    end
  end
end
