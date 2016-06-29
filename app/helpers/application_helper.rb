module ApplicationHelper

  # ページごとの完全なタイトルを返します。
  def full_title(page_title)
    base_title = "KAKEBO"
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end

  def sortable(column, title = nil, flag = false)
    title ||= column.titleize
    css_class = (column == sort_column) ? "current #{sort_direction}" : nil
    direction = (column == sort_column && sort_direction == "desc") ? "asc" : "desc"
    if flag
      link_to title, {
                       :sort => column,
                       :direction => direction,
                       :params => {:kakebo => params[:kakebo]},
                     },
                     {:class => css_class}
    else
      link_to title, {
                       :sort => column,
                       :direction => direction,
                       :params => {:q => params[:q]},
                     },
                     {:class => css_class}
    end
  end
end
