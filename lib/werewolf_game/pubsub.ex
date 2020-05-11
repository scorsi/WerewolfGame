defmodule WerewolfGame.PubSub do
  @moduledoc false

  def subscribe(topic) do
    Phoenix.PubSub.subscribe(WerewolfGame.PubSub, topic)
  end

  def unsubscribe(topic) do
    Phoenix.PubSub.unsubscribe(WerewolfGame.PubSub, topic)
  end

  def broadcast(topic, event, payload \\ nil) do
    Phoenix.PubSub.broadcast(
      WerewolfGame.PubSub,
      topic,
      %{event: event, payload: payload}
    )

    {:ok, payload}
  end
end
