defmodule FarneboFloraWeb.PlantLive.FormComponent do
  use FarneboFloraWeb, :live_component

  alias FarneboFlora.Plants

  @frequency_classes [
    {"Tämligen allmän", "ta"},
    {"Allmän", "a"},
    {"Mindre allmän", "ma"},
    {"Rar", "r"},
    {"Sällsynt", "s"},
    {"Utdöd", "x"}
  ]

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage plant records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="plant-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:latin_name]} type="text" label="Latin name" />
        <.input field={@form[:local_name]} type="text" label="Local name" />
        <.input
          field={@form[:frequency_class]}
          type="select"
          label="Frequency class"
          options={@frequency_classes}
        />
        <.input field={@form[:location]} type="text" label="Location" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Plant</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{plant: plant} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Plants.change_plant(plant))
     end)}
  end

  @impl true
  def handle_event("validate", %{"plant" => plant_params}, socket) do
    changeset = Plants.change_plant(socket.assigns.plant, plant_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"plant" => plant_params}, socket) do
    save_plant(socket, socket.assigns.action, plant_params)
  end

  defp save_plant(socket, :edit, plant_params) do
    case Plants.update_plant(socket.assigns.plant, plant_params) do
      {:ok, plant} ->
        notify_parent({:saved, plant})

        {:noreply,
         socket
         |> put_flash(:info, "Plant updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_plant(socket, :new, plant_params) do
    case Plants.create_plant(plant_params) do
      {:ok, plant} ->
        notify_parent({:saved, plant})

        {:noreply,
         socket
         |> put_flash(:info, "Plant created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
