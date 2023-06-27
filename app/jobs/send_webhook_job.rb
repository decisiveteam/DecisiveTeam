require 'net/http'
require 'uri'

class SendWebhookJob < ApplicationJob
  queue_as :webhooks

  def perform(webhook_id, payload)
    webhook = Webhook.find(webhook_id)
    uri = URI.parse(webhook.url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.scheme == 'https'

    request = Net::HTTP::Post.new(uri.request_uri, { 'Content-Type' => 'application/json' })
    request.body = payload.to_json

    response = http.request(request)

    # Handle response here (e.g., log errors, schedule retries, etc.)
  end
end
