defmodule MySuperAppWeb.AdminPage do
  @moduledoc """
  AdminPage
  """
  use MySuperAppWeb, :admin_surface_live_view
  alias Moon.Design.Table.Column
  alias MySuperApp.{User, Accounts, CasinosAdmins}
  alias Moon.Design.{Table, Snackbar, Button, Modal, Pagination, Drawer, Form, Search, Dropdown}
  alias Moon.Design.Form.{Field, Input, Select}
  alias Moon.Icons.{GenericInfo, ControlsChevronRight, ControlsChevronLeft}
  alias Moon.Icons.GenericUserSwapping
  alias Moon.Lego

  on_mount {MySuperAppWeb.UserAuth, :mount_current_user}

  def mount(_, _, socket) do
    users =
      if socket.assigns.current_user.role_id == 1 do
        Accounts.get_all_users_by_id()
      else
        Accounts.get_all_users_by_operator(socket.assigns.current_user.operator_id)
      end

    {
      :ok,
      assign(
        socket,
        users: users,
        user: %{id: nil, username: nil, email: nil},
        open_delete: false,
        limit: 5,
        current_page: 1,
        filter: "",
        sort: [],
        selected: socket.assigns.current_user.id,
        drawer_open: false,
        drawer_open_operator: false,
        modal_delete_open: false,
        selected_user: %User{id: 0, username: "", email: nil, role_id: nil},
        form: to_form(Accounts.user_changeset()),
        items: CasinosAdmins.roles_name(),
        dropdown_name: "Select users by role",
        dropdown_name_operators: "Select users by operator",
        items_operators: CasinosAdmins.operators_name(),
        selected_role_id: nil,
        selected_oper_id: nil
      )
    }
  end

  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end

  def get_operator(id), do: CasinosAdmins.get_operator(id).name

  def get_role_name(id), do: CasinosAdmins.get_role_name(id).name

  def handle_event("option_send", %{"value" => role}, socket) do
    role_id = CasinosAdmins.get_roles_by_name(role).id

    Dropdown.close("dropdown_roles")

    {:noreply,
     assign(
       socket,
       users: Accounts.get_all_users_by_role(role_id),
       dropdown_name_operators: "Select users by operator",
       dropdown_name: role,
       current_page: 1,
       selected_role_id: role_id,
       selected_oper_id: nil,
       filter: ""
     )}
  end

  def handle_event("option_send_all", %{"value" => _oper}, socket) do
    users =
      if socket.assigns.current_user.role_id == 1 do
        Accounts.get_all_users_by_id()
      else
        Accounts.get_all_users_by_operator(socket.assigns.current_user.operator_id)
      end

    {:noreply,
     assign(
       socket,
       users: users,
       dropdown_name: "Select users by role",
       dropdown_name_operators: "Select users by operator",
       current_page: 1,
       selected_role_id: nil,
       selected_oper_id: nil,
       filter: ""
     )}
  end

  def handle_event("option_send_oper", %{"value" => oper}, socket) do
    oper_id = CasinosAdmins.get_operator_by_name(oper).id

    Dropdown.close("dropdown_operators")

    {:noreply,
     assign(
       socket,
       users: Accounts.select_users_by_operator(oper_id),
       dropdown_name: "Select users by role",
       dropdown_name_operators: oper,
       current_page: 1,
       selected_role_id: nil,
       selected_oper_id: oper_id,
       filter: ""
     )}
  end

  def handle_event("option_send_all_oper", %{"value" => _oper}, socket) do
    {:noreply,
     assign(
       socket,
       users: Accounts.get_all_users_by_id(),
       dropdown_name_operators: "Select users by operator",
       dropdown_name: "Select users by role",
       current_page: 1,
       selected_role_id: nil,
       selected_oper_id: nil,
       filter: ""
     )}
  end

  def handle_event("open_drawer", %{"value" => id}, socket) do
    Drawer.open("drawer")
    user = CasinosAdmins.get_user(id)

    {:noreply,
     assign(socket,
       drawer_open: true,
       selected_user: user,
       user: %User{username: user.username}
     )}
  end

  def handle_event("close_drawer", _, socket) do
    Drawer.close("drawer")

    {:noreply, assign(socket, drawer_open: false)}
  end

  def handle_event("update_user", %{"user" => user_params}, socket) do
    Process.send_after(self(), :clear_flash, 3000)

    case Accounts.update_user(socket.assigns.selected_user.id, user_params) do
      {:ok, _user} ->
        Drawer.close("drawer")

        {:noreply,
         assign(
           socket
           |> put_flash(:info, "User #{user_params["username"]} was given a role permission"),
           form: to_form(Accounts.user_changeset()),
           drawer_open: false,
           users:
             change_user_list_after_role_update(
               socket.assigns.selected_user.id,
               user_params,
               socket
             ),
           filter: ""
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        Drawer.close("drawer")

        {:noreply,
         assign(socket |> put_flash(:error, "Can't give user role permission."),
           form: to_form(changeset),
           drawer_open: false,
           filter: ""
         )}
    end
  end

  def handle_event("delete_role", _, socket) do
    Process.send_after(self(), :clear_flash, 3000)
    user = CasinosAdmins.get_user(socket.assigns.selected_user.id)

    updated = Ecto.Changeset.change(user, role_id: nil)

    CasinosAdmins.update_repo(updated)

    {:noreply,
     assign(socket |> put_flash(:info, "Role deleted"),
       drawer_open: false,
       users: change_user_list_after_role_delete(socket.assigns.selected_user.id, socket)
     )}
  end

  def handle_event("validate", %{"user" => user_attrs}, socket) do
    form =
      Accounts.user_changeset(user_attrs)
      |> Map.put(:action, :insert)
      |> to_form()

    {:noreply,
     assign(socket,
       form: form
     )}
  end

  def handle_event("open_drawer_operator", %{"value" => id}, socket) do
    Drawer.open("drawer_operator")
    user = CasinosAdmins.get_user(id)

    {:noreply,
     assign(socket,
       drawer_open_operator: true,
       selected_user: user,
       user: %User{username: user.username}
     )}
  end

  def handle_event("close_drawer_operator", _, socket) do
    Drawer.close("drawer_operator")

    {:noreply, assign(socket, drawer_open_operator: false)}
  end

  def handle_event("update_user_operator", %{"user" => user_params}, socket) do
    Process.send_after(self(), :clear_flash, 3000)

    case Accounts.update_user(socket.assigns.selected_user.id, user_params) do
      {:ok, _user} ->
        Drawer.close("drawer_operator")

        {:noreply,
         assign(
           socket
           |> put_flash(:info, "User #{user_params["username"]} was given a operator permission"),
           form: to_form(Accounts.user_changeset()),
           drawer_open_operator: false,
           users:
             change_user_list_after_operator_update(
               socket.assigns.selected_user.id,
               user_params,
               socket
             )
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        Drawer.close("drawer_operator")

        {:noreply,
         assign(socket |> put_flash(:error, "Can't give user operator permission."),
           form: to_form(changeset),
           drawer_open_operator: false
         )}
    end
  end

  def handle_event("delete_operator", _, socket) do
    Process.send_after(self(), :clear_flash, 3000)

    user = CasinosAdmins.get_user(socket.assigns.selected_user.id)

    updated = Ecto.Changeset.change(user, operator_id: nil)

    CasinosAdmins.update_repo(updated)

    {:noreply,
     assign(socket |> put_flash(:info, "Operator permissions were removed"),
       drawer_open_operator: false,
       users: change_user_list_after_operator_delete(socket.assigns.selected_user.id, socket)
     )}
  end

  def handle_event(
        "handle_sorting_click",
        %{"sort-dir" => sort_dir, "sort-key" => sort_key},
        socket
      ) do
    {:noreply,
     assign(socket,
       users: users_sorted_by(Accounts.get_all_users_by_id(), String.to_atom(sort_key), sort_dir),
       sort: ["#{sort_key}": sort_dir]
     )}
  end

  def handle_event("change_filter", %{"value" => filter}, socket) do
    is_number = String.match?(filter, ~r/^\d+$/)

    pictures =
      if is_number do
        Enum.filter(get_users_by_dropdown(socket), fn b ->
          b.id == String.to_integer(filter)
        end)
      else
        Enum.filter(get_users_by_dropdown(socket), fn b ->
          String.starts_with?(String.downcase(b.username), String.downcase(filter))
        end)
      end

    {:noreply,
     assign(socket,
       filter: filter,
       pictures: pictures,
       current_page: 1
     )}
  end

  def handle_event("set_open", %{"value" => id}, socket) do
    Modal.open("default_modal")

    {
      :noreply,
      assign(
        socket,
        user: CasinosAdmins.get_user(id),
        open_delete: false,
        modal_delete_open: true
      )
    }
  end

  def handle_event("set_close_confirm", %{"value" => id}, socket) do
    Modal.close("default_modal")

    deleted_user = CasinosAdmins.get_user(id)
    CasinosAdmins.repo_delete(deleted_user)

    if socket.assigns.current_page >
         ceil(Enum.count(Accounts.get_all_users_by_id()) / socket.assigns.limit) do
      {
        :noreply,
        assign(
          socket,
          users: get_sites_after_deletion(id, socket),
          current_page: socket.assigns.current_page - 1,
          open_delete: true,
          modal_delete_open: false,
          user: %{id: nil, username: deleted_user.username, email: nil}
        )
      }
    else
      {
        :noreply,
        assign(
          socket,
          users: get_sites_after_deletion(id, socket),
          modal_delete_open: false,
          open_delete: true
        )
      }
    end
  end

  def handle_event("set_close", _, socket) do
    Modal.close("default_modal")
    {:noreply, socket}
  end

  def handle_event("handle_paging_click", %{"value" => current_page}, socket) do
    current_page = String.to_integer(current_page)

    {:noreply,
     socket
     |> assign(current_page: current_page, models_10: users_pages(socket.assigns))}
  end

  def users_sorted_by(users, col, dir) when dir == "ASC",
    do: Enum.sort_by(users, &[&1[col]], :asc)

  def users_sorted_by(users, col, dir) when dir == "DESC",
    do: Enum.sort_by(users, &[&1[col]], :desc)

  defp users_pages(assigns) do
    current_page = assigns.current_page
    limit = assigns.limit

    assigns.users
    |> Enum.slice((current_page * limit - limit)..(current_page * limit - 1))
  end

  defp get_sites_after_deletion(id, socket) do
    socket.assigns.users
    |> Enum.filter(fn user -> user.id != String.to_integer(id) end)
  end

  defp change_user_list_after_role_update(user_id, user_params, socket) do
    Enum.map(socket.assigns.users, fn user ->
      if user.id == user_id do
        %{
          user
          | email: user_params["email"],
            role_id: user_params["role_id"],
            username: user_params["username"]
        }
      else
        user
      end
    end)
  end

  defp change_user_list_after_role_delete(user_id, socket) do
    Enum.map(socket.assigns.users, fn user ->
      if user.id == user_id do
        %{user | role_id: nil}
      else
        user
      end
    end)
  end

  defp change_user_list_after_operator_update(user_id, user_params, socket) do
    Enum.map(socket.assigns.users, fn user ->
      if user.id == user_id do
        %{
          user
          | email: user_params["email"],
            operator_id: user_params["operator_id"],
            username: user_params["username"]
        }
      else
        user
      end
    end)
  end

  defp change_user_list_after_operator_delete(user_id, socket) do
    Enum.map(socket.assigns.users, fn user ->
      if user.id == user_id do
        %{user | operator_id: nil}
      else
        user
      end
    end)
  end

  defp prioritize_operator(selected_id) do
    {selected_operator, other_operators} =
      Enum.split_with(CasinosAdmins.operators_for_select(), fn operator ->
        Keyword.get(operator, :value) == selected_id
      end)

    selected_operator ++ other_operators
  end

  defp prioritize_role(role_id, operator_id) do
    {selected_role, other_roles} =
      Enum.split_with(CasinosAdmins.roles_for_select(operator_id), fn role ->
        Keyword.get(role, :value) == role_id
      end)

    selected_role ++ other_roles
  end

  defp get_users_by_dropdown(socket) do
    cond do
      socket.assigns.dropdown_name != "Select users by role" ->
        Accounts.get_all_users_by_role(socket.assigns.selected_role_id)

      socket.assigns.dropdown_name_operators != "Select users by operator" ->
        Accounts.select_users_by_operator(socket.assigns.selected_oper_id)

      true ->
        if socket.assigns.current_user.role_id == 1 do
          Accounts.get_all_users_by_id()
        else
          Accounts.get_all_users_by_operator(socket.assigns.current_user.operator_id)
        end
    end
  end
end
