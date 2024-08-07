# SPDX-FileCopyrightText: 2024 Rosa Richter
#
# SPDX-License-Identifier: AGPL-3.0-or-later

defmodule Liberator.Default.DecisionTree do
  @moduledoc false

  def decisions do
    %{
      service_available?: {:known_method?, :handle_service_unavailable},
      known_method?: {:method_allowed?, :handle_unknown_method},
      method_allowed?: {:uri_too_long?, :handle_method_not_allowed},
      uri_too_long?: {:handle_uri_too_long, :valid_content_header?},
      valid_content_header?: {:known_content_type?, :handle_not_implemented},
      known_content_type?: {:method_options?, :handle_unsupported_media_type},
      method_options?: {:handle_options, :body_exists?},
      body_exists?: {:valid_entity_length?, :authorized?},
      valid_entity_length?: {:well_formed?, :handle_request_entity_too_large},
      well_formed?: {:malformed?, :handle_malformed},
      malformed?: {:handle_malformed, :authorized?},
      authorized?: {:allowed?, :handle_unauthorized},
      allowed?: {:too_many_requests?, :handle_forbidden},
      too_many_requests?: {:handle_too_many_requests, :payment_required?},
      payment_required?: {:handle_payment_required, :accept_exists?},
      accept_exists?: {:media_type_available?, :accept_language_exists?},
      media_type_available?: {:accept_language_exists?, :handle_not_acceptable},
      accept_language_exists?: {:language_available?, :accept_charset_exists?},
      language_available?: {:accept_charset_exists?, :handle_not_acceptable},
      accept_charset_exists?: {:charset_available?, :accept_encoding_exists?},
      charset_available?: {:accept_encoding_exists?, :handle_not_acceptable},
      accept_encoding_exists?: {:encoding_available?, :processable?},
      encoding_available?: {:processable?, :handle_not_acceptable},
      processable?: {:unavailable_for_legal_reasons?, :handle_unprocessable_entity},
      unavailable_for_legal_reasons?: {:handle_unavailable_for_legal_reasons, :exists?},
      exists?: {:if_match_exists?, :if_match_star_exists_for_missing?},
      if_match_exists?: {:if_match_star?, :if_unmodified_since_exists?},
      if_match_star?: {:if_unmodified_since_exists?, :etag_matches_for_if_match?},
      etag_matches_for_if_match?: {:if_unmodified_since_exists?, :handle_precondition_failed},
      if_unmodified_since_exists?: {:if_unmodified_since_valid_date?, :if_none_match_exists?},
      if_unmodified_since_valid_date?: {:unmodified_since?, :if_none_match_exists?},
      unmodified_since?: {:handle_precondition_failed, :if_none_match_exists?},
      if_none_match_exists?: {:if_none_match_star?, :if_modified_since_exists?},
      if_none_match_star?: {:if_none_match?, :etag_matches_for_if_none?},
      etag_matches_for_if_none?: {:if_none_match?, :if_modified_since_exists?},
      if_none_match?: {:handle_not_modified, :handle_precondition_failed},
      if_modified_since_exists?: {:if_modified_since_valid_date?, :method_delete?},
      if_modified_since_valid_date?: {:modified_since?, :method_delete?},
      modified_since?: {:method_delete?, :handle_not_modified},
      if_match_star_exists_for_missing?: {:handle_precondition_failed, :method_put?},
      method_put?: {:put_to_different_url?, :existed?},
      put_to_different_url?: {:handle_moved_permanently, :can_put_to_missing?},
      can_put_to_missing?: {:conflict?, :handle_not_implemented},
      existed?: {:moved_permanently?, :post_to_missing?},
      moved_permanently?: {:handle_moved_permanently, :moved_temporarily?},
      moved_temporarily?: {:handle_moved_temporarily, :post_to_gone?},
      post_to_gone?: {:can_post_to_gone?, :handle_gone},
      can_post_to_gone?: {:post!, :handle_gone},
      post_to_missing?: {:can_post_to_missing?, :handle_not_found},
      can_post_to_missing?: {:post!, :handle_not_found},
      method_delete?: {:delete!, :method_patch?},
      method_patch?: {:patch!, :post_to_existing?},
      post_to_existing?: {:conflict?, :put_to_existing?},
      put_to_existing?: {:conflict?, :multiple_representations?},
      conflict?: {:handle_conflict, :method_post?},
      method_post?: {:post!, :put!},
      delete_enacted?: {:respond_with_entity?, :handle_accepted},
      put_enacted?: {:new?, :handle_accepted},
      patch_enacted?: {:respond_with_entity?, :handle_accepted},
      post_enacted?: {:post_redirect?, :handle_accepted},
      post_redirect?: {:handle_see_other, :new?},
      new?: {:handle_created, :respond_with_entity?},
      respond_with_entity?: {:multiple_representations?, :handle_no_content},
      multiple_representations?: {:handle_multiple_representations, :handle_ok}
    }
  end

  def actions do
    %{
      initialize: :service_available?,
      delete!: :delete_enacted?,
      put!: :put_enacted?,
      patch!: :patch_enacted?,
      post!: :post_enacted?
    }
  end

  def handlers do
    %{
      handle_ok: 200,
      handle_options: 200,
      handle_created: 201,
      handle_accepted: 202,
      handle_no_content: 204,
      handle_multiple_representations: 300,
      handle_moved_permanently: 301,
      handle_see_other: 303,
      handle_not_modified: 304,
      handle_moved_temporarily: 307,
      handle_malformed: 400,
      handle_unauthorized: 401,
      handle_payment_required: 402,
      handle_forbidden: 403,
      handle_not_found: 404,
      handle_method_not_allowed: 405,
      handle_not_acceptable: 406,
      handle_conflict: 409,
      handle_gone: 410,
      handle_precondition_failed: 412,
      handle_request_entity_too_large: 413,
      handle_uri_too_long: 414,
      handle_unsupported_media_type: 415,
      handle_unprocessable_entity: 422,
      handle_too_many_requests: 429,
      handle_unavailable_for_legal_reasons: 451,
      handle_unknown_method: 501,
      handle_not_implemented: 501,
      handle_service_unavailable: 503
    }
  end
end
