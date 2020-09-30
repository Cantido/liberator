defmodule LiberatorEx.Base do
  @behaviour LiberatorEx.Resource

  def service_available?(_conn) do
    true
  end

  def known_method?(_conn) do
    true
  end

  def uri_too_long?(_conn) do
    false
  end

  def method_allowed?(_conn) do
    true
  end

  def malformed?(_conn) do
    false
  end

  def authorized?(_conn) do
    true
  end

  def allowed?(_conn) do
    true
  end

  def valid_content_header?(_conn) do
    true
  end

  def known_content_type?(_conn) do
    true
  end

  def valid_entity_length?(_conn) do
    true
  end
end
