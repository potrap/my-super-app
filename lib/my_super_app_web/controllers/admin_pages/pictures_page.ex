defmodule MySuperAppWeb.PicturesPage do
  @moduledoc """
  PicturesPage
  """
  use MySuperAppWeb, :admin_surface_live_view

  require Logger

  alias Moon.Design.Table.Column
  alias MySuperApp.{Pictures, Blog}
  alias MySuperApp.Blog.Picture
  alias Moon.Design.{Form, Table, Pagination, Button, Modal, Progress, Drawer, Search}
  alias Moon.Design.Form.{Field, Input, Select}
  alias Moon.Icons.{ControlsChevronRight, ControlsChevronLeft}
  alias Moon.Design.Dropdown
  alias Moon.Lego

  on_mount {MySuperAppWeb.UserAuth, :mount_current_user}

  def mount(_, _, socket) do
    {
      :ok,
      assign(
        socket,
        pictures: Pictures.list_pictures(),
        limit: 5,
        current_page: 1,
        filter: "",
        sort: [],
        create_modal_open: false,
        delete_modal_open: false,
        post_info_modal_open: false,
        picture_modal_open: false,
        open_delete_snackbar: false,
        open_create_snackbar: false,
        open_create_snackbar_error: false,
        drawer_open: false,
        picture: nil,
        extensions: [".jpg", ".jpeg", ".png"],
        extension_dropdown_name: "Select extension",
        form: to_form(Picture.changeset(%Picture{}, %{}))
      )
      |> assign(:uploaded_files, [])
      |> allow_upload(:avatar, accept: ~w(.jpg .jpeg .png), max_entries: 1)
    }
  end

  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end

  def handle_event("set_close_confirm", %{"value" => id}, socket) do
    Modal.close("delete_modal")

    Pictures.get_picture!(id)
    |> Pictures.delete_picture()

    socket = put_flash(socket, :info, "Picture deleted")

    {
      :noreply,
      assign(
        socket,
        delete_modal_open: false,
        pictures: Pictures.list_pictures()
      )
    }
  end

  def handle_event("set_close", _, socket) do
    Modal.close("delete_modal")
    {:noreply, assign(socket, delete_modal_open: false)}
  end

  def handle_event("set_close_info", _, socket) do
    Modal.close("post_info_modal")
    {:noreply, assign(socket, post_info_modal_open: false)}
  end

  def handle_event("set_close_picture", _, socket) do
    Modal.close("picture_modal")
    {:noreply, assign(socket, picture_modal_open: false)}
  end

  def handle_event("open_delete_modal", _, socket) do
    Drawer.close("drawer")
    Modal.open("delete_modal")

    {
      :noreply,
      assign(
        socket,
        open_delete_snackbar: false,
        open_create_snackbar: false,
        open_create_snackbar_error: false,
        delete_modal_open: true
      )
    }
  end

  def handle_event("open_post_info_modal", _, socket) do
    Drawer.close("drawer")
    Modal.open("post_info_modal")

    {
      :noreply,
      assign(
        socket,
        open_delete_snackbar: false,
        open_create_snackbar: false,
        open_create_snackbar_error: false,
        post_info_modal_open: true
      )
    }
  end

  def handle_event("open_picture_modal", _, socket) do
    Drawer.close("drawer")
    Modal.open("picture_modal")

    {
      :noreply,
      assign(
        socket,
        open_delete_snackbar: false,
        open_create_snackbar: false,
        open_create_snackbar_error: false,
        picture_modal_open: true
      )
    }
  end

  def handle_event("update_picture", %{"picture" => params}, socket) do
    Pictures.get_picture!(socket.assigns.picture.id)
    |> Pictures.update_picture(params)

    Process.send_after(self(), :clear_flash, 3000)
    Drawer.close("drawer")

    socket = put_flash(socket, :info, "Picture updated")

    {:noreply,
     assign(socket,
       drawer_open: false,
       pictures: Pictures.list_pictures()
     )}
  end

  def handle_event("close_drawer", _, socket) do
    Drawer.close("drawer")

    {:noreply, assign(socket, drawer_open: false)}
  end

  def handle_event("open_drawer", %{"selected" => id}, socket) do
    picture = Pictures.get_picture_with_post(id)
    Drawer.open("drawer")

    {:noreply,
     assign(socket,
       drawer_open: true,
       picture: picture
     )}
  end

  def handle_event("open_create_modal", _, socket) do
    Modal.open("create_picture_modal")

    {
      :noreply,
      assign(
        socket,
        open_delete_snackbar: false,
        open_create_snackbar: false,
        open_create_snackbar_error: false,
        create_modal_open: true
      )
    }
  end

  def handle_event("close_create_modal", _, socket) do
    Modal.close("create_picture_modal")
    {:noreply, socket}
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :avatar, ref)}
  end

  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("save", _params, socket) do
    with [%Cloudex.UploadedImage{secure_url: url_path}] <-
           consume_uploaded_entries(socket, :avatar, fn meta, _entry ->
             Cloudex.upload(meta.path)
           end),
         {:ok, _updated_picture} <-
           Pictures.create_picture(%{
             "path" => url_path,
             "file_name" =>
               (socket.assigns.uploads.avatar.entries
                |> List.first()).client_name
           }) do
      Modal.close("create_picture_modal")
      Process.send_after(self(), :clear_flash, 3000)

      {:noreply,
       socket
       |> put_flash(:info, "Picture uploaded")
       |> assign(:pictures, Pictures.list_pictures())}
    else
      _ ->
        Modal.close("create_picture_modal")

        {:noreply,
         socket
         |> put_flash(:error, "Failed to upload avatar to Cloudinary")}
    end
  end

  def handle_event(
        "handle_sorting_click",
        %{"sort-dir" => sort_dir, "sort-key" => sort_key},
        socket
      ) do
    {:noreply,
     assign(socket,
       pictures:
         pictures_sorted_by(
           Pictures.list_pictures(),
           String.to_atom(sort_key),
           sort_dir
         ),
       sort: ["#{sort_key}": sort_dir]
     )}
  end

  def handle_event("handle_paging_click", %{"value" => current_page}, socket) do
    current_page = String.to_integer(current_page)

    {:noreply,
     socket
     |> assign(current_page: current_page, models_10: picture_pages(socket.assigns))}
  end

  def handle_event("option_send", %{"value" => extension}, socket) do
    Dropdown.close("extension_dropdown")

    {:noreply,
     assign(
       socket,
       pictures: sort_by_extension(Pictures.list_pictures(), extension),
       extension_dropdown_name: extension,
       current_page: 1
     )}
  end

  def handle_event("clear_filter", %{"value" => _extension}, socket) do
    {:noreply,
     assign(
       socket,
       pictures: Pictures.list_pictures(),
       extension_dropdown_name: "Select extension",
       filter: ""
     )}
  end

  def handle_event("option_send_all", %{"value" => _extension}, socket) do
    {:noreply,
     assign(
       socket,
       pictures: Pictures.list_pictures(),
       extension_dropdown_name: "Select extension",
       current_page: 1
     )}
  end

  def handle_event("change_filter", %{"value" => filter}, socket) do
    pictures = Pictures.list_pictures() |> filter_pictures(filter)

    {:noreply,
     assign(socket,
       filter: filter,
       pictures: pictures,
       current_page: 1
     )}
  end

  defp filter_pictures(pictures, filter) when is_binary(filter) do
    if String.match?(filter, ~r/^\d+$/) do
      filter_by_id(pictures, String.to_integer(filter))
    else
      filter_by_file_name_or_post(pictures, filter)
    end
  end

  defp filter_by_id(pictures, id) do
    Enum.filter(pictures, fn picture -> picture.post_id == id end)
  end

  defp filter_by_file_name_or_post(pictures, filter) do
    Enum.filter(pictures, fn picture ->
      String.starts_with?(String.downcase(picture.file_name), String.downcase(filter)) ||
        (picture.post_id != nil &&
           Enum.any?([picture.post_title, picture.author, picture.email], fn str ->
             String.starts_with?(String.downcase(str), String.downcase(filter))
           end))
    end)
  end

  defp sort_by_extension(pictures, extension) do
    pictures
    |> Enum.filter(fn pic -> get_extension(pic.path) == extension end)
  end

  defp get_extension(path) do
    extension =
      path
      |> String.split("/")
      |> List.last()
      |> String.split(".")
      |> List.last()

    "." <> extension
  end

  defp picture_pages(assigns) do
    current_page = assigns.current_page
    limit = assigns.limit

    assigns.pictures
    |> Enum.slice((current_page * limit - limit)..(current_page * limit - 1))
  end

  def pictures_sorted_by(pictures, col, dir) when dir == "ASC",
    do: Enum.sort_by(pictures, &[&1[col]], :asc)

  def pictures_sorted_by(pictures, col, dir) when dir == "DESC",
    do: Enum.sort_by(pictures, &[&1[col]], :desc)

  defp pictures_pages(assigns) do
    current_page = assigns.current_page
    limit = assigns.limit

    assigns.pictures
    |> Enum.slice((current_page * limit - limit)..(current_page * limit - 1))
  end

  defp get_select_posts(picture) do
    current_post = [key: picture.post_title, value: picture.post_id]

    other_posts =
      Blog.get_posts_without_pictures()

    [current_post | other_posts]
  end
end
