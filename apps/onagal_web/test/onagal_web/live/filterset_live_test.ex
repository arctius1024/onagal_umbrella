defmodule OnagalWeb.FiltersetLiveTest do
  use OnagalWeb.ConnCase

  import Phoenix.LiveViewTest
  import Onagal.TagsFixtures

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  defp create_filterset(_) do
    filterset = filterset_fixture()
    %{filterset: filterset}
  end

  describe "Index" do
    setup [:create_filterset]

    test "lists all filtersets", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, Routes.filterset_index_path(conn, :index))

      assert html =~ "Listing Filtersets"
    end

    test "saves new filterset", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.filterset_index_path(conn, :index))

      assert index_live |> element("a", "New Filterset") |> render_click() =~
               "New Filterset"

      assert_patch(index_live, Routes.filterset_index_path(conn, :new))

      assert index_live
             |> form("#filterset-form", filterset: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#filterset-form", filterset: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.filterset_index_path(conn, :index))

      assert html =~ "Filterset created successfully"
    end

    test "updates filterset in listing", %{conn: conn, filterset: filterset} do
      {:ok, index_live, _html} = live(conn, Routes.filterset_index_path(conn, :index))

      assert index_live |> element("#filterset-#{filterset.id} a", "Edit") |> render_click() =~
               "Edit Filterset"

      assert_patch(index_live, Routes.filterset_index_path(conn, :edit, filterset))

      assert index_live
             |> form("#filterset-form", filterset: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#filterset-form", filterset: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.filterset_index_path(conn, :index))

      assert html =~ "Filterset updated successfully"
    end

    test "deletes filterset in listing", %{conn: conn, filterset: filterset} do
      {:ok, index_live, _html} = live(conn, Routes.filterset_index_path(conn, :index))

      assert index_live |> element("#filterset-#{filterset.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#filterset-#{filterset.id}")
    end
  end

  describe "Show" do
    setup [:create_filterset]

    test "displays filterset", %{conn: conn, filterset: filterset} do
      {:ok, _show_live, html} = live(conn, Routes.filterset_show_path(conn, :show, filterset))

      assert html =~ "Show Filterset"
    end

    test "updates filterset within modal", %{conn: conn, filterset: filterset} do
      {:ok, show_live, _html} = live(conn, Routes.filterset_show_path(conn, :show, filterset))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Filterset"

      assert_patch(show_live, Routes.filterset_show_path(conn, :edit, filterset))

      assert show_live
             |> form("#filterset-form", filterset: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#filterset-form", filterset: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.filterset_show_path(conn, :show, filterset))

      assert html =~ "Filterset updated successfully"
    end
  end
end
