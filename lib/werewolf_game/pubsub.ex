defmodule WerewolfGame.PubSub do
  def subscribe(topic) do
    Phoenix.PubSub.subscribe(WerewolfGame.PubSub, topic)
  end

  def broadcast(topic, event, payload) do
    Phoenix.PubSub.broadcast(
      WerewolfGame.PubSub,
      topic,
      {event, payload}
    )
    {:ok, payload}
  end
end
