module ApplicationHelper
  def timeago(datetime)
    "<time data-controller='timeago' data-timeago-datetime-value='#{datetime.iso8601}' data-refresh-interval='#{60 * 1000}'>#{time_ago_in_words(datetime)}</time> ago".html_safe
  end

  def username_with_profile_link(user)
    "<a href='/users/#{user.id}'>#{sanitize(user.username || user.display_name || user.email)}</a>".html_safe
  end
end
