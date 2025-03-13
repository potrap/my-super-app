defmodule MySuperAppWeb.UsersPage do
  @moduledoc """
  Users page
  """
  use MySuperAppWeb, :surface_live_view
  alias Moon.Design.Table.Column
  alias MySuperApp.{Accounts, CasinosAdmins}
  alias Moon.Design.{Table, Pagination, Button, Modal}
  alias Moon.Icons.{ControlsChevronRight, ControlsChevronLeft}
  alias Moon.Design.Search

  on_mount {MySuperAppWeb.UserAuth, :mount_current_user}

  def mount(_, _, socket) do
    Process.send_after(self(), :clear_flash, 3000)

    {
      :ok,
      assign(
        socket,
        users: Accounts.get_all_users_no_admins(),
        limit: 5,
        current_page: 1,
        filter: "",
        user: %{id: nil, username: nil},
        sort: [],
        selected: socket.assigns.current_user.id
      )
    }
  end

  def handle_event("set_open", %{"value" => id}, socket) do
    Modal.open("default_modal")

    {
      :noreply,
      assign(
        socket,
        user: CasinosAdmins.get_user(id),
        open_delete_snackbar: false
      )
    }
  end

  def handle_event("set_close_confirm", %{"value" => value}, socket) do
    Modal.close("default_modal")

    deleted_role = CasinosAdmins.get_user(value)
    CasinosAdmins.repo_delete(deleted_role)

    {
      :noreply,
      assign(
        socket
        |> redirect(to: ~p"/"),
        open_delete_snackbar: true,
        user: %{id: nil, name: deleted_role.username}
      )
    }
  end

  def handle_event("set_close", _, socket) do
    Modal.close("default_modal")
    {:noreply, socket}
  end

  def handle_event("change_filter", %{"value" => filter}, socket) do
    {:noreply,
     assign(socket,
       filter: filter,
       users:
         Enum.filter(Accounts.get_all_users_no_admins(), fn b ->
           String.starts_with?(String.downcase(b.username), [String.downcase(filter)])
         end),
       current_page: 1
     )}
  end

  def handle_event(
        "on_sorting_click",
        %{"sort-dir" => sort_dir, "sort-key" => sort_key},
        socket
      ) do
    {:noreply,
     assign(socket,
       users:
         users_sorted_by(Accounts.get_all_users_no_admins(), String.to_atom(sort_key), sort_dir),
       sort: ["#{sort_key}": sort_dir]
     )}
  end

  def handle_event("handle_paging_click", %{"value" => current_page}, socket) do
    current_page = String.to_integer(current_page)

    {:noreply,
     socket
     |> assign(current_page: current_page, models_10: users_pages(socket.assigns))}
  end

  def users_pages(assigns) do
    offset = (assigns.current_page - 1) * assigns.limit

    assigns.users
    |> Enum.slice(offset..(offset + assigns.limit - 1))
  end

  def users_sorted_by(users, col, dir) do
    case dir do
      "DEFAULT" ->
        Accounts.get_all_users_by_id()

      "ASC" ->
        users
        |> Enum.sort_by(&[&1[col]], :asc)

      "DESC" ->
        users
        |> Enum.sort_by(&[&1[col]], :desc)

      _ ->
        users
    end
  end

  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end
end
