module Admin::ApplicationHelper
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
