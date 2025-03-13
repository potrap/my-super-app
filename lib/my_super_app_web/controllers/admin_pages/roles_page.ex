defmodule MySuperAppWeb.RolesPage do
  @moduledoc """
  AdminPage
  """
  use MySuperAppWeb, :admin_surface_live_view

  alias Moon.Design.Table.Column
  alias MySuperApp.{Role, CasinosAdmins}
  alias Moon.Design.{Table, Snackbar, Button, Modal, Pagination, Form, Search, Drawer}
  alias Moon.Design.Form.{Field, Input}
  alias Moon.Icons.{GenericInfo, ControlsChevronRight, ControlsChevronLeft}
  alias Moon.Design.Dropdown
  alias Moon.Lego

  on_mount {MySuperAppWeb.UserAuth, :mount_current_user}

  def mount(_, _, socket) do
    {
      :ok,
      assign(
        socket,
        form: to_form(CasinosAdmins.role_changeset()),
        roles: CasinosAdmins.get_all_roles_by_id(),
        role: %{id: nil, name: nil},
        open_delete_snackbar: false,
        open_create_snackbar: false,
        open_create_snackbar_error: false,
        limit: 5,
        current_page: 1,
        filter: "",
        sort: [],
        role_modal_open: false,
        items: CasinosAdmins.operators_name(),
        dropdown_name: "Select Operator",
        selected: nil,
        drawer_open: false,
        role_delete_open: false,
        role: %Role{name: ""},
        selected_role: %Role{id: 0, name: ""}
      )
    }
  end

  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end

  def get_name(id), do: CasinosAdmins.get_operator(id).name

  def handle_event("open_drawer", %{"selected" => selected}, socket) do
    Drawer.open("drawer")
    sl_role = CasinosAdmins.get_role(selected)

    {:noreply,
     assign(socket,
       drawer_open: true,
       selected_role: sl_role,
       role: %Role{name: sl_role.name}
     )}
  end

  def handle_event("close_drawer", _, socket) do
    Drawer.close("drawer")

    {:noreply, assign(socket, drawer_open: false)}
  end

  def handle_event("update_role", %{"role" => role_params}, socket) do
    Process.send_after(self(), :clear_flash, 3000)

    case CasinosAdmins.update_role(socket.assigns.selected_role.id, role_params) do
      {:ok, _role} ->
        Drawer.close("drawer")

        {:noreply,
         assign(socket |> put_flash(:info, "Role #{role_params["name"]} updated!"),
           form: to_form(CasinosAdmins.role_changeset()),
           drawer_open: false,
           roles: CasinosAdmins.get_all_roles_by_id()
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        Drawer.close("drawer")

        {:noreply,
         assign(socket |> put_flash(:error, "Can't update role."),
           form: to_form(changeset),
           drawer_open: false,
           roles: CasinosAdmins.get_all_roles_by_id()
         )}
    end
  end

  def handle_event("option_send", %{"value" => oper}, socket) do
    operator = CasinosAdmins.get_operator_by_name(oper).id

    Dropdown.close("dropdown")

    {:noreply,
     assign(
       socket,
       roles: CasinosAdmins.get_all_roles_by_operator(operator),
       dropdown_name: oper,
       current_page: 1
     )}
  end

  def handle_event("option_send_all", %{"value" => _oper}, socket) do
    {:noreply,
     assign(
       socket,
       roles: CasinosAdmins.get_all_roles_by_id(),
       dropdown_name: "All Operators",
       current_page: 1
     )}
  end

  def handle_event("change_filter", %{"value" => filter}, socket) do
    {:noreply,
     assign(socket,
       filter: filter,
       roles:
         Enum.filter(CasinosAdmins.get_all_roles_by_id(), fn b ->
           String.starts_with?(String.downcase(b.name), [String.downcase(filter)])
         end),
       current_page: 1,
       dropdown_name: "All_operators"
     )}
  end

  def handle_event("set_open", %{"value" => id}, socket) do
    Modal.open("default_modal")

    {
      :noreply,
      assign(
        socket,
        role: CasinosAdmins.get_role(id),
        open_delete_snackbar: false,
        role_delete_open: true
      )
    }
  end

  def handle_event("set_close_confirm", %{"value" => value}, socket) do
    Modal.close("default_modal")

    deleted_role = CasinosAdmins.get_role(value)

    CasinosAdmins.repo_delete(deleted_role)

    if socket.assigns.current_page >
         ceil(Enum.count(CasinosAdmins.get_all_roles_by_id()) / socket.assigns.limit) do
      {
        :noreply,
        assign(
          socket,
          roles: CasinosAdmins.get_all_roles_by_id(),
          current_page: socket.assigns.current_page - 1,
          open_delete_snackbar: true,
          role: %{id: nil, name: deleted_role.name},
          dropdown_name: "Select_operator",
          role_delete_open: false
        )
      }
    else
      {
        :noreply,
        assign(
          socket,
          roles: CasinosAdmins.get_all_roles_by_id(),
          open_delete_snackbar: true,
          dropdown_name: "Select_operator",
          role_delete_open: false
        )
      }
    end
  end

  def handle_event("set_close", _, socket) do
    Modal.close("default_modal")
    {:noreply, assign(socket, role_delete_open: false)}
  end

  def handle_event("open_create_modal", _, socket) do
    Modal.open("create_role_modal")

    {
      :noreply,
      assign(
        socket,
        open_delete_snackbar: false,
        open_create_snackbar: false,
        open_create_snackbar_error: false,
        role_modal_open: true
      )
    }
  end

  def handle_event("close_create_modal", _, socket) do
    Modal.close("create_role_modal")
    {:noreply, socket}
  end

  def handle_event("validate", %{"role" => role_attrs}, socket) do
    form =
      CasinosAdmins.role_changeset(role_attrs)
      |> Map.put(:action, :insert)
      |> to_form()

    {:noreply,
     assign(socket,
       form: form
     )}
  end

  def handle_event("save", %{"role" => role_params}, socket) do
    Modal.close("create_role_modal")

    role_params = Map.put(role_params, "operator_id", socket.assigns.current_user.operator_id)

    case CasinosAdmins.create_role(role_params) do
      {:ok, _role} ->
        {:noreply,
         assign(
           socket,
           form: to_form(CasinosAdmins.role_changeset()),
           role_modal_open: false,
           roles: CasinosAdmins.get_all_roles_by_id(),
           open_create_snackbar: true,
           dropdown_name: "All operators"
         )}

      {:error, _changeset} ->
        {:noreply,
         assign(socket,
           form: to_form(CasinosAdmins.role_changeset()),
           role_modal_open: false,
           roles: CasinosAdmins.get_all_roles_by_id(),
           open_create_snackbar_error: true
         )}
    end
  end

  def handle_event("handle_paging_click", %{"value" => current_page}, socket) do
    current_page = String.to_integer(current_page)

    {:noreply,
     socket
     |> assign(current_page: current_page, models_10: roles_pages(socket.assigns))}
  end

  def handle_event(
        "handle_sorting_click",
        %{"sort-dir" => sort_dir, "sort-key" => sort_key},
        socket
      ) do
    {:noreply,
     assign(socket,
       roles:
         roles_sorted_by(
           CasinosAdmins.get_all_roles_by_id(),
           String.to_atom(sort_key),
           sort_dir
         ),
       sort: ["#{sort_key}": sort_dir]
     )}
  end

  def roles_sorted_by(roles, col, dir) when dir == "ASC",
    do: Enum.sort_by(roles, &[&1[col]], :asc)

  def roles_sorted_by(roles, col, dir) when dir == "DESC",
    do: Enum.sort_by(roles, &[&1[col]], :desc)

  defp roles_pages(assigns) do
    current_page = assigns.current_page
    limit = assigns.limit

    assigns.roles
    |> Enum.slice((current_page * limit - limit)..(current_page * limit - 1))
  end
end
