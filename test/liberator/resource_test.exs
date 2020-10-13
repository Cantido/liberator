defmodule Liberator.ResourceTest do
  use ExUnit.Case, async: true
  use Plug.Test
  doctest Liberator.Resource

  test "traces decisions" do
    defmodule TracingResource do
      use Liberator.Resource
    end

    conn = conn(:get, "/")

    conn = TracingResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "OK"

    assert conn.private.liberator_trace == [
      initialize: nil,
      service_available?: true,
      known_method?: true,
      uri_too_long?: false,
      method_allowed?: true,
      malformed?: false,
      authorized?: true,
      allowed?: true,
      too_many_requests?: false,
      payment_required?: false,
      valid_content_header?: true,
      known_content_type?: true,
      valid_entity_length?: true,
      is_options?: false,
      accept_exists?: false,
      accept_language_exists?: false,
      accept_charset_exists?: false,
      accept_encoding_exists?: false,
      processable?: true,
      unavailable_for_legal_reasons?: false,
      exists?: true,
      if_match_exists?: false,
      if_unmodified_since_exists?: false,
      if_none_match_exists?: false,
      if_modified_since_exists?: false,
      method_delete?: false,
      method_patch?: false,
      post_to_existing?: false,
      put_to_existing?: false,
      multiple_representations?: false,
      handle_ok: nil
    ]
  end

  test "gets index" do
    defmodule GetOkResource do
      use Liberator.Resource
    end

    conn = conn(:get, "/")

    conn = GetOkResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "OK"
  end

  test "can override the decision tree" do
    defmodule ShortcutResource do
      use Liberator.Resource,
        decision_tree_overrides: %{
          service_available?: {:handle_ok, :handle_service_unavailable}
        }
    end

    conn = conn(:get, "/")

    conn = ShortcutResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "OK"

    assert conn.private.liberator_trace == [
      initialize: nil,
      service_available?: true,
      handle_ok: nil
    ]
  end

  test "exception test" do
    defmodule WillBreakLiberatorResource do
      use Liberator.Resource,
        decision_tree_overrides: %{
          service_available?: {:i_dont_exist, :handle_service_unavailable}
        }
    end

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

    assert_raise RuntimeError, message, fn ->
      WillBreakLiberatorResource.call(conn, [])
    end
  end

  test "can override the handlers tree" do
    defmodule DevilsOkayResource do
      use Liberator.Resource,
        handler_status_overrides: %{
          handle_ok: 666
        }
    end

    conn = conn(:get, "/")

    conn = DevilsOkayResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 666
    assert conn.resp_body == "OK"
  end

  test "can override the action followups" do
    defmodule PostGoesToOk do
      use Liberator.Resource,
        action_followup_overrides: %{
          post!: :handle_ok
        }
      @impl true
      def allowed_methods(_conn), do: ["POST"]
    end

    conn = conn(:post, "/")

    conn = PostGoesToOk.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "OK"
  end

  test "gets index as JSON" do
    defmodule JsonResource do
      use Liberator.Resource
      @impl true
      def available_media_types(_), do: ["application/json"]
    end

    conn = conn(:get, "/") |> put_req_header("accept", "application/json")
    conn = JsonResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 200
    assert Jason.decode!(conn.resp_body) == "OK"
  end

  test "returns 503 when service_available? returns false" do
    defmodule UnavailableResource do
      use Liberator.Resource
      @impl true
      def service_available?(_conn), do: false
    end

    conn = conn(:get, "/")
    conn = UnavailableResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 503
    assert conn.resp_body == "Service Unavailable"
  end

  test "returns 501 when known_method? returns false" do
    defmodule UnknownMethodResource do
      use Liberator.Resource
      @impl true
      def known_method?(_conn), do: false
    end

    conn = conn(:get, "/")
    conn = UnknownMethodResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 501
    assert conn.resp_body == "Unknown Method"
  end

  test "returns 414 when uri_too_long? returns true" do
    defmodule UriTooLongResource do
      use Liberator.Resource
      @impl true
      def uri_too_long?(_conn), do: true
    end

    conn = conn(:get, "/")
    conn = UriTooLongResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 414
    assert conn.resp_body == "URI Too Long"
  end

  test "returns 405 when method_allowed? returns false" do
    defmodule MethodNotAllowedResource do
      use Liberator.Resource
      @impl true
      def method_allowed?(_conn), do: false
    end

    conn = conn(:get, "/")
    conn = MethodNotAllowedResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 405
    assert conn.resp_body == "Method Not Allowed"
  end

  test "returns 400 when malformed? returns true" do
    defmodule MalformedResource do
      use Liberator.Resource
      @impl true
      def malformed?(_conn), do: true
    end

    conn = conn(:get, "/")
    conn = MalformedResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 400
    assert conn.resp_body == "Malformed"
  end

  test "returns 401 when authorized? returns false" do
    defmodule UnauthorizedResource do
      use Liberator.Resource
      @impl true
      def authorized?(_conn), do: false
    end

    conn = conn(:get, "/")
    conn = UnauthorizedResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 401
    assert conn.resp_body == "Unauthorized"
  end

  test "returns 403 when allowed? returns false" do
    defmodule ForbiddenResource do
      use Liberator.Resource
      @impl true
      def allowed?(_conn), do: false
    end

    conn = conn(:get, "/")
    conn = ForbiddenResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 403
    assert conn.resp_body == "Forbidden"
  end

  test "returns 501 when valid_content_header? returns false" do
    defmodule NotImplementedResource do
      use Liberator.Resource
      @impl true
      def valid_content_header?(_conn), do: false
    end

    conn = conn(:get, "/")
    conn = NotImplementedResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 501
    assert conn.resp_body == "Not Implemented"
  end

  test "returns 415 when known_content_type? returns false" do
    defmodule UnsupportedMediaResource do
      use Liberator.Resource
      @impl true
      def known_content_type?(_conn), do: false
    end

    conn = conn(:get, "/")
    conn = UnsupportedMediaResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 415
    assert conn.resp_body == "Unsupported Media Type"
  end

  test "returns 413 when valid_entity_length? returns false" do
    defmodule EntityTooLongResource do
      use Liberator.Resource
      @impl true
      def valid_entity_length?(_conn), do: false
    end

    conn = conn(:get, "/")
    conn = EntityTooLongResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 413
    assert conn.resp_body == "Request Entity Too Large"
  end

  test "returns 200-options for an options request" do
    defmodule OptionsResource do
      use Liberator.Resource
      @impl true
      def allowed_methods(_conn), do: ["OPTIONS"]
      def is_options?(_conn), do: true
    end

    conn = conn(:options, "/")
    conn = OptionsResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "Options"
  end

  test "returns 402 when payment_required? returns true" do
    defmodule PayGatedResource do
      use Liberator.Resource
      @impl true
      def payment_required?(_conn), do: true
    end

    conn = conn(:get, "/")
    conn = PayGatedResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 402
    assert conn.resp_body == "Payment Required"
  end

  test "returns 406 when accept_exists? returns true but media_type_available? returns false" do
    defmodule NotAcceptableResource do
      use Liberator.Resource
      @impl true
      def accept_exists?(_conn), do: true
      def media_type_available?(_conn), do: false
    end

    conn = conn(:get, "/")
    conn = NotAcceptableResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 406
    assert conn.resp_body == "Not Acceptable"
  end

  test "returns 406 when accept_language_exists? returns true but language_available? returns false" do
    defmodule LanguageUnavailableResource do
      use Liberator.Resource
      @impl true
      def accept_language_exists?(_conn), do: true
      def language_available?(_conn), do: false
    end

    conn = conn(:get, "/")
    conn = LanguageUnavailableResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 406
    assert conn.resp_body == "Not Acceptable"
  end

  test "returns 406 when accept_charset_exists? returns true but charset_available? returns false" do
    defmodule CharsetUnavailableResource do
      use Liberator.Resource
      @impl true
      def accept_charset_exists?(_conn), do: true
      def charset_available?(_conn), do: false
    end

    conn = conn(:get, "/")
    conn = CharsetUnavailableResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 406
    assert conn.resp_body == "Not Acceptable"
  end

  test "returns 406 when accept_encoding_exists? returns true but encoding_available? returns false" do
    defmodule EncodingUnavailableResource do
      use Liberator.Resource
      @impl true
      def accept_encoding_exists?(_conn), do: true
      def encoding_available?(_conn), do: false
    end

    conn = conn(:get, "/")
    conn = EncodingUnavailableResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 406
    assert conn.resp_body == "Not Acceptable"
  end

  test "returns 422 when processable? returns false" do
    defmodule UnprocessableResource do
      use Liberator.Resource
      @impl true
      def processable?(_conn), do: false
    end

    conn = conn(:get, "/")
    conn = UnprocessableResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 422
    assert conn.resp_body == "Unprocessable Entity"
  end

  test "returns 429 when too_many_requests? returns true" do
    defmodule RateLimitedResource do
      use Liberator.Resource
      @impl true
      def too_many_requests?(_conn), do: true
    end

    conn = conn(:get, "/")
    conn = RateLimitedResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 429
    assert conn.resp_body == "Too Many Requests"
  end

  test "sets retry-after header of resource if too_many_requests returns %{retry_after: %DateTime{}}" do
    defmodule RateLimitedUntilOctoberResource do
      use Liberator.Resource
      @impl true
      def too_many_requests?(_conn), do: %{retry_after: ~U[2020-10-12 17:06:00Z]}
    end

    conn = conn(:get, "/")
    conn = RateLimitedUntilOctoberResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 429
    assert conn.resp_body == "Too Many Requests"
    assert "Mon, 12 Oct 2020 17:06:00 GMT" in get_resp_header(conn, "retry-after")
  end

  test "sets retry-after header of resource if too_many_requests returns %{retry_after: 60}" do
    defmodule RateLimitedForAMinuteResource do
      use Liberator.Resource
      @impl true
      def too_many_requests?(_conn), do: %{retry_after: 60}
    end

    conn = conn(:get, "/")
    conn = RateLimitedForAMinuteResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 429
    assert conn.resp_body == "Too Many Requests"
    assert "60" in get_resp_header(conn, "retry-after")
  end

  test "sets retry-after header of resource if too_many_requests returns %{retry_after: \"whenever, man\"}" do
    defmodule RateLimitedByLebowskiResource do
      use Liberator.Resource
      @impl true
      def too_many_requests?(_conn), do: %{retry_after: "whenever, man"}
    end

    conn = conn(:get, "/")
    conn = RateLimitedByLebowskiResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 429
    assert conn.resp_body == "Too Many Requests"
    assert "whenever, man" in get_resp_header(conn, "retry-after")
  end

  test "raises if the value of :retry_after is not a valid string" do
    defmodule RateLimitedByUnicodeConsortiumResource do
      use Liberator.Resource
      @impl true
      def too_many_requests?(_conn), do: %{retry_after: <<0xFFFF::16>>}
    end

    expected_message =
      "Value for :retry_after was not a valid DateTime, integer, or String, but was <<255, 255>>. " <>
        "Make sure the too_many_requests?/1 function of " <>
        "Liberator.ResourceTest.RateLimitedByUnicodeConsortiumResource is setting " <>
        "that key to one of those types. Remember that you can also just return true or false."

    conn = conn(:get, "/")

    assert_raise RuntimeError, expected_message, fn ->
      RateLimitedByUnicodeConsortiumResource.call(conn, [])
    end
  end

  test "returns 451 when unavailable_for_legal_reasons? returns true" do
    defmodule UnavailableForLegalReasonsResource do
      use Liberator.Resource
      @impl true
      def unavailable_for_legal_reasons?(_conn), do: true
    end

    conn = conn(:get, "/")
    conn = UnavailableForLegalReasonsResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 451
    assert conn.resp_body == "Unavailable for Legal Reasons"
  end

  test "returns 404 if entity does not exist" do
    defmodule NotFoundResource do
      use Liberator.Resource
      @impl true
      def exists?(_conn), do: false
      def if_match_star_exists_for_missing?(_conn), do: false
      def method_put?(_conn), do: false
      def existed?(_conn), do: false
      def post_to_missing?(_conn), do: false
    end

    conn = conn(:get, "/")
    conn = NotFoundResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 404
    assert conn.resp_body == "Not Found"
  end

  test "returns 404 if entity does not exist and can't post to missing" do
    defmodule NotFoundNoPostResource do
      use Liberator.Resource
      @impl true
      def exists?(_conn), do: false
      def if_match_star_exists_for_missing?(_conn), do: false
      def method_put?(_conn), do: false
      def existed?(_conn), do: false
      def post_to_missing?(_conn), do: true
      def can_post_to_missing?(_conn), do: false
    end

    conn = conn(:get, "/")
    conn = NotFoundNoPostResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 404
    assert conn.resp_body == "Not Found"
  end

  test "returns 303 if entity does not exist and we can post to missing, and have want a post redirect" do
    defmodule PostedNotFoundRedirectResource do
      use Liberator.Resource
      @impl true
      def exists?(_conn), do: false
      def if_match_star_exists_for_missing?(_conn), do: false
      def method_put?(_conn), do: false
      def existed?(_conn), do: false
      def post_to_missing?(_conn), do: true
      def can_post_to_missing?(_conn), do: true
      def post_enacted?(_conn), do: true
      def post_redirect?(_conn), do: true
    end

    conn = conn(:get, "/")
    conn = PostedNotFoundRedirectResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 303
    assert conn.resp_body == "See Other"
  end

  test "returns 201 if entity does not exist and we can post to missing, and create a new resource" do
    defmodule PostedNotFoundNewResource do
      use Liberator.Resource
      @impl true
      def exists?(_conn), do: false
      def if_match_star_exists_for_missing?(_conn), do: false
      def method_put?(_conn), do: false
      def existed?(_conn), do: false
      def post_to_missing?(_conn), do: true
      def can_post_to_missing?(_conn), do: true
      def post_enacted?(_conn), do: true
      def post_redirect?(_conn), do: false
      def new?(_conn), do: true
    end

    conn = conn(:get, "/")
    conn = PostedNotFoundNewResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 201
    assert conn.resp_body == "Created"
  end

  test "returns 202 if entity does not exist and we can post to missing, and post is not immediately enacted" do
    defmodule PostedNotFoundAcceptedResource do
      use Liberator.Resource
      @impl true
      def exists?(_conn), do: false
      def if_match_star_exists_for_missing?(_conn), do: false
      def method_put?(_conn), do: false
      def existed?(_conn), do: false
      def post_to_missing?(_conn), do: true
      def can_post_to_missing?(_conn), do: true
      def post_enacted?(_conn), do: false
    end

    conn = conn(:get, "/")
    conn = PostedNotFoundAcceptedResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 202
    assert conn.resp_body == "Accepted"
  end

  test "returns 204 if entity does not exist and we can post to missing, the entity isn't new and we won't respond with entities" do
    defmodule PostedNotFoundNoContentResource do
      use Liberator.Resource
      @impl true
      def exists?(_conn), do: false
      def if_match_star_exists_for_missing?(_conn), do: false
      def method_put?(_conn), do: false
      def existed?(_conn), do: false
      def post_to_missing?(_conn), do: true
      def can_post_to_missing?(_conn), do: true
      def post_enacted?(_conn), do: true
      def post_redirect?(_conn), do: false
      def new?(_conn), do: false
      def respond_with_entity?(_conn), do: false
    end

    conn = conn(:get, "/")
    conn = PostedNotFoundNoContentResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 204
    assert conn.resp_body == "No Content"
  end

  test "returns 300 if entity does not exist and we can post to missing, the entity isn't new and we have multiple entity representations" do
    defmodule PostedNotFoundMultipleRepresentationsResource do
      use Liberator.Resource
      @impl true
      def exists?(_conn), do: false
      def if_match_star_exists_for_missing?(_conn), do: false
      def method_put?(_conn), do: false
      def existed?(_conn), do: false
      def post_to_missing?(_conn), do: true
      def can_post_to_missing?(_conn), do: true
      def post_enacted?(_conn), do: true
      def post_redirect?(_conn), do: false
      def new?(_conn), do: false
      def respond_with_entity?(_conn), do: true
      def multiple_representations?(_conn), do: true
    end

    conn = conn(:get, "/")
    conn = PostedNotFoundMultipleRepresentationsResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 300
    assert conn.resp_body == "Multiple Representations"
  end

  test "returns 200 if entity does not exist and we can post to missing, the entity isn't new" do
    defmodule PostedNotFoundSingleRepresentationResource do
      use Liberator.Resource
      @impl true
      def exists?(_conn), do: false
      def if_match_star_exists_for_missing?(_conn), do: false
      def method_put?(_conn), do: false
      def existed?(_conn), do: false
      def post_to_missing?(_conn), do: true
      def can_post_to_missing?(_conn), do: true
      def post_enacted?(_conn), do: true
      def post_redirect?(_conn), do: false
      def new?(_conn), do: false
      def respond_with_entity?(_conn), do: true
      def multiple_representations?(_conn), do: false
    end

    conn = conn(:get, "/")
    conn = PostedNotFoundSingleRepresentationResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "OK"
  end

  test "returns 301 for permanently moved resource" do
    defmodule MovedPermanentlyResource do
      use Liberator.Resource
      @impl true
      def exists?(_conn), do: false
      def if_match_star_exists_for_missing?(_conn), do: false
      def method_put?(_conn), do: false
      def existed?(_conn), do: true
      def moved_permanently?(_conn), do: true
    end

    conn = conn(:get, "/")
    conn = MovedPermanentlyResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 301
    assert conn.resp_body == "Moved Permanently"
  end

  test "returns 307" do
    defmodule MovedTemporarilyResource do
      use Liberator.Resource
      @impl true
      def exists?(_conn), do: false
      def if_match_star_exists_for_missing?(_conn), do: false
      def method_put?(_conn), do: false
      def existed?(_conn), do: true
      def moved_permanently?(_conn), do: false
      def moved_temporarily?(_conn), do: true
    end

    conn = conn(:get, "/")
    conn = MovedTemporarilyResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 307
    assert conn.resp_body == "Moved Temporarily"
  end

  test "returns 410 if the resource is gone" do
    defmodule GoneResource do
      use Liberator.Resource
      @impl true
      def exists?(_conn), do: false
      def if_match_star_exists_for_missing?(_conn), do: false
      def method_put?(_conn), do: false
      def existed?(_conn), do: true
      def moved_permanently?(_conn), do: false
      def moved_temporarily?(_conn), do: false
      def post_to_gone?(_conn), do: false
    end

    conn = conn(:get, "/")
    conn = GoneResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 410
    assert conn.resp_body == "Gone"
  end

  test "returns 410 when can't post to gone" do
    defmodule CantPostToGoneResource do
      use Liberator.Resource
      @impl true
      def exists?(_conn), do: false
      def if_match_star_exists_for_missing?(_conn), do: false
      def method_put?(_conn), do: false
      def existed?(_conn), do: true
      def moved_permanently?(_conn), do: false
      def moved_temporarily?(_conn), do: false
      def post_to_gone?(_conn), do: true
      def can_post_to_gone?(_conn), do: false
    end

    conn = conn(:get, "/")
    conn = CantPostToGoneResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 410
    assert conn.resp_body == "Gone"
  end

  test "returns 201 when resource is gone but we can post to it" do
    defmodule NewPostToGoneResource do
      use Liberator.Resource
      @impl true
      def allowed_methods(_conn), do: ["POST"]
      def exists?(_conn), do: false
      def if_match_star_exists_for_missing?(_conn), do: false
      def method_put?(_conn), do: false
      def existed?(_conn), do: true
      def moved_permanently?(_conn), do: false
      def moved_temporarily?(_conn), do: false
      def post_to_gone?(_conn), do: true
      def can_post_to_gone?(_conn), do: true
      def post_enacted?(_conn), do: true
      def post_redirect?(_conn), do: false
      def new?(_conn), do: true
    end

    conn = conn(:post, "/")
    conn = NewPostToGoneResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 201
    assert conn.resp_body == "Created"
  end

  test "returns 301 when put to a different url but entity doesn't exist" do
    defmodule PutToDifferentUrlResource do
      use Liberator.Resource
      @impl true
      def allowed_methods(_conn), do: ["PUT"]
      def exists?(_conn), do: false
      def if_match_star_exists_for_missing?(_conn), do: false
      def method_put?(_conn), do: true
      def put_to_different_url?(_conn), do: true
    end

    conn = conn(:put, "/")
    conn = PutToDifferentUrlResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 301
    assert conn.resp_body == "Moved Permanently"
  end

  test "returns 501 when put to a different url but entity doesn't exist and can't put to missing" do
    defmodule CantPutToMissingResource do
      use Liberator.Resource
      @impl true
      def allowed_methods(_conn), do: ["PUT"]
      def exists?(_conn), do: false
      def if_match_star_exists_for_missing?(_conn), do: false
      def method_put?(_conn), do: true
      def put_to_different_url?(_conn), do: false
      def can_put_to_missing?(_conn), do: false
    end

    conn = conn(:put, "/")
    conn = CantPutToMissingResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 501
    assert conn.resp_body == "Not Implemented"
  end

  test "returns 409 when put to a different url but entity doesn't exist, and we can put to missing, but there's a conflict" do
    defmodule CanPutToMissingConflictResource do
      use Liberator.Resource
      @impl true
      def allowed_methods(_conn), do: ["PUT"]
      def exists?(_conn), do: false
      def if_match_star_exists_for_missing?(_conn), do: false
      def method_put?(_conn), do: true
      def put_to_different_url?(_conn), do: false
      def can_put_to_missing?(_conn), do: true
      def conflict?(_conn), do: true
    end

    conn = conn(:put, "/")
    conn = CanPutToMissingConflictResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 409
    assert conn.resp_body == "Conflict"
  end

  test "returns 412 when entity doesn't exist but if_match_star_exists_for_missing is true" do
    defmodule MissingMatchStarResource do
      use Liberator.Resource
      @impl true
      def exists?(_conn), do: false
      def if_match_star_exists_for_missing?(_conn), do: true
    end

    conn = conn(:get, "/")
    conn = MissingMatchStarResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 412
    assert conn.resp_body == "Precondition Failed"
  end

  test "returns 412 if If-Match <etag> doesn't match an etag" do
    defmodule MismatchedIfMatchEtagResource do
      use Liberator.Resource
      @impl true
      def if_match_exists?(_conn), do: true
      def if_match_star?(_conn), do: false
      def etag_matches_for_if_match?(_conn), do: false
    end

    conn = conn(:get, "/")
    conn = MismatchedIfMatchEtagResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 412
    assert conn.resp_body == "Precondition Failed"
  end

  test "returns 412 if If-Unmodified-Since <date> and entity has not been modified since" do
    defmodule UnmodifiedSinceResource do
      use Liberator.Resource
      @impl true
      def if_unmodified_since_exists?(_conn), do: true
      def if_unmodified_since_valid_date?(_conn), do: true
      def unmodified_since?(_conn), do: true
    end

    conn = conn(:get, "/")
    conn = UnmodifiedSinceResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 412
    assert conn.resp_body == "Precondition Failed"
  end

  test "returns 412 if If-None-Match <etag> etag does match" do
    defmodule IfNoneMatchButDoesMatchResource do
      use Liberator.Resource
      @impl true
      def if_none_match_exists?(_conn), do: true
      def if_none_match_star?(_conn), do: false
      def etag_matches_for_if_none?(_conn), do: true
      def if_none_match?(_conn), do: false
    end

    conn = conn(:get, "/")
    conn = IfNoneMatchButDoesMatchResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 412
    assert conn.resp_body == "Precondition Failed"
  end

  test "returns 412 if If-None-Match * etag does match" do
    defmodule IfNoneMatchStarButMatchesResource do
      use Liberator.Resource
      @impl true
      def if_none_match_exists?(_conn), do: true
      def if_none_match_star?(_conn), do: true
      def if_none_match?(_conn), do: false
    end

    conn = conn(:get, "/")
    conn = IfNoneMatchStarButMatchesResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 412
    assert conn.resp_body == "Precondition Failed"
  end

  test "returns 304 if If-None-Match <etag> etag does't match" do
    defmodule NotModifiedIfNoneMatchResource do
      use Liberator.Resource
      @impl true
      def if_none_match_exists?(_conn), do: true
      def if_none_match_star?(_conn), do: false
      def etag_matches_for_if_none?(_conn), do: true
      def if_none_match?(_conn), do: true
    end

    conn = conn(:get, "/")
    conn = NotModifiedIfNoneMatchResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 304
    assert conn.resp_body == "Not Modified"
  end

  test "returns 304 if If-Modified-Since <date> and resource has not been modified" do
    defmodule ModifiedSinceResource do
      use Liberator.Resource
      @impl true
      def if_modified_since_exists?(_conn), do: true
      def if_modified_since_valid_date?(_conn), do: true
      def modified_since?(_conn), do: false
    end

    conn = conn(:get, "/")
    conn = ModifiedSinceResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 304
    assert conn.resp_body == "Not Modified"
  end

  test "returns 200 if method is delete" do
    defmodule SuccessfulDeleteResource do
      use Liberator.Resource
      @impl true
      def allowed_methods(_conn), do: ["DELETE"]
      def method_delete?(_conn), do: true
      def delete!(_conn), do: nil
    end

    conn = conn(:delete, "/")
    conn = SuccessfulDeleteResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "OK"
  end

  test "returns 202 if method is delete but delete is not immediately enacted" do
    defmodule DelayedDeleteResource do
      use Liberator.Resource
      @impl true
      def allowed_methods(_conn), do: ["DELETE"]
      def method_delete?(_conn), do: true
      def delete!(_conn), do: nil
      def delete_enacted?(_conn), do: false
    end

    conn = conn(:delete, "/")
    conn = DelayedDeleteResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 202
    assert conn.resp_body == "Accepted"
  end

  test "returns 204 if method is delete and no content is returned" do
    defmodule SuccessfulDeleteNoEntityResource do
      use Liberator.Resource
      @impl true
      def allowed_methods(_conn), do: ["DELETE"]
      def method_delete?(_conn), do: true
      def delete!(_conn), do: nil
      def respond_with_entity?(_conn), do: false
    end

    conn = conn(:delete, "/")
    conn = SuccessfulDeleteNoEntityResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 204
    assert conn.resp_body == "No Content"
  end

  test "returns 200 if method is patch" do
    defmodule SuccessfulPatchResource do
      use Liberator.Resource
      @impl true
      def allowed_methods(_conn), do: ["PATCH"]
      def method_delete?(_conn), do: false
      def method_patch?(_conn), do: true
      def patch!(_conn), do: nil
      def patch_enacted?(_conn), do: true
      def respond_with_entity?(_conn), do: true
      def multiple_representations?(_conn), do: false
    end

    conn = conn(:patch, "/")
    conn = SuccessfulPatchResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "OK"
  end

  test "returns 202 if method is patch and patch is not immediately enacted" do
    defmodule AcceptedPatchResource do
      use Liberator.Resource
      @impl true
      def allowed_methods(_conn), do: ["PATCH"]
      def method_delete?(_conn), do: false
      def method_patch?(_conn), do: true
      def patch!(_conn), do: nil
      def patch_enacted?(_conn), do: false
    end

    conn = conn(:patch, "/")
    conn = AcceptedPatchResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 202
    assert conn.resp_body == "Accepted"
  end

  test "returns 204 if method is patch and no content is returned" do
    defmodule AcceptedPatchNoContentResource do
      use Liberator.Resource
      @impl true
      def allowed_methods(_conn), do: ["PATCH"]
      def method_delete?(_conn), do: false
      def method_patch?(_conn), do: true
      def patch!(_conn), do: nil
      def patch_enacted?(_conn), do: true
      def respond_with_entity?(_conn), do: false
    end

    conn = conn(:patch, "/")
    conn = AcceptedPatchNoContentResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 204
    assert conn.resp_body == "No Content"
  end

  test "returns 409 if post-to-existing has a conflict" do
    defmodule ConflictedPostToExistingResource do
      use Liberator.Resource
      @impl true
      def allowed_methods(_conn), do: ["POST"]
      def method_delete?(_conn), do: false
      def method_patch?(_conn), do: false
      def post_to_existing?(_conn), do: true
      def conflict?(_conn), do: true
    end

    conn = conn(:post, "/")
    conn = ConflictedPostToExistingResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 409
    assert conn.resp_body == "Conflict"
  end

  test "returns 409 if put-to-existing has a conflict" do
    defmodule ConflictedPutToExistingResource do
      use Liberator.Resource
      @impl true
      def allowed_methods(_conn), do: ["PUT"]
      def method_delete?(_conn), do: false
      def method_patch?(_conn), do: false
      def post_to_existing?(_conn), do: false
      def put_to_existing?(_conn), do: true
      def conflict?(_conn), do: true
    end

    conn = conn(:put, "/")
    conn = ConflictedPutToExistingResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 409
    assert conn.resp_body == "Conflict"
  end

  test "returns 303 if post with post-redirect enabled" do
    defmodule PostRedirectResource do
      use Liberator.Resource
      @impl true
      def allowed_methods(_conn), do: ["POST"]
      def exists?(_conn), do: true
      def if_match_exists?(_conn), do: false
      def if_unmodified_since_exists?(_conn), do: false
      def if_none_match_exists?(_conn), do: false
      def post_to_existing?(_conn), do: true
      def conflict?(_conn), do: false
      def method_post?(_conn), do: true
      def post_enacted?(_conn), do: true
      def post_redirect?(_conn), do: true
    end

    conn = conn(:post, "/")
    conn = PostRedirectResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 303
    assert conn.resp_body == "See Other"
  end

  test "returns 201 if post when resource is created" do
    defmodule PostCreatedNewResource do
      use Liberator.Resource
      @impl true
      def allowed_methods(_conn), do: ["POST"]
      def exists?(_conn), do: true
      def if_match_exists?(_conn), do: false
      def if_unmodified_since_exists?(_conn), do: false
      def if_none_match_exists?(_conn), do: false
      def post_to_existing?(_conn), do: true
      def conflict?(_conn), do: false
      def method_post?(_conn), do: true
      def post_enacted?(_conn), do: true
      def post_redirect?(_conn), do: false
      def new?(_conn), do: true
    end

    conn = conn(:post, "/")
    conn = PostCreatedNewResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 201
    assert conn.resp_body == "Created"
  end

  test "returns 204 if post when resource is not new and we want no entity response" do
    defmodule PostNewNoEntityResponseResource do
      use Liberator.Resource
      @impl true
      def allowed_methods(_conn), do: ["POST"]
      def exists?(_conn), do: true
      def if_match_exists?(_conn), do: false
      def if_unmodified_since_exists?(_conn), do: false
      def if_none_match_exists?(_conn), do: false
      def post_to_existing?(_conn), do: true
      def conflict?(_conn), do: false
      def method_post?(_conn), do: true
      def post_enacted?(_conn), do: true
      def post_redirect?(_conn), do: false
      def new?(_conn), do: false
      def respond_with_entity?(_conn), do: false
    end

    conn = conn(:post, "/")
    conn = PostNewNoEntityResponseResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 204
    assert conn.resp_body == "No Content"
  end

  test "returns 200 if post when resource is not new and we want an entity response with one representation" do
    defmodule PostNewSingleEntityResponseResource do
      use Liberator.Resource
      @impl true
      def allowed_methods(_conn), do: ["POST"]
      def exists?(_conn), do: true
      def if_match_exists?(_conn), do: false
      def if_unmodified_since_exists?(_conn), do: false
      def if_none_match_exists?(_conn), do: false
      def post_to_existing?(_conn), do: true
      def conflict?(_conn), do: false
      def method_post?(_conn), do: true
      def post_enacted?(_conn), do: true
      def post_redirect?(_conn), do: false
      def new?(_conn), do: false
      def respond_with_entity?(_conn), do: true
      def multiple_representations?(_conn), do: false
    end

    conn = conn(:post, "/")
    conn = PostNewSingleEntityResponseResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "OK"
  end

  test "returns 300 if post when resource is not new and we want an entity response with multiple representations" do
    defmodule PostNewMultipleEntityResponseResource do
      use Liberator.Resource
      @impl true
      def allowed_methods(_conn), do: ["POST"]
      def exists?(_conn), do: true
      def if_match_exists?(_conn), do: false
      def if_unmodified_since_exists?(_conn), do: false
      def if_none_match_exists?(_conn), do: false
      def post_to_existing?(_conn), do: true
      def conflict?(_conn), do: false
      def method_post?(_conn), do: true
      def post_enacted?(_conn), do: true
      def post_redirect?(_conn), do: false
      def new?(_conn), do: false
      def respond_with_entity?(_conn), do: true
      def multiple_representations?(_conn), do: true
    end

    conn = conn(:post, "/")
    conn = PostNewMultipleEntityResponseResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 300
    assert conn.resp_body == "Multiple Representations"
  end

  test "returns 201 if put when resource is new" do
    defmodule PostNewResource do
      use Liberator.Resource
      @impl true
      def allowed_methods(_conn), do: ["POST"]
      def exists?(_conn), do: true
      def if_match_exists?(_conn), do: false
      def if_unmodified_since_exists?(_conn), do: false
      def if_none_match_exists?(_conn), do: false
      def post_to_existing?(_conn), do: true
      def conflict?(_conn), do: false
      def method_post?(_conn), do: true
      def post_enacted?(_conn), do: true
      def post_redirect?(_conn), do: false
      def new?(_conn), do: true
    end

    conn = conn(:post, "/")
    conn = PostNewResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 201
    assert conn.resp_body == "Created"
  end
end
