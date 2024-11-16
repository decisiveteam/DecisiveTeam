# The purpose of this class is to render Markdown content as HTML, while
# sanitizing the HTML and adding rel="noopener noreferrer" to all links.
# This is a security measure to prevent malicious links from being used to
# exploit users.
# Also, for image tags we check for http(s) protocol and add loading="lazy"
# to enable lazy loading of images for performance and partial DoS protection.
class MarkdownRenderer
  @@markdown = Redcarpet::Markdown.new(
    Redcarpet::Render::HTML.new(
      hard_wrap: true,
      safe_links_only: true,
      filter_html: false, # Turned off so we can handle sanitization manually
      no_images: false,   # Same as above
      no_links: false,    # Same as above
      no_styles: true     # No need for inline styles
    ),
    autolink: true,
    tables: true,
    fenced_code_blocks: true
  )

  def self.render(content)
    raw_html = @@markdown.render(content.to_s)
    sanitized_html = sanitize(raw_html)
    shifted_header_html = shift_headers(sanitized_html)
    display_refereces(shifted_header_html)
  end

  def self.render_inline(content)
    raw_html = @@markdown.render(content.to_s)
    sanitized_html = sanitize(raw_html)
    sanitized_html.gsub(/<p>(.*)<\/p>/, '\1')
  end

  private

  def self.sanitize(html)
    sanitized_html = ActionController::Base.helpers.sanitize(html)
    doc = Nokogiri::HTML.fragment(sanitized_html)

    # Remove dangerous protocols from URLs
    doc.search('a').each do |a|
      if a['href']
        uri = URI.parse(a['href']) rescue nil
        if uri && !["http", "https", "mailto"].include?(uri.scheme)
          a.remove
        else
          a['rel'] = 'noopener noreferrer'
        end
      end
    end

    # Handle Image tags
    doc.search('img').each do |img|
      if img['src']
        uri = URI.parse(img['src']) rescue nil
        if uri && !["http", "https"].include?(uri.scheme)
          img.remove
        else
          # Optionally add lazy loading for performance and partial DoS protection
          img['loading'] = 'lazy'
        end
      end
    end

    doc.to_html
  end

  def self.shift_headers(html, shift_by: 2)
    # We want to shift the headers down by two because on the decision page
    # h1 is used for the decision question and h2 for the description, options, and results
    doc = Nokogiri::HTML.fragment(html)
    (1..6).reverse_each do |i|
      doc.search("h#{i}").each do |header|
        header.name = "h#{i + shift_by}"
      end
    end
    doc.to_html
  end

  def self.display_refereces(html)
    models = { 'n' => Note, 'c' => Commitment, 'd' => Decision }
    domain = ENV['HOSTNAME']
    pattern = Regexp.new("https://#{domain}/([ncd])/([0-9a-f-]+)")
    doc = Nokogiri::HTML.fragment(html)
    doc.search('a').each do |a|
      if a['href'] && a['href'].match?(pattern)
        matches = a.content.scan(pattern)
        matches.each do |m, id|
          model = models[m]
          column_name = id.length == 8 ? :truncated_id : :id
          resource = model.find_by(column_name => id)
          a['title'] = resource.title if resource
          if resource && a.content == a['href']
            a['class'] = "resource-link-#{model.name.downcase}"
            a.content = id
          end
        end
      end
    end
    doc.to_html
  end

end
