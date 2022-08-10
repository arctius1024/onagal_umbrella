defmodule Onagal.Repo.Migrations.CreateUsersAuthTables do
  use Ecto.Migration

  def change do
    function_up_sql = """
      CREATE OR REPLACE FUNCTION images_with_all_tag_names(tnames text[]) 
        RETURNS TABLE(image_id BIGINT)
        LANGUAGE plpgsql
        AS
      $func$
          BEGIN
              RETURN QUERY
                  SELECT images_tags.image_id AS image_id FROM images_tags GROUP BY images_tags.image_id HAVING array_agg(tag_id) @> 
                  (SELECT array_agg(id) FROM tags WHERE name IN (SELECT * FROM unnest(tnames))); 
              RETURN NEXT;
          END;
      $func$;
    """
    
    function_down_sql = """
      DROP FUNCTION images_with_all_tag_names(text[]);
    """
  
    execute(function_up_sql, function_down_sql)
  end
end
