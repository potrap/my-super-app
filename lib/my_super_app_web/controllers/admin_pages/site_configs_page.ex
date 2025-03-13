defmodule MySuperAppWeb.SiteConfigsPage do
  @moduledoc """
  AdminPage
  """
  use MySuperAppWeb, :admin_surface_live_view

  alias Moon.Design.Table.Column
  alias MySuperApp.CasinosAdmins
  alias Moon.Design.{Table, Snackbar, Button, Modal, Pagination, Form, Search}
  alias Moon.Icons.{GenericInfo, ControlsChevronRight, ControlsChevronLeft}
  alias Moon.Design.Form.{Field, Input, Select}
  alias Moon.Design.Button.IconButton
  alias Moon.Design.Dropdown
  alias Moon.Lego

  on_mount {MySuperAppWeb.UserAuth, :mount_current_user}

  def mount(_, _, socket) do
    {
      :ok,
      assign(
        socket,
        form: to_form(CasinosAdmins.site_changeset()),
        sites: CasinosAdmins.get_all_sites_by_id(),
        site: %{id: nil, name: nil},
        open_delete: false,
        limit: 5,
        current_page: 1,
        filter: "",
        sort: [],
        site_modal_open: false,
        site_delete_open: false,
        open_delete_snackbar: false,
        open_create_snackbar: false,
        open_create_snackbar_error: false,
        items: CasinosAdmins.operators_name(),
        dropdown_name: "Select sites by operator",
        operator_id: nil,
        from: "",
        to: ""
      )
    }
  end

  def handle_event("open_site", %{"value" => value}, socket) do
    {:noreply, push_redirect(socket, to: "/admin/site-configs/site/#{value}")}
  end

  def handle_event("option_send", %{"value" => oper}, socket) do
    operator_id = CasinosAdmins.get_operator_by_name(oper).id

    Dropdown.close("dropdown")

    params =
      form_params(
        socket.assigns.filter,
        socket.assigns.from,
        socket.assigns.to,
        socket.assigns.sort,
        operator_id
      )

    {:noreply,
     assign(
       socket,
       sites: CasinosAdmins.get_all_sites_by_id(params),
       dropdown_name: oper,
       current_page: 1,
       operator_id: operator_id
     )}
  end

  def handle_event("option_send_all", %{"value" => _oper}, socket) do
    params =
      form_params(
        socket.assigns.filter,
        socket.assigns.from,
        socket.assigns.to,
        socket.assigns.sort,
        nil
      )

    {:noreply,
     assign(
       socket,
       sites: CasinosAdmins.get_all_sites_by_id(params),
       dropdown_name: "All Operators",
       current_page: 1,
       operator_id: nil
     )}
  end

  def handle_event("change", %{"id" => id, "status" => status}, socket) do
    case status do
      "ACTIVE" ->
        CasinosAdmins.update_site_config(id, %{status: "STOPPED"})

        {:noreply,
         assign(socket,
           sites:
             CasinosAdmins.get_all_sites_by_id(
               socket
               |> form_socket_params()
             )
         )}

      "STOPPED" ->
        CasinosAdmins.update_site_config(id, %{status: "ACTIVE"})

        {:noreply,
         assign(socket,
           sites:
             CasinosAdmins.get_all_sites_by_id(
               socket
               |> form_socket_params()
             )
         )}
    end
  end

  def handle_event(
        "handle_sorting_click",
        %{"sort-dir" => sort_dir, "sort-key" => sort_key},
        socket
      ) do
    params =
      form_params(
        socket.assigns.filter,
        socket.assigns.from,
        socket.assigns.to,
        %{String.to_atom(sort_key) => sort_dir},
        socket.assigns.operator_id
      )

    {:noreply,
     assign(socket,
       sites: CasinosAdmins.get_all_sites_by_id(params),
       sort: ["#{sort_key}": sort_dir]
     )}
  end

  def handle_event("set_open", %{"value" => id}, socket) do
    Modal.open("default_modal")

    {
      :noreply,
      assign(
        socket,
        site: CasinosAdmins.get_site(id),
        open_delete: false,
        open_create_snackbar: false,
        site_delete_open: true
      )
    }
  end

  def handle_event("set_close_confirm", %{"value" => value}, socket) do
    Modal.close("default_modal")

    deleted_site = CasinosAdmins.get_site(value)
    CasinosAdmins.repo_delete(deleted_site)

    if socket.assigns.current_page >
         ceil(Enum.count(CasinosAdmins.get_all_sites_by_id()) / socket.assigns.limit) do
      {
        :noreply,
        assign(
          socket,
          sites: CasinosAdmins.get_all_sites_by_operator(socket.assigns.operator_id),
          current_page: socket.assigns.current_page - 1,
          open_delete: true,
          site: %{id: nil, name: deleted_site.name},
          open_delete_snackbar: true,
          site_delete_open: false,
          open_create_snackbar: false
        )
      }
    else
      {
        :noreply,
        assign(
          socket,
          sites: CasinosAdmins.get_all_sites_by_operator(socket.assigns.operator_id),
          open_delete: true,
          site_delete_open: false,
          open_delete_snackbar: true
        )
      }
    end
  end

  def handle_event("set_close", _, socket) do
    Modal.close("default_modal")
    {:noreply, assign(socket, site_delete_open: false)}
  end

  def handle_event("open_create_modal", _, socket) do
    Modal.open("create_site_modal")

    {
      :noreply,
      assign(
        socket,
        open_delete_snackbar: false,
        open_create_snackbar: false,
        open_create_snackbar_error: false,
        site_modal_open: true
      )
    }
  end

  def handle_event("close_create_modal", _, socket) do
    Modal.close("create_site_modal")

    {:noreply, socket}
  end

  def handle_event("change_filter", %{"value" => filter}, socket) do
    params =
      form_params(
        filter,
        socket.assigns.from,
        socket.assigns.to,
        socket.assigns.sort,
        socket.assigns.operator_id
      )

    {:noreply,
     assign(socket,
       filter: filter,
       sites: CasinosAdmins.get_all_sites_by_id(params),
       current_page: 1,
       dropdown_name: "Select sites by operator"
     )}
  end

  def handle_event("filter_dates", %{"site" => [from, to]}, socket) do
    params =
      form_params(
        socket.assigns.filter,
        from,
        to,
        socket.assigns.sort,
        socket.assigns.operator_id
      )

    {:noreply,
     assign(socket,
       sites: CasinosAdmins.get_all_sites_by_id(params),
       from: from,
       to: to
     )}
  end

  def handle_event("validate", %{"site" => site_attrs}, socket) do
    form =
      CasinosAdmins.site_changeset(site_attrs)
      |> Map.put(:action, :insert)
      |> to_form()

    {:noreply,
     assign(socket,
       form: form
     )}
  end

  def handle_event("save", %{"site" => site_params}, socket) do
    Modal.close("create_site_modal")

    site_params = Map.put(site_params, "operator_id", socket.assigns.current_user.operator_id)

    case CasinosAdmins.create_site(site_params) do
      {:ok, _site} ->
        {:noreply,
         assign(
           socket,
           form: to_form(CasinosAdmins.site_changeset()),
           site_modal_open: false,
           open_delete_snackbar: false,
           sites: CasinosAdmins.get_all_sites_by_id(),
           open_create_snackbar: true,
           site: %{id: nil, name: site_params["name"]}
         )}

      {:error, _changeset} ->
        {:noreply,
         assign(socket,
           form: to_form(CasinosAdmins.site_changeset()),
           site_modal_open: false,
           open_delete_snackbar: false,
           sites: CasinosAdmins.get_all_sites_by_operator(socket.assigns.operator_id),
           open_create_snackbar_error: true
         )}
    end
  end

  def handle_event("handle_paging_click", %{"value" => current_page}, socket) do
    current_page = String.to_integer(current_page)

    {:noreply,
     socket
     |> assign(current_page: current_page, models_10: sites_pages(socket.assigns))}
  end

  def handle_event("clear_filter", _params, socket) do
    {:noreply,
     socket
     |> assign(
       sites: CasinosAdmins.get_all_sites_by_id(),
       from: "",
       to: "",
       operator_id: nil,
       filter: "",
       sort: []
     )}
  end

  def sites_sorted_by(sites, col, dir) when dir == "ASC",
    do: Enum.sort_by(sites, &[&1[col]], :asc)

  def sites_sorted_by(sites, col, dir) when dir == "DESC",
    do: Enum.sort_by(sites, &[&1[col]], :desc)

  defp sites_pages(assigns) do
    current_page = assigns.current_page
    limit = assigns.limit

    assigns.sites
    |> Enum.slice((current_page * limit - limit)..(current_page * limit - 1))
  end

  defp form_params(search, from, to, sort, operator_id) do
    %{
      "search" => search,
      "from" => from,
      "to" => to,
      "sort" => sort,
      "operator_id" => operator_id
    }
  end

  defp form_socket_params(socket) do
    %{
      "search" => socket.assigns.filter,
      "from" => socket.assigns.from,
      "to" => socket.assigns.to,
      "sort" => socket.assigns.sort,
      "operator_id" => socket.assigns.operator_id
    }
  end
end
