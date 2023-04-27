module ApplicationHelper
  def with_tag_links(text, team_id)
    sanitize(text).gsub(Tag.pattern) do |match|
      resource_type = Tag.is_decision_tag?($1) ? 'decisions' : 'tags'
      "<a href='/teams/#{team_id}/#{resource_type}/#{$1}'>#{match}</a>"
    end.html_safe
  end
end
