module ApplicationHelper
  def timeago(datetime)
    ago_or_from_now = datetime < Time.now ? 'ago' : 'from now'
    "<time
      data-controller='timeago'
      data-timeago-datetime-value='#{datetime.to_datetime.iso8601}'
      title='#{datetime.to_s}'
    >#{time_ago_in_words(datetime)} #{ago_or_from_now}</time>".html_safe
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

  def backlinks(record)
    return "" if record.backlinks.empty?
    html =  "<h2>Backlinks</h2>" +
            "<p>Items that link back to this #{record.class.name.downcase}:</p>" +
            "<ul>" +
              record.backlinks.map do |r|
                model_name = r.class.name.downcase
                icon = "<i class='#{model_name}-icon'></i>"
                created_or_updated = r.updated_at == r.created_at ? "created" : "last updated"
                created_or_updated_at = r.updated_at
                hover_message = "#{r.title}\nCreated #{time_ago_in_words(r.created_at)} ago"
                "<li><a style='font-weight:bold;' href='#{r.path}' title='#{hover_message}'>#{icon} #{r.title}</a></li>"
              end.join +
            "</ul>"
    html.html_safe
  end

end
