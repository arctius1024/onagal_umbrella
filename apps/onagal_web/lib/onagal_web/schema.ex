defmodule OnagalWeb.Schema do
  use Absinthe.Schema

  alias OnagalWeb.Schema
  alias OnagalWeb.Middleware.{ErrorHandler, SafeResolution}

  import_types(Absinthe.Type.Custom)
  import_types(Schema.Image.Types)
  import_types(Schema.Tag.Types)

  query do
    import_fields(:get_images)
    import_fields(:get_image)

    import_fields(:get_tags)
  end

  mutation do
    import_fields(:update_image)

    import_fields(:create_tag)
  end

  def middleware(middleware, _field, %{identifier: type}) when type in [:query, :mutation] do
    SafeResolution.apply(middleware) ++ [ErrorHandler]
  end

  def middleware(middleware, _field, _object) do
    middleware
  end
end
