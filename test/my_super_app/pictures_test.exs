defmodule MySuperApp.PicturesTest do
  use MySuperApp.DataCase, async: true

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

  @invalid_attrs %{
    "path" => nil,
    "file_name" => nil
  }

  setup do
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
    {:ok, picture: picture_fixture(), post: post}
  end

  defp picture_fixture(attrs \\ %{}) do
    {:ok, picture} =
      attrs
      |> Enum.into(@valid_attrs)
      |> Pictures.create_picture()

    picture
  end

  describe "list_pictures/1" do
    test "returns all pictures" do
      [picture] = Pictures.list_pictures()
      assert picture.file_name == "test"
    end
  end

  describe "create_picture/1" do
    test "creates a picture with valid data" do
      assert {:ok, %Picture{} = picture} = Pictures.create_picture(@valid_attrs)
      assert picture.file_name == "test"
    end
  end

  describe "update_picture/2" do
    test "updates a picture with valid data", %{picture: picture, post: post} do
      assert {:ok, %Picture{} = updated_picture} =
               Pictures.update_picture(picture, %{
                 "post_id" => post.id
               })

      assert updated_picture.post_id == post.id
    end

    test "fails to update a picture with invalid data", %{picture: picture} do
      assert {:error, _changeset} = Pictures.update_picture(picture, @invalid_attrs)
    end
  end

  describe "get_picture/1" do
    test "gets a picture by id", %{picture: picture} do
      assert %Picture{} = Pictures.get_picture(picture.id)
    end

    test "returns nil if picture doesn't exist" do
      assert Pictures.get_picture(-1) == nil
    end
  end

  describe "delete_picture/1" do
    test "deletes a picture", %{picture: picture} do
      assert {:ok, %Picture{}} = Pictures.delete_picture(picture)
      assert Pictures.get_picture(picture.id) == nil
    end
  end
end
