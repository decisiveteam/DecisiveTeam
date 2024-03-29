module ApplicationHelper
  def timeago(datetime)
    ago_or_from_now = datetime < Time.now ? 'ago' : 'from now'
    "<time
      data-controller='timeago'
      data-timeago-datetime-value='#{datetime.iso8601}'
      data-refresh-interval='#{60 * 1000}'
      title='#{datetime.to_s}'
    >#{time_ago_in_words(datetime)}</time> #{ago_or_from_now}".html_safe
  end

  def countdown(datetime, base_unit: 'seconds')
    "<time
      data-controller='countdown'
      data-countdown-end-time-value='#{datetime.iso8601}'
      data-countdown-base-unit-value='#{base_unit}'
      >
      <span data-countdown-target='time' style='font-family:monospace;'>...</span>
    </time>".html_safe
  end

  def markdown(text)
    return "" unless text
    MarkdownRenderer.render(text).html_safe
  end

  def markdown_inline(text)
    return "" unless text
    MarkdownRenderer.render_inline(text).html_safe
  end

end
