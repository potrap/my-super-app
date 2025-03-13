defmodule MySuperAppWeb.ErrorPermission do
  @moduledoc """
  LiveMenu
  """
  use MySuperAppWeb, :surface_live_view

  on_mount {MySuperAppWeb.UserAuth, :mount_current_user}

  @spec render(map()) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~F"""
    <div class="text-center">
      <p class="text-moon-64 transition-colors">Permission Denied</p>
    </div>

    <div class="pl-10 pr-10 pt-10">
      {#if @current_user.role_id == nil && @current_user.operator_id != nil}
        <p class="text-moon-24 mb-8 text-center">
          As operator you cant visit this page
        </p>
      {#elseif @current_user.role_id == nil && @current_user.operator_id == nil}
        <p class="text-moon-24 mb-8 text-center">
          You are regular user , you dont have access to admin part
        </p>
      {#else}
        <p class="text-moon-24 mb-8 text-center">
          As Admin you cant visit this page
        </p>
      {/if}

      {#if @current_user.role_id == nil && @current_user.operator_id == nil}
        <.link href={~p"/users"}>
          <button
            id="menu_item_permission"
            class="bg-white  rounded-lg w-full text-black pr-4 pl-4 pt-2 pb-2 text-base flex justify-start border-solid border-2"
          >
            GO TO USER PAGE
          </button>
        </.link>
      {#elseif @current_user.role_id != 1 && @current_user.operator_id == nil && @current_user.role_id != nil}
        <.link href={~p"/users"}>
          <button
            id="menu_item_permission"
            class="bg-white rounded-lg w-full text-black pr-4 pl-4 pt-2 pb-2 text-base flex justify-start border-solid border-2"
          >
            GO TO USERS PAGE
          </button>
        </.link>
      {#else}
        <.link href={~p"/admin"}>
          <button
            id="menu_item_permission"
            class="bg-white rounded-lg w-full text-black pr-4 pl-4 pt-2 pb-2 text-base flex justify-start border-solid border-2"
          >
            GO TO ADMIN PAGE
          </button>
        </.link>
      {/if}
    </div>
    """
  end
end
