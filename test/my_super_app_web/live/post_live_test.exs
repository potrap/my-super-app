defmodule MySuperAppWeb.PostLiveTest do
  use MySuperAppWeb.ConnCase

  import Phoenix.LiveViewTest
  import MySuperApp.BlogFixtures

  defp create_post(_) do
    post = post_fixture()
    %{post: post}
  end

  describe "Show" do
    setup [:create_post, :register_and_log_in_user]

    test "displays post", %{conn: conn, post: post} do
      {:ok, _show_live, html} = live(conn, ~p"/posts/#{post}")

      assert html =~ "Show Post"
      assert html =~ post.title
    end
  end
end
