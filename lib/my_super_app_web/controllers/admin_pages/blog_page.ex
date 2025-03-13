defmodule MySuperAppWeb.BlogPage do
  @moduledoc """
  AdminPage
  """
  use MySuperAppWeb, :admin_surface_live_view

  alias Moon.Design.Table.Column
  alias MySuperApp.{Blog, Accounts, Pictures}
  alias Moon.Design.{Form, Table, Snackbar, Button, Modal, Pagination, Search, Tag}
  alias Moon.Design.Form.Field
  alias Moon.Icons.{GenericInfo, ControlsChevronRight, ControlsChevronLeft}
  alias Moon.Design.Dropdown
  alias Moon.Lego
  alias MySuperApp.Blog.{Post, Picture}

  on_mount {MySuperAppWeb.UserAuth, :mount_current_user}

  def mount(_, _, socket) do
    {
      :ok,
      assign(
        socket,
        posts: Blog.get_all_posts_by_published_at(),
        open_delete_snackbar: false,
        default_modal_open: false,
        body_modal_open: false,
        edit_picture_modal_open: false,
        limit: 5,
        current_page: 1,
        filter: "",
        sort: [],
        items: Blog.authors_name(),
        tag_items: Blog.list_tags(),
        dropdown_name: "Select Author",
        tag_dropdown_name: "Select Tag",
        selected: nil,
        post: %Post{title: ""},
        selected_post: %Post{id: 0, title: ""},
        picture_form: to_form(Picture.changeset(%Picture{}, %{})),
        image_src:
          "https://res.cloudinary.com/dacln9dzy/image/upload/v1727274476/zqgetbyigqjrzntiq2vg.jpg"
      )
    }
  end

  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end

  def get_name(nil), do: "Nobody"
  def get_name(id), do: Accounts.get_user(id).username

  def get_tags(id) do
    tags = Blog.get_post(id).tags
    Enum.map(tags, fn x -> x.name end)
  end

  def handle_event("option_send", %{"value" => author}, socket) do
    author_id = Blog.get_user_by_name(author).id

    Dropdown.close("dropdown")

    {:noreply,
     assign(
       socket,
       posts: Blog.get_all_posts_by_author(author_id),
       dropdown_name: author,
       current_page: 1
     )}
  end

  def handle_event("option_send_tag", %{"value" => tag_name}, socket) do
    Dropdown.close("tag_dropdown")

    {:noreply,
     assign(
       socket,
       posts: get_posts_by_tag(tag_name, socket),
       tag_dropdown_name: tag_name,
       current_page: 1
     )}
  end

  def handle_event("option_send_all", %{"value" => _oper}, socket) do
    {:noreply,
     assign(
       socket,
       posts: Blog.get_all_posts_by_published_at(),
       dropdown_name: "Select authors",
       current_page: 1
     )}
  end

  def handle_event("option_send_all_tags", %{"value" => _oper}, socket) do
    {:noreply,
     assign(
       socket,
       posts: Blog.get_all_posts_by_published_at(),
       tag_dropdown_name: "Select Tag",
       current_page: 1
     )}
  end

  def handle_event("change_filter", %{"value" => filter}, socket) do
    is_number = String.match?(filter, ~r/^\d+$/)

    posts =
      if is_number do
        Enum.filter(Blog.get_all_posts_by_published_at(), fn b ->
          b.id == String.to_integer(filter)
        end)
      else
        Enum.filter(Blog.get_all_posts_by_published_at(), fn b ->
          String.starts_with?(String.downcase(b.title), [String.downcase(filter)])
        end)
      end

    {:noreply,
     assign(socket,
       filter: filter,
       posts: posts,
       current_page: 1,
       dropdown_name: "Select Author"
     )}
  end

  def handle_event("set_open", %{"value" => id}, socket) do
    Modal.open("default_modal")

    {
      :noreply,
      assign(
        socket,
        post: Blog.get_post!(id),
        default_modal_open: true,
        open_delete_snackbar: false
      )
    }
  end

  def handle_event("open_edit_picture_modal", %{"value" => id}, socket) do
    Modal.open("default_modal")

    {
      :noreply,
      assign(
        socket,
        post: Blog.get_post!(id),
        edit_picture_modal_open: true,
        open_delete_snackbar: false
      )
    }
  end

  def handle_event("set_close_confirm", %{"value" => value}, socket) do
    Modal.close("default_modal")

    deleted_post = Blog.get_post!(value)

    Blog.delete_post(deleted_post)

    if socket.assigns.current_page >
         ceil(Enum.count(Blog.get_all_posts_by_published_at()) / socket.assigns.limit) do
      {
        :noreply,
        assign(
          socket,
          posts: Blog.get_all_posts_by_published_at(),
          current_page: socket.assigns.current_page - 1,
          default_modal_open: false,
          open_delete_snackbar: true,
          post: %{id: nil, title: deleted_post.title},
          dropdown_name: "Select author"
        )
      }
    else
      {
        :noreply,
        assign(
          socket,
          posts: Blog.get_all_posts_by_published_at(),
          default_modal_open: false,
          open_delete_snackbar: true,
          dropdown_name: "Select author"
        )
      }
    end
  end

  def handle_event("set_close", _, socket) do
    Modal.close("default_modal")
    {:noreply, assign(socket, default_modal_open: false)}
  end

  def handle_event("set_close_edit_picture", _, socket) do
    Modal.close("edit_picture_modal")
    {:noreply, assign(socket, edit_picture_modal_open: false)}
  end

  def handle_event("handle_paging_click", %{"value" => current_page}, socket) do
    current_page = String.to_integer(current_page)

    {:noreply,
     socket
     |> assign(current_page: current_page, models_10: posts_pages(socket.assigns))}
  end

  def handle_event(
        "handle_sorting_click",
        %{"sort-dir" => sort_dir, "sort-key" => sort_key},
        socket
      ) do
    {:noreply,
     assign(socket,
       posts:
         posts_sorted_by(
           Blog.get_all_posts_by_published_at(),
           String.to_atom(sort_key),
           sort_dir
         ),
       sort: ["#{sort_key}": sort_dir]
     )}
  end

  def handle_event("show_modal_body", %{"selected" => selected}, socket) do
    Modal.open("body_modal")

    sl_post = Blog.get_post(selected)

    {:noreply,
     assign(socket,
       selected_post: sl_post,
       body_modal_open: true
     )}
  end

  def handle_event("close_body_modal", _, socket) do
    Modal.close("body_modal")

    {:noreply, assign(socket, body_modal_open: false)}
  end

  def handle_event("update_picture", params, socket) do
    Modal.close("edit_picture_modal")
    picture = Pictures.get_picture(params["id"])
    attrs = %{"post_id" => socket.assigns.post.id}
    Pictures.update_picture(picture, attrs)

    {:noreply,
     socket
     |> assign(
       edit_picture_modal_open: false,
       image_src:
         "https://res.cloudinary.com/dacln9dzy/image/upload/v1727274476/zqgetbyigqjrzntiq2vg.jpg"
     )
     |> put_flash(:info, "Picture updated")}
  end

  def handle_event("update_picture_in_modal", params, socket) do
    image_src = Pictures.get_picture(params["id"]).path
    {:noreply, assign(socket, image_src: image_src)}
  end

  def handle_event("publish_post", %{"value" => id}, socket) do
    published_at =
      NaiveDateTime.utc_now()
      |> NaiveDateTime.add(3 * 60 * 60, :second)
      |> NaiveDateTime.truncate(:second)

    {:ok, post} = Blog.update_post(%{"id" => id, "published_at" => published_at})
    user = Accounts.get_user(post.user_id)

    MySuperApp.MailWorker.send_email(user.email, post.title <> " has published!")

    {:noreply,
     assign(socket,
       posts: Blog.get_all_posts_by_published_at()
     )
     |> put_flash(:info,
     "Post published! Notification was sent to user's email.")}
  end

  def posts_sorted_by(posts, col, dir) when dir == "ASC",
    do: Enum.sort_by(posts, &[&1[col]], :asc)

  def posts_sorted_by(posts, col, dir) when dir == "DESC",
    do: Enum.sort_by(posts, &[&1[col]], :desc)

  defp posts_pages(assigns) do
    current_page = assigns.current_page
    limit = assigns.limit

    assigns.posts
    |> Enum.slice((current_page * limit - limit)..(current_page * limit - 1))
  end

  defp get_posts_by_tag(tag_name, socket) do
    socket.assigns.posts
    |> Enum.filter(fn post -> tag_name in (post.tags |> Enum.map(fn tag -> tag.name end)) end)
  end

  defp get_path(id) do
    picture = Pictures.get_picture_by_post(id)

    if picture == nil do
      ""
    else
      picture.path
    end
  end
end
