module ApplicationHelper
  def with_tag_links(text, team_id)
    sanitize(text).gsub(Tag.pattern) do |match|
      resource_type = Tag.is_decision_tag?($1) ? 'decisions' : 'tags'
      "<a href='/teams/#{team_id}/#{resource_type}/#{$1}'>#{match}</a>"
    end.html_safe
  end

  def timeago(datetime)
    "<time data-controller='timeago' data-timeago-datetime-value='#{datetime.iso8601}' data-refresh-interval='#{60 * 1000}'>#{time_ago_in_words(datetime)}</time> ago".html_safe
  end

  def username_with_profile_link(user)
    "<a href='/users/#{user.id}'>#{sanitize(user.username || user.display_name || user.email)}</a>".html_safe
  end
end
