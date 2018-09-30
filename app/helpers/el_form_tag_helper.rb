module ElFormTagHelper
  extend ActionView::Helpers::FormTagHelper

  def el_form_tag_html(html_options)
    extra_tags = extra_tags_for_form(html_options)
    tag('el-form', html_options, true) + extra_tags
  end

  def el_form_tag_with_body(html_options, content)
    output = el_form_tag_html(html_options)
    output << content
    output.safe_concat("</el-form>")
  end
end
