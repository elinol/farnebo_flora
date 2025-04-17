defmodule FarneboFloraWeb.PlantLive.Index do
  use FarneboFloraWeb, :live_view

  alias FarneboFlora.Plants
  alias FarneboFlora.Plants.Plant

  @impl true
  def mount(_params, _session, socket) do
    families = Plants.list_families() |> Enum.map(&{String.capitalize(&1.name), &1.id})

    {:ok,
     socket
     |> assign(:filter_form, to_form(%{"family_id" => ""}))
     |> assign(:families, families)
     |> stream(:plants, Plants.list_plants())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Plant")
    |> assign(:plant, Plants.get_plant!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Plant")
    |> assign(:plant, %Plant{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Plants")
    |> assign(:plant, nil)
  end

  @impl true
  def handle_event("filter", %{"family_id" => ""}, socket) do
    {:noreply, stream(socket, :plants, Plants.list_plants(), reset: true)}
  end

  def handle_event("filter", %{"family_id" => family_id}, socket) do
    plants = Plants.list_plants_by_family(family_id)
    {:noreply, stream(socket, :plants, plants, reset: true)}
  end

  @impl true
  def handle_info({FarneboFloraWeb.PlantLive.FormComponent, {:saved, plant}}, socket) do
    {:noreply, stream_insert(socket, :plants, plant)}
  end
end
