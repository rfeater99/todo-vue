module ElFormHelper
  extend ActionView::Helpers::FormHelper

  def form_for(record, options = {}, &block)
    return super unless options[:builder] && options[:builder] == ElFormBuilder

    raise ArgumentError, "Missing block" unless block_given?
    html_options = options[:html] ||= {}

    case record
    when String, Symbol
      object_name = record
      object      = nil
    else
      object      = record.is_a?(Array) ? record.last : record
      raise ArgumentError, "First argument in form cannot contain nil or be empty" unless object
      object_name = options[:as] || model_name_from_record_or_class(object).param_key
      apply_form_for_options!(record, object, options)
    end

    html_options[:data]   = options.delete(:data)   if options.has_key?(:data)
    html_options[:remote] = options.delete(:remote) if options.has_key?(:remote)
    html_options[:method] = options.delete(:method) if options.has_key?(:method)
    html_options[:enforce_utf8] = options.delete(:enforce_utf8) if options.has_key?(:enforce_utf8)
    html_options[:authenticity_token] = options.delete(:authenticity_token)

    builder = instantiate_builder(object_name, object, options)
    output  = capture(builder, &block)
    html_options[:multipart] ||= builder.multipart?

    html_options = html_options_for_form(options[:url] || {}, html_options)
    
    options.delete(:url)
    options.delete(:builder)
    options.delete(:as)
    options.delete(:html)
    html_options = html_options.merge(options)
    el_form_tag_with_body(html_options, output)
  end
end
