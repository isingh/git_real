require 'githubber'

class ApplicationController < ActionController::Base
  include ActionView::Helpers::OutputSafetyHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Context
  include UserSession

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  ALERT_TYPES = [:success, :info, :warning, :danger]

  helper_method :bootstrap_flash
  helper_method :is_logged_in?
  helper_method :current_user_profile

  private

  def bootstrap_flash
    flash_messages = []
    flash.each do |type, message|
      # Skip empty messages, e.g. for devise messages set to nothing in a locale file.
      next if message.blank?

      type = type.to_sym
      type = :success if type == :notice
      type = :danger  if type == :alert
      type = :danger  if type == :error
      next unless ALERT_TYPES.include?(type)

      Array(message).each do |msg|
        text = content_tag(:div,
                            content_tag(:button, raw("&times;"), 
                                       :class => "close", 
                                       "data-dismiss" => "alert",
                                       "aria-hidden" => "true",
                                       "type" => "button") +
                            msg,
                           :class => "alert fade in alert-#{type} alert-dismissable")
        flash_messages << text if msg
      end
    end
    flash_messages.join("\n").html_safe
  end

  def current_github_user
    @current_github_user ||= Githubber::User.new(current_user_profile.oauth_token)
  end
end
