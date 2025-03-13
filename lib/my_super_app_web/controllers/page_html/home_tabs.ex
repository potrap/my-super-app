defmodule MySuperAppWeb.HomeLiveTab do
  @moduledoc """
  Tabs
  """
  use MySuperAppWeb, :surface_live_view
  alias MySuperApp.DbQueries

  alias Moon.Design.{Tabs}

  alias Moon.Design.Table
  alias Moon.Design.Table.Column

  prop(selected, :list, default: [])

  data(rooms_with_phones, :any, default: [])
  data(rooms_without_phones, :any, default: [])
  data(phones_no_rooms, :any, default: [])

  def mount(_params, _session, socket) do
    {
      :ok,
      assign(
        socket,
        rooms_with_phones: DbQueries.rooms_with_phones(),
        rooms_without_phones: DbQueries.rooms_without_phones(),
        phones_no_rooms: DbQueries.phones_without_rooms(),
        selected: []
      )
    }
  end

  @spec render(map()) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~F"""
    <div style="padding: 0rem 16rem">
      <Tabs id="tabs-ex-1">
        <Tabs.List>
          <Tabs.Tab>Кімнати з телефонами</Tabs.Tab>
          <Tabs.Tab>Кімнати без телефонів</Tabs.Tab>
          <Tabs.Tab>Телефони не прив'язані до кімнат</Tabs.Tab>
        </Tabs.List>
        <Tabs.Panels>
          <Tabs.Panel>
            <Table items={room <- @rooms_with_phones} row_click="single_row_click" {=@selected}>
              <Column label="Room Number">
                {room.room_number}
              </Column>
              <Column label="Phones">
                {#for {phone, index} <- room.phones |> Enum.with_index(1)}
                  {#if index < room.phones |> Enum.count()}
                    {"#{phone.phone_number}, "}
                  {#else}
                    {phone.phone_number}
                  {/if}
                {/for}
              </Column>
            </Table>
          </Tabs.Panel>
          <Tabs.Panel>
            <Table items={room <- @rooms_without_phones}>
              <Column label="Room Number">
                {room.room_number}
              </Column>
            </Table>
          </Tabs.Panel>
          <Tabs.Panel>
            <Table items={phone <- @phones_no_rooms}>
              <Column label="Phone">
                {phone.phone_number}
              </Column>
            </Table>
          </Tabs.Panel>
        </Tabs.Panels>
      </Tabs>
    </div>
    """
  end

  def handle_event("single_row_click", %{"selected" => selected}, socket) do
    {:noreply, assign(socket, selected: [selected])}
  end
end
