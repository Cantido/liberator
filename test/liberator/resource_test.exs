# SPDX-FileCopyrightText: 2024 Rosa Richter
#
# SPDX-License-Identifier: AGPL-3.0-or-later

defmodule Liberator.ResourceTest do
  use ExUnit.Case, async: true
  use Plug.Test
  doctest Liberator.Resource

  defmodule TracingResource do
    use Liberator.Resource
  end

  test "traces decisions" do
    conn = conn(:get, "/", "hello!") |> put_req_header("content-type", "text/plain")

    conn = TracingResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "OK"

    trace = conn.private.liberator_trace

    assert List.first(trace)[:step] == :start
    assert List.last(trace)[:step] == :stop
  end

  defmodule TracingToHeaderResource do
    use Liberator.Resource, trace: :headers
  end

  test "traces decisions to header when trace: :headers" do
    conn = conn(:get, "/")

    conn = TracingToHeaderResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "OK"

    trace = get_resp_header(conn, "x-liberator-trace")
    assert String.starts_with?(Enum.at(trace, 0), "initialize: nil (took ")
  end

  defmodule TracingToLogResource do
    use Liberator.Resource, trace: :log

    # The docs for the RequestId plug specify that the correct way to access it is via Logger metadata
    @impl true
    def initialize(_), do: Logger.metadata(request_id: "my-very-specific-request-id")
  end

  test "logs the trace to the logger when trace: :log" do
    parent = self()

    defmodule LogMessageToParentProcess do
      def init(parent), do: {:ok, parent}

      def handle_event({_level, _gl, {Logger, msg, _, _}}, parent) do
        Process.send(parent, msg, [])
        {:ok, parent}
      end

      def handle_event(:flush, parent) do
        {:ok, parent}
      end

      def handle_call({:configure, options}, _state) do
        parent = Keyword.fetch!(options, :parent)
        {:ok, :ok, parent}
      end
    end

    Logger.add_backend(LogMessageToParentProcess)
    Logger.configure_backend(LogMessageToParentProcess, parent: parent)

    on_exit(fn ->
      Logger.remove_backend(LogMessageToParentProcess)
    end)

    conn = conn(:get, "/")

    conn = TracingToLogResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "OK"

    assert_receive <<"Liberator trace for request \"my-very-specific-request-id\" to /:">> <> _
  end

  defmodule SetsLiberatorModuleResource do
    use Liberator.Resource
  end

  test "sets conn.private.liberator_module" do
    conn = conn(:get, "/")

    conn = SetsLiberatorModuleResource.call(conn, [])

    assert conn.private.liberator_module == Liberator.ResourceTest.SetsLiberatorModuleResource
  end

  defmodule GetOkResource do
    use Liberator.Resource
  end

  test "gets index" do
    conn = conn(:get, "/")

    conn = GetOkResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "OK"
  end

  defmodule ReturnsMapResource do
    use Liberator.Resource

    @impl true
    def service_available?(_conn) do
      %{test_value: "Hello!"}
    end
  end

  test "decision functions can return a map and have it merged into the conn.assigns" do
    conn = conn(:get, "/")

    conn = ReturnsMapResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "OK"
    assert conn.assigns[:test_value] == "Hello!"
  end

  defmodule InitializedMapResource do
    use Liberator.Resource

    @impl true
    def initialize(_conn) do
      %{test_value: "Hello!"}
    end
  end

  test "action functions can return a map and have it merged into the conn.assigns" do
    conn = conn(:get, "/")

    conn = InitializedMapResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "OK"
    assert conn.assigns[:test_value] == "Hello!"
  end

  defmodule InitializedConnResource do
    use Liberator.Resource

    @impl true
    def initialize(conn) do
      assign(conn, :test_value, "Hello!")
    end
  end

  test "action functions can return the conn" do
    conn = conn(:get, "/")

    conn = InitializedConnResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "OK"
    assert conn.assigns[:test_value] == "Hello!"
  end

  defmodule ReturnsConnResource do
    use Liberator.Resource

    @impl true
    def service_available?(conn) do
      assign(conn, :test_value, "Hello!")
    end
  end

  test "decision functions can return the conn" do
    conn = conn(:get, "/")

    conn = ReturnsConnResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "OK"
    assert conn.assigns[:test_value] == "Hello!"
  end

  defmodule RaisingPostResource do
    use Liberator.Resource

    @impl true
    def allowed_methods(_conn) do
      ["POST"]
    end

    @impl true
    def post!(_conn) do
      raise "That resource already exists"
    end

    @impl true
    def handle_error(conn, error, failed_step) do
      assert failed_step == :post!

      conn
      |> send_resp(400, error.message)
    end
  end

  test "handle_error will be called if an action function raises" do
    conn = conn(:post, "/")

    conn = RaisingPostResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 400
    assert conn.resp_body == "That resource already exists"
  end

  defmodule ErrorTuplePostResource do
    use Liberator.Resource

    @impl true
    def allowed_methods(_conn) do
      ["POST"]
    end

    @impl true
    def post!(_conn) do
      {:error, "That resource already exists"}
    end

    @impl true
    def handle_error(conn, {:error, message}, failed_step) do
      assert failed_step == :post!
      assert message == "That resource already exists"

      conn
      |> send_resp(400, message)
    end
  end

  test "handle_error will be called if an an action returns an error tuple" do
    conn = conn(:post, "/")

    conn = ErrorTuplePostResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 400
    assert conn.resp_body == "That resource already exists"
  end

  defmodule ErrorTupleHandlerResource do
    use Liberator.Resource

    @impl true
    def handle_ok(_conn) do
      {:error, "I couldn't say OK :("}
    end

    @impl true
    def handle_error(conn, {:error, message}, failed_step) do
      assert failed_step == :handle_ok
      assert message == "I couldn't say OK :("

      conn
      |> send_resp(500, message)
    end
  end

  test "handle_error will be called if an a handler returns an error tuple" do
    conn = conn(:get, "/")

    conn = ErrorTupleHandlerResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 500
    assert conn.resp_body == "I couldn't say OK :("
  end

  defmodule GetAMapResource do
    use Liberator.Resource

    @impl true
    def handle_ok(_), do: %{a: 1, b: 2}
  end

  test "stringifies return values from the handler" do
    conn = conn(:get, "/")

    conn = GetAMapResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body =~ "a: 1"
    assert conn.resp_body =~ "b: 2"
  end

  defmodule OkTupleHandlerResource do
    use Liberator.Resource

    @impl true
    def handle_ok(_), do: {:ok, "no ok tuple here!"}
  end

  test "stringifies ok tuple values from the handler" do
    conn = conn(:get, "/")

    conn = OkTupleHandlerResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "no ok tuple here!"
  end

  defmodule WillBreakLiberatorResource do
    use Liberator.Resource,
      decision_tree_overrides: %{
        service_available?: {:i_dont_exist, :handle_service_unavailable}
      }
  end

  test "exception test" do
    conn = conn(:get, "/")

    message = """
      Liberator encountered an unknown step called :i_dont_exist

      In module: Liberator.ResourceTest.WillBreakLiberatorResource

      A couple things could be wrong:

      - If you have overridden part of the decision tree with :decision_tree_overrides,
        make sure that the atoms in the {true, false} tuple values have their own entries in the map.

      - If you have overridden part of the handler tree with :handler_status_overrides,
        or the action followups with :action_followup_overrides,
        make sure that the handler the atoms you passed in are spelled correctly,
        and match what the decision tree is calling.
    """

    assert_raise Liberator.UnknownStepException, message, fn ->
      WillBreakLiberatorResource.call(conn, [])
    end
  end

  defmodule DevilsOkayResource do
    use Liberator.Resource,
      handler_status_overrides: %{
        handle_ok: 666
      }
  end

  test "can override the handlers tree" do
    conn = conn(:get, "/")

    conn = DevilsOkayResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 666
    assert conn.resp_body == "OK"
  end

  defmodule PostGoesToOk do
    use Liberator.Resource,
      action_followup_overrides: %{
        post!: :handle_ok
      }

    @impl true
    def allowed_methods(_conn), do: ["POST"]
  end

  test "can override the action followups" do
    conn = conn(:post, "/")

    conn = PostGoesToOk.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "OK"
  end

  defmodule JsonResource do
    use Liberator.Resource
    @impl true
    def available_media_types(_), do: ["application/json"]
  end

  test "gets index as JSON" do
    conn = conn(:get, "/") |> put_req_header("accept", "application/json")
    conn = JsonResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 200
    assert Jason.decode!(conn.resp_body) == "OK"
  end

  defmodule LastModifiedResource do
    use Liberator.Resource
    @impl true
    def last_modified(_conn), do: ~U[2015-10-21 07:28:00Z]
  end

  test "serves the last-modified header" do
    conn = conn(:get, "/")
    conn = LastModifiedResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "OK"
    assert Enum.at(get_resp_header(conn, "last-modified"), 0) == "Wed, 21 Oct 2015 07:28:00 GMT"
  end

  defmodule EtagResource do
    use Liberator.Resource
    @impl true
    def etag(_), do: ["very-strong-etag"]
  end

  test "sets etag if etag is provided" do
    conn = conn(:get, "/")
    conn = EtagResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "OK"
    assert Enum.at(get_resp_header(conn, "etag"), 0) == ~s("very-strong-etag")
  end

  defmodule NoEtagResource do
    use Liberator.Resource
  end

  test "does not set etag if etag callback returns nil" do
    conn = conn(:get, "/")
    conn = NoEtagResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "OK"
    assert get_resp_header(conn, "etag") == []
  end

  defmodule LocationResource do
    use Liberator.Resource
    @impl true
    def allowed_methods(_), do: ["POST"]
    def post!(_), do: %{location: "somewhere safe and sound"}
  end

  test "sets location if location is provided in assigns" do
    conn = conn(:post, "/")
    conn = LocationResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 201
    assert conn.resp_body == "Created"
    assert Enum.at(get_resp_header(conn, "location"), 0) == "somewhere safe and sound"
  end

  defmodule MethodNotAllowedAllowHeaderResource do
    use Liberator.Resource

    @impl true
    def allowed_methods(_conn), do: ["OPTIONS", "HEAD", "GET"]

    @impl true
    def method_allowed?(_conn), do: false
  end

  test "sets the allow header when returning a 405" do
    conn = conn(:get, "/")
    conn = MethodNotAllowedAllowHeaderResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 405
    assert get_resp_header(conn, "allow") |> Enum.at(0) == "OPTIONS, HEAD, GET"
  end

  defmodule RaisingWellFormedResource do
    use Liberator.Resource
    @impl true
    def well_formed?(_conn), do: raise("shouldn't have called me!")
  end

  test "does not call well_formed? when body is nil" do
    conn = conn(:get, "/")
    conn = RaisingWellFormedResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "OK"
  end

  defmodule OptionsAllowResource do
    use Liberator.Resource
    @impl true
    def allowed_methods(_conn), do: ["OPTIONS", "HEAD", "GET"]
    def method_options?(_conn), do: true
  end

  test "response headers contain contents from allowed_methods for an options request" do
    conn = conn(:options, "/")
    conn = OptionsAllowResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 200
    assert get_resp_header(conn, "allow") |> Enum.at(0) == "OPTIONS, HEAD, GET"
  end

  defmodule RateLimitedUntilOctoberResource do
    use Liberator.Resource
    @impl true
    def too_many_requests?(_conn), do: %{retry_after: ~U[2020-10-12 17:06:00Z]}
  end

  test "sets retry-after header of resource if too_many_requests returns %{retry_after: %DateTime{}}" do
    conn = conn(:get, "/")
    conn = RateLimitedUntilOctoberResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 429
    assert conn.resp_body == "Too Many Requests"
    assert "Mon, 12 Oct 2020 17:06:00 GMT" in get_resp_header(conn, "retry-after")
  end

  defmodule RateLimitedForAMinuteResource do
    use Liberator.Resource
    @impl true
    def too_many_requests?(_conn), do: %{retry_after: 60}
  end

  test "sets retry-after header of resource if too_many_requests returns %{retry_after: 60}" do
    conn = conn(:get, "/")
    conn = RateLimitedForAMinuteResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 429
    assert conn.resp_body == "Too Many Requests"
    assert "60" in get_resp_header(conn, "retry-after")
  end

  defmodule RateLimitedByLebowskiResource do
    use Liberator.Resource
    @impl true
    def too_many_requests?(_conn), do: %{retry_after: "whenever, man"}
  end

  test "sets retry-after header of resource if too_many_requests returns %{retry_after: \"whenever, man\"}" do
    conn = conn(:get, "/")
    conn = RateLimitedByLebowskiResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 429
    assert conn.resp_body == "Too Many Requests"
    assert "whenever, man" in get_resp_header(conn, "retry-after")
  end

  defmodule RateLimitedByUnicodeConsortiumResource do
    use Liberator.Resource
    @impl true
    def too_many_requests?(_conn), do: %{retry_after: <<0xFFFF::16>>}
  end

  test "raises if the value of :retry_after is not a valid string" do
    expected_message =
      "Value for :retry_after was not a valid DateTime, integer, or String, but was <<255, 255>>. " <>
        "Make sure the too_many_requests?/1 function of " <>
        "Liberator.ResourceTest.RateLimitedByUnicodeConsortiumResource is setting " <>
        "that key to one of those types. Remember that you can also just return true or false."

    conn = conn(:get, "/")

    assert_raise Liberator.InvalidRetryAfterValueException, expected_message, fn ->
      RateLimitedByUnicodeConsortiumResource.call(conn, [])
    end
  end
end
