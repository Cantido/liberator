# SPDX-FileCopyrightText: 2024 Rosa Richter
#
# SPDX-License-Identifier: AGPL-3.0-or-later

defmodule Liberator.Default.Handlers do
  import Liberator.Gettext

  @moduledoc false

  def handle_ok(_onn) do
    gettext("OK")
  end

  def handle_options(_conn) do
    gettext("Options")
  end

  def handle_created(_conn) do
    gettext("Created")
  end

  def handle_accepted(_conn) do
    gettext("Accepted")
  end

  def handle_no_content(_conn) do
    gettext("No Content")
  end

  def handle_multiple_representations(_conn) do
    gettext("Multiple Representations")
  end

  def handle_moved_permanently(_conn) do
    gettext("Moved Permanently")
  end

  def handle_see_other(_conn) do
    gettext("See Other")
  end

  def handle_not_modified(_conn) do
    gettext("Not Modified")
  end

  def handle_moved_temporarily(_conn) do
    gettext("Moved Temporarily")
  end

  def handle_malformed(_conn) do
    gettext("Malformed")
  end

  def handle_payment_required(_conn) do
    gettext("Payment Required")
  end

  def handle_unauthorized(_conn) do
    gettext("Unauthorized")
  end

  def handle_forbidden(_conn) do
    gettext("Forbidden")
  end

  def handle_not_found(_conn) do
    gettext("Not Found")
  end

  def handle_method_not_allowed(_conn) do
    gettext("Method Not Allowed")
  end

  def handle_not_acceptable(_conn) do
    gettext("Not Acceptable")
  end

  def handle_conflict(_conn) do
    gettext("Conflict")
  end

  def handle_gone(_conn) do
    gettext("Gone")
  end

  def handle_precondition_failed(_conn) do
    gettext("Precondition Failed")
  end

  def handle_request_entity_too_large(_conn) do
    gettext("Request Entity Too Large")
  end

  def handle_uri_too_long(_conn) do
    gettext("URI Too Long")
  end

  def handle_unsupported_media_type(_conn) do
    gettext("Unsupported Media Type")
  end

  def handle_unprocessable_entity(_conn) do
    gettext("Unprocessable Entity")
  end

  def handle_too_many_requests(_conn) do
    gettext("Too Many Requests")
  end

  def handle_unavailable_for_legal_reasons(_conn) do
    gettext("Unavailable for Legal Reasons")
  end

  def handle_error(conn, _error, _failed_step) do
    body = gettext("Internal Server Error")

    Plug.Conn.resp(conn, 500, body)
  end

  def handle_not_implemented(_conn) do
    gettext("Not Implemented")
  end

  def handle_unknown_method(_conn) do
    gettext("Unknown Method")
  end

  def handle_service_unavailable(_conn) do
    gettext("Service Unavailable")
  end
end
