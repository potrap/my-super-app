defmodule MySuperAppWeb.PostControllerTest do
  use MySuperAppWeb.ConnCase

  import MySuperApp.BlogFixtures

  alias MySuperApp.Blog.Post

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all posts", %{conn: conn} do
      conn = get(conn, ~p"/api/posts")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "update post" do
    setup [:create_post]

    test "renders post when data is valid", %{conn: conn, post: %Post{id: id}} do
      conn =
        put(conn, ~p"/api/posts/#{id}", %{
          "title" => "some updated title",
          "body" => "some updated body"
        })

      assert %{"id" => ^id, "body" => "some updated body", "title" => "some updated title"} =
               json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/posts/#{id}")

      assert %{
               "id" => ^id,
               "body" => "some updated body",
               "title" => "some updated title"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when post does not exist", %{conn: conn} do
      conn = put(conn, ~p"/api/posts/#{1}", post: %{"title" => nil, "body" => nil})
      assert json_response(conn, 404)["errors"] != %{}
    end
  end

  describe "delete post" do
    setup [:create_post]

    test "deletes chosen post", %{conn: conn, post: post} do
      conn = delete(conn, ~p"/api/posts/#{post}")
      assert response(conn, 204)
    end
  end

  defp create_post(_) do
    post = post_fixture()
    %{post: post}
  end
end
