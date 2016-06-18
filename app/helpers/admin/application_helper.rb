module Admin::ApplicationHelper
  def render_admin_breadcrumb(info)
    content_tag(:ol, class: "breadcrumb row") do
      info[0...-1].each do |e|
        concat content_tag(:li, content_tag(:a, e[:text], href: e[:path]))
      end
      concat content_tag(:li, info.last, class: "active")
    end
  end

  def admin_render_tabs(tabs_info)
    list_items = tabs_info.map do |tab_info|
      tab_class = "active" if current_page?(tab_info[:path])
      content_tag(:li, class: tab_class) do
        content_tag(:a, tab_info[:text], href: tab_info[:path])
      end
    end

    content_tag(:ul, class: "nav nav-tabs row") do
      list_items.each do |e|
        concat e
      end
    end
  end
end
