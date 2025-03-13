defmodule MySuperAppWeb.PictureControllerTest do
  use MySuperAppWeb.ConnCase

  alias MySuperApp.Pictures
  alias MySuperApp.Blog.Picture

  alias MySuperApp.Blog
  alias MySuperApp.Blog.{Post}
  alias MySuperApp.Accounts

  @valid_attrs %{
    "path" => "uploads/test.jpg",
    "file_name" => "test",
    "upload_at" => NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all pictures", %{conn: conn} do
      conn = get(conn, ~p"/api/pictures")
      assert json_response(conn, 200)["data"] == nil
    end
  end

  describe "update picture" do
    setup [:create_picture]

    test "updates picture with valid data", %{conn: conn, picture: %Picture{id: id}, post: post} do
      conn = put(conn, ~p"/api/pictures/#{id}", %{"post_id" => post.id})
      assert %{"id" => ^id, "file_name" => "test"} = json_response(conn, 200)["data"]
    end

    test "renders errors when picture does not exist", %{conn: conn} do
      conn = put(conn, ~p"/api/pictures/#{-1}", %{"file_name" => "updated.jpg"})
      assert json_response(conn, 404)["error"] != %{}
    end
  end

  describe "delete picture" do
    setup [:create_picture]

    test "deletes chosen picture", %{conn: conn, picture: %Picture{id: id}} do
      conn = delete(conn, ~p"/api/pictures/#{id}")
      assert response(conn, 204)
    end
  end

  describe "create picture" do
    test "creates a picture with invalid path", %{conn: conn} do
      upload = %Plug.Upload{path: "some/path", filename: "somefile.jpg"}
      conn = post(conn, ~p"/api/pictures", %{"file" => upload})

      assert nil == json_response(conn, 422)["data"]
    end
  end

  defp create_picture(_) do
    user_attrs = %{
      username: "test_user",
      email: "test@example.com",
      password: "password123"
    }

    {:ok, user} = Accounts.register_user(user_attrs)

    attrs = %{
      "title" => "Test Post",
      "body" => "This is a test post",
      "post_tags" => ["test_tag"],
      "user_id" => user.id
    }

    assert {:ok, %Post{} = post} = Blog.create_post(attrs)

    {:ok, %Picture{} = picture} = Pictures.create_picture(@valid_attrs)
    %{picture: picture, post: post}
  end
end
