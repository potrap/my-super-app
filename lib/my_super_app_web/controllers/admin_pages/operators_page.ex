defmodule MySuperAppWeb.OperatorsPage do
  @moduledoc """
  Operators Page
  """
  use MySuperAppWeb, :admin_surface_live_view

  alias MySuperApp.{CasinosAdmins, Operator}
  alias Moon.Design.{Table, Button, Drawer, Form, Modal, Snackbar}
  alias Moon.Design.Button.IconButton
  alias Moon.Design.Form.{Field, Input}
  alias Moon.Design.Table.Column
  alias Moon.Icons.GenericInfo

  on_mount {MySuperAppWeb.UserAuth, :mount_current_user}

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       operators: CasinosAdmins.get_operators(),
       form: to_form(CasinosAdmins.operator_changeset()),
       create_drawer_open: false,
       operator: %{id: "", name: ""},
       open_delete: false,
       open_create: false,
       open_delete_error: false,
       selected: nil,
       drawer_open: false,
       delete_modal_open: false,
       operator: %Operator{name: ""},
       selected_operator: %Operator{id: 0, name: ""}
     )}
  end

  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end

  def handle_event("open_drawer", %{"selected" => selected}, socket) do
    Drawer.open("drawer")
    sl_operator = CasinosAdmins.get_operator(selected)

    {:noreply,
     assign(socket,
       drawer_open: true,
       selected_operator: sl_operator,
       operator: %Operator{name: sl_operator.name}
     )}
  end

  def handle_event("close_drawer", _, socket) do
    Drawer.close("drawer")

    {:noreply, assign(socket, drawer_open: false)}
  end

  def handle_event("update_operator", %{"operator" => operator_params}, socket) do
    Process.send_after(self(), :clear_flash, 3000)

    case CasinosAdmins.update_operator(socket.assigns.selected_operator.id, operator_params) do
      {:ok, _operator} ->
        Drawer.close("drawer")

        {:noreply,
         assign(socket |> put_flash(:info, "Operator #{operator_params["name"]} updated!"),
           form: to_form(CasinosAdmins.operator_changeset()),
           drawer_open: false,
           operators: CasinosAdmins.get_operators()
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        Drawer.close("drawer")

        {:noreply,
         assign(socket |> put_flash(:error, "Can't update operator."),
           form: to_form(changeset),
           drawer_open: false,
           operators: CasinosAdmins.get_operators()
         )}
    end
  end

  def handle_event("open_drawer_create", _params, socket) do
    Drawer.open("create_drawer")

    {:noreply,
     assign(socket,
       create_drawer_open: true,
       open_create: false,
       open_delete_error: false
     )}
  end

  def handle_event("on_create_close", _params, socket) do
    Drawer.close("create_drawer")

    {:noreply, assign(socket, create_drawer_open: false)}
  end

  def handle_event("validate", %{"operator" => operator_attrs}, socket) do
    form =
      CasinosAdmins.operator_changeset(operator_attrs)
      |> Map.put(:action, :insert)
      |> to_form()

    {:noreply,
     assign(socket,
       form: form
     )}
  end

  def handle_event("save", %{"operator" => operator_params}, socket) do
    Drawer.close("create_drawer")

    case CasinosAdmins.create_operator(operator_params) do
      {:ok, _operator} ->
        {:noreply,
         assign(
           socket,
           operators: CasinosAdmins.get_operators(),
           open_create: true,
           create_drawer_open: false,
           form: to_form(CasinosAdmins.operator_changeset())
         )}

      {:error, _changeset} ->
        {:noreply,
         assign(socket,
           form: to_form(CasinosAdmins.operator_changeset()),
           create_drawer_open: false,
           open_delete_error: true
         )}
    end
  end

  def handle_event("modal_open", %{"value" => id}, socket) do
    Modal.open("modal_delete_operators")

    {:noreply,
     assign(socket,
       operator: CasinosAdmins.get_operator(id),
       open_delete: false,
       delete_modal_open: true
     )}
  end

  def handle_event("modal_cancel", _params, socket) do
    Modal.close("modal_delete_operators")
    {:noreply, assign(socket, delete_modal_open: false)}
  end

  def handle_event("modal_delete", %{"value" => id}, socket) do
    Modal.close("modal_delete_operators")

    case CasinosAdmins.delete_operator(id) do
      {:ok, _operator} ->
        {:noreply,
         assign(
           socket,
           operators: CasinosAdmins.get_operators(),
           open_delete: true,
           delete_modal_open: false
         )}

      {:error, _changeset} ->
        {:noreply, socket}
    end
  end
end
