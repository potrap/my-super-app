defmodule MySuperAppWeb.AdminWelcomePage do
  @moduledoc """
  AdminPage
  """
  use MySuperAppWeb, :admin_surface_live_view

  on_mount {MySuperAppWeb.UserAuth, :mount_current_user}

  @spec render(map()) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~F"""
    <div class="pl-10 pr-10 pt-10">
      {#if @current_user.operator_id != nil}
        <p class="text-moon-24 mb-8">
          Welcome, Operator! As an Operator, you have comprehensive access across the platform. Your permissions include:
        </p>
        <ul class="text-moon-18">
          <li>* Full access to all admin pages</li>
          <br>
          <li>* The ability to create and delete sites</li>
          <br>
          <li>* The ability to create and delete roles</li>
          <br>
          <li>* Access to users pages</li>
        </ul>
      {#elseif @current_user.role_id == 1}
        <p class="text-moon-24 mb-8">
          Welcome, Super Admin! As a Super Admin, you have the following permissions:
          <ul class="text-moon-18">
            <li>* Access to the operator pages</li>
            <br>
            <li>* Partial access to the registred users pages</li>
            <br>
          </ul>
        </p>
      {#else}
        <p class="text-moon-24 mb-8">
          Welcome, Admin! As a Regular Admin, you have the following permissions:
          <ul class="text-moon-18">
            <li>* Access to the users pages</li>
            <br>
            <li>* Access to the blog pages</li>
            <br>
            <li>* Partial access to the registred users pages</li>
            <br>
          </ul>
        </p>
      {/if}
    </div>
    """
  end
end
