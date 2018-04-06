defmodule Statushq do
  @moduledoc """
  Statushq keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  def is_config_present?(app, key) do
    config = Application.get_env(app, key)
    config && String.length(config) > 0
  end

  def is_mailgun_configured?() do
    is_config_present?(:statushq, :mailgun_domain) &&
      is_config_present?(:statushq, :mailgun_api_key)
  end

  def is_twitter_configured?() do
    config = Application.get_env(:extwitter, :oauth)
    config && String.length(config[:consumer_key]) > 0 &&
      String.length(config[:consumer_secret]) > 0
  end
end
