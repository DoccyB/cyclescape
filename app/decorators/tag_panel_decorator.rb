# frozen_string_literal: true

class TagPanelDecorator < ApplicationDecorator
  attr_accessor :context, :form_url, :cancel_url, :auth_context

  def initialize(context, options = {})
    self.context = context
    self.form_url = options[:form_url] || h.url_for([context, :tags])
    self.auth_context = options[:auth_context] || ((context.respond_to?(:source) ? context.source : context).class.name.underscore + '_tags').to_sym
    begin
      self.cancel_url = options[:cancel_url] || h.url_for
    rescue ActionController::UrlGenerationError => e
      Rollbar.log e
      self.cancel_url = "/"
    end
  end

  def render
    locals = { context: context, form_url: form_url, cancel_url: cancel_url, auth_context: auth_context }
    h.content_tag(:div, class: 'tags-panel') do
      panel = h.render partial: 'shared/tags/panel', locals: locals
      form = h.render partial: 'shared/tags/edit', locals: locals
      panel + form
    end
  end

  # Accessing Helpers
  #   You can access any helper via a proxy
  #
  #   Normal Usage: helpers.number_to_currency(2)
  #   Abbreviated : h.number_to_currency(2)
  #
  #   Or, optionally enable "lazy helpers" by calling this method:
  #     lazy_helpers
  #   Then use the helpers with no proxy:
  #     number_to_currency(2)

  # Defining an Interface
  #   Control access to the wrapped subject's methods using one of the following:
  #
  #   To allow only the listed methods (whitelist):
  #     allows :method1, :method2
  #
  #   To allow everything except the listed methods (blacklist):
  #     denies :method1, :method2

  # Presentation Methods
  #   Define your own instance methods, even overriding accessors
  #   generated by ActiveRecord:
  #
  #   def created_at
  #     h.content_tag :span, time.strftime("%a %m/%d/%y"),
  #                   :class => 'timestamp'
  #   end
end
