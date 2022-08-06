defmodule OnagalWeb.GalleryLiveTest do
  use OnagalWeb.ConnCase

  import Phoenix.LiveViewTest
  import Onagal.TagsFixtures

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  defp create_gallery(_) do
    gallery = gallery_fixture()
    %{gallery: gallery}
  end

  describe "Index" do
    setup [:create_gallery]

    test "lists all galleries", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, Routes.gallery_index_path(conn, :index))

      assert html =~ "Listing Galleries"
    end

    test "saves new gallery", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.gallery_index_path(conn, :index))

      assert index_live |> element("a", "New Gallery") |> render_click() =~
               "New Gallery"

      assert_patch(index_live, Routes.gallery_index_path(conn, :new))

      assert index_live
             |> form("#gallery-form", gallery: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#gallery-form", gallery: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.gallery_index_path(conn, :index))

      assert html =~ "Gallery created successfully"
    end

    test "updates gallery in listing", %{conn: conn, gallery: gallery} do
      {:ok, index_live, _html} = live(conn, Routes.gallery_index_path(conn, :index))

      assert index_live |> element("#gallery-#{gallery.id} a", "Edit") |> render_click() =~
               "Edit Gallery"

      assert_patch(index_live, Routes.gallery_index_path(conn, :edit, gallery))

      assert index_live
             |> form("#gallery-form", gallery: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#gallery-form", gallery: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.gallery_index_path(conn, :index))

      assert html =~ "Gallery updated successfully"
    end

    test "deletes gallery in listing", %{conn: conn, gallery: gallery} do
      {:ok, index_live, _html} = live(conn, Routes.gallery_index_path(conn, :index))

      assert index_live |> element("#gallery-#{gallery.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#gallery-#{gallery.id}")
    end
  end

  describe "Show" do
    setup [:create_gallery]

    test "displays gallery", %{conn: conn, gallery: gallery} do
      {:ok, _show_live, html} = live(conn, Routes.gallery_show_path(conn, :show, gallery))

      assert html =~ "Show Gallery"
    end

    test "updates gallery within modal", %{conn: conn, gallery: gallery} do
      {:ok, show_live, _html} = live(conn, Routes.gallery_show_path(conn, :show, gallery))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Gallery"

      assert_patch(show_live, Routes.gallery_show_path(conn, :edit, gallery))

      assert show_live
             |> form("#gallery-form", gallery: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#gallery-form", gallery: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.gallery_show_path(conn, :show, gallery))

      assert html =~ "Gallery updated successfully"
    end
  end
end
