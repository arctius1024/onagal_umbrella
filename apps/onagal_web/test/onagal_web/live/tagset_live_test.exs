defmodule OnagalWeb.TagsetLiveTest do
  use OnagalWeb.ConnCase

  import Phoenix.LiveViewTest
  import Onagal.TagsFixtures

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  defp create_tagset(_) do
    tagset = tagset_fixture()
    %{tagset: tagset}
  end

  describe "Index" do
    setup [:create_tagset]

    test "lists all tagsets", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, Routes.tagset_index_path(conn, :index))

      assert html =~ "Listing Tagsets"
    end

    test "saves new tagset", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.tagset_index_path(conn, :index))

      assert index_live |> element("a", "New Tagset") |> render_click() =~
               "New Tagset"

      assert_patch(index_live, Routes.tagset_index_path(conn, :new))

      assert index_live
             |> form("#tagset-form", tagset: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#tagset-form", tagset: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.tagset_index_path(conn, :index))

      assert html =~ "Tagset created successfully"
    end

    test "updates tagset in listing", %{conn: conn, tagset: tagset} do
      {:ok, index_live, _html} = live(conn, Routes.tagset_index_path(conn, :index))

      assert index_live |> element("#tagset-#{tagset.id} a", "Edit") |> render_click() =~
               "Edit Tagset"

      assert_patch(index_live, Routes.tagset_index_path(conn, :edit, tagset))

      assert index_live
             |> form("#tagset-form", tagset: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#tagset-form", tagset: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.tagset_index_path(conn, :index))

      assert html =~ "Tagset updated successfully"
    end

    test "deletes tagset in listing", %{conn: conn, tagset: tagset} do
      {:ok, index_live, _html} = live(conn, Routes.tagset_index_path(conn, :index))

      assert index_live |> element("#tagset-#{tagset.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#tagset-#{tagset.id}")
    end
  end

  describe "Show" do
    setup [:create_tagset]

    test "displays tagset", %{conn: conn, tagset: tagset} do
      {:ok, _show_live, html} = live(conn, Routes.tagset_show_path(conn, :show, tagset))

      assert html =~ "Show Tagset"
    end

    test "updates tagset within modal", %{conn: conn, tagset: tagset} do
      {:ok, show_live, _html} = live(conn, Routes.tagset_show_path(conn, :show, tagset))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Tagset"

      assert_patch(show_live, Routes.tagset_show_path(conn, :edit, tagset))

      assert show_live
             |> form("#tagset-form", tagset: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#tagset-form", tagset: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.tagset_show_path(conn, :show, tagset))

      assert html =~ "Tagset updated successfully"
    end
  end
end
