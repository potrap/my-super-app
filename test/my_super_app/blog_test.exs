defmodule MySuperApp.BlogTest do
  use MySuperApp.DataCase

  alias MySuperApp.Blog
  alias MySuperApp.Blog.{Post, Tag}
  alias MySuperApp.Accounts

  describe "posts" do
    setup do
      user_attrs = %{
        username: "test_user",
        email: "test@example.com",
        password: "password123"
      }

      {:ok, user} = Accounts.register_user(user_attrs)

      tag_attrs = %{"name" => "test_tag"}
      {:ok, tag} = Blog.create_tag(tag_attrs)

      {:ok, user: user, tag: tag}
    end

    test "create_post/1 with valid data creates a post", %{user: user} do
      attrs = %{
        "title" => "Test Post",
        "body" => "This is a test post",
        "post_tags" => ["test_tag"],
        "user_id" => user.id
      }

      assert {:ok, %Post{} = post} = Blog.create_post(attrs)
      assert post.title == "Test Post"
      assert post.body == "This is a test post"
      assert post.user_id == user.id
      assert Enum.any?(post.tags, fn t -> t.name == "test_tag" end)
    end

    test "create_post/1 with missing fields returns an error", %{user: user} do
      attrs = %{
        "body" => "This is a test post",
        "user_id" => user.id
      }

      assert {:error, changeset} = Blog.create_post(attrs)
      assert %{title: ["can't be blank"]} = errors_on(changeset)
    end

    test "create_post/1 with invalid tags returns an error", %{user: user} do
      attrs = %{
        "title" => "Test Post",
        "body" => "This is a test post",
        "post_tags" => ["invalid_tag"],
        "user_id" => user.id
      }

      assert {:ok, %Post{} = post} = Blog.create_post(attrs)
      assert post.tags == []
    end

    test "update_post/2 with valid data updates the post", %{user: user} do
      attrs = %{
        "title" => "Test Post",
        "body" => "This is a test post",
        "post_tags" => ["test_tag"],
        "user_id" => user.id
      }

      {:ok, %Post{id: id}} = Blog.create_post(attrs)
      update_attrs = %{"title" => "Updated Title", "body" => "Updated Body"}

      assert {:ok, %Post{} = post} = Blog.update_post(%{"id" => id} |> Map.merge(update_attrs))
      assert post.title == "Updated Title"
      assert post.body == "Updated Body"
    end

    test "update_post/2 with invalid data returns an error", %{user: user} do
      attrs = %{
        "title" => "Test Post",
        "body" => "This is a test post",
        "user_id" => user.id
      }

      {:ok, %Post{id: id}} = Blog.create_post(attrs)
      update_attrs = %{"title" => nil, "body" => nil}

      assert {:error, changeset} = Blog.update_post(%{"id" => id} |> Map.merge(update_attrs))
      assert %{title: ["can't be blank"], body: ["can't be blank"]} = errors_on(changeset)
    end

    test "delete_post/1 deletes the post", %{user: user} do
      attrs = %{
        "title" => "Test Post",
        "body" => "This is a test post",
        "post_tags" => ["test_tag"],
        "user_id" => user.id
      }

      {:ok, %Post{id: id} = post} = Blog.create_post(attrs)
      assert {:ok, %Post{}} = Blog.delete_post(post)
      assert Blog.get_post(id) == {:error, :not_found}
    end
  end

  describe "tags" do
    test "create_tag/1 with valid data creates a tag" do
      attrs = %{"name" => "new_tag"}

      assert {:ok, %Tag{} = tag} = Blog.create_tag(attrs)
      assert tag.name == "new_tag"
    end

    test "get_tag_by_name/1 returns the tag with the given name" do
      attrs = %{"name" => "existing_tag"}

      {:ok, %Tag{}} = Blog.create_tag(attrs)
      assert %Tag{} = Blog.get_tag_by_name("existing_tag")
    end

    test "get_tag_by_name/1 returns nil for non-existent tag" do
      assert Blog.get_tag_by_name("non_existent_tag") == nil
    end
  end
end
