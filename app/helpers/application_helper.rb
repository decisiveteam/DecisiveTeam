module ApplicationHelper
  def with_tag_links(text, team_id)
    sanitize(text).gsub(Tag.pattern) do |match|
      "<a href='/teams/#{team_id}/tags/#{$1}'>#{match}</a>"
    end.html_safe
  end
end
