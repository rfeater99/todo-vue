class ElFormBuilder < ActionView::Helpers::FormBuilder

  def el_input_field(method, options={})
    opt = objectify_options(options)
    @template.content_tag(
      'el-input', '',
      id: "#{@object_name}_#{method}",
      name: "#{@object_name}[#{method}]",
      value: opt[:object][method],
      **options
    )
  end

  def el_checkbox(method, options={})
    opt = objectify_options(options)
    @template.content_tag(
      'el-checkbox', opt[:label],
      id: "#{@object_name}_#{method}",
      name: "#{@object_name}[#{method}]",
      checked: opt[:checked] || opt[:object][method],
      **options
    )
  end

  def el_submit(label, options={})
    @template.content_tag(
      'el-button', label,
      'native-type': :submit,
      **options
    )
  end

  def email_field(method, options={})
    super
  end
end