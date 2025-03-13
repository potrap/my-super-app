defmodule MySuperAppWeb.HomeLiveAccordion do
  @moduledoc """
  Accordion
  """
  use MySuperAppWeb, :surface_live_view

  alias Moon.Design.{Accordion}

  @spec render(map()) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~F"""
    <div class="pl-10 pr-10 pt-10">
      <Accordion id="single-accordion" is_single_open class="bg-cell p-10 rounded-lg">
        <Accordion.Item>
          <Accordion.Header>Lorem</Accordion.Header>
          <Accordion.Content class="text-center">Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum
            has been the industry's standard dummy text ever since the 1500s, when an unknown printer
            took a galley of type and scrambled it to make a type specimen book.
          </Accordion.Content>
        </Accordion.Item>
        <Accordion.Item>
          <Accordion.Header>Ipsum</Accordion.Header>
          <Accordion.Content class="text-center">It has survived not only five centuries, but also the leap into electronic typesetting, remaining
            essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing
            Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem.
          </Accordion.Content>
        </Accordion.Item>
        <Accordion.Item>
          <Accordion.Header>Dolor</Accordion.Header>
          <Accordion.Content class="text-center">Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of
            classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin
            professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur,
            from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source.
          </Accordion.Content>
        </Accordion.Item>
      </Accordion>
    </div>
    """
  end
end
