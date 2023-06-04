defmodule ServerProcess do
  # start/1 takes a callback module as arg
  def start(callback_module) do
    spawn(fn ->
      # get inital state from the callback_module init/0 func(which the callback_module needs to satisfy)
      initial_state = callback_module.init()

      # start the process loop with the callback_module and the inital_state
      loop(callback_module, initial_state)
    end)
  end

  defp loop(callback_module, current_state) do
    receive do
      {request, caller} ->
        # calls the callback_module to process the message
        # handle_call must implement this interface: takes request and current state and returns a {request, new_state} tuple
        {response, new_state} = callback_module.handle_call(request, current_state)

        # sends the response back
        send(caller, {:response, response})

        # loops with new state
        loop(callback_module, new_state)
    end
  end

  def call(server_pid, request) do
    # issue requests to the server process
    send(server_pid, {request, self()})

    # receives from the mailbox an item matching the {:response, response} format
    receive do
      {:response, response} ->
        # returns the response
        response
    end
  end
end

defmodule KeyValueStore do
  # implement the init state function
  def init do
    %{}
  end

  # handle the multiple type of message processing
  def handle_call({:put, key, value}, state) do
    {:ok, Map.put(state, key, value)}
  end

  def handle_call({:get, key}, state) do
    {Map.get(state, key), state}
  end
end
