module ApplicationHelper
  def timeago(datetime)
    ago_or_from_now = datetime < Time.now ? 'ago' : 'from now'
    "<time
      data-controller='timeago'
      data-timeago-datetime-value='#{datetime.iso8601}'
      data-refresh-interval='#{60 * 1000}'
      title='#{datetime.to_s(:long)}'
    >#{time_ago_in_words(datetime)}</time> #{ago_or_from_now}".html_safe
  end

  def countdown(datetime)
    "<time
      data-controller='countdown'
      data-countdown-end-time-value='#{datetime.iso8601}'
      >
      <span data-target='countdown.time' style='font-family:monospace;'>...</span>
    </time>".html_safe
  end

  def username_with_profile_link(user)
    "<a href='/users/#{user.id}'>#{sanitize(user.username || user.display_name || user.email)}</a>".html_safe
  end
end
