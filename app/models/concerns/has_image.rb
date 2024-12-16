module HasImage
  extend ActiveSupport::Concern

  def image_path
    if image.attached?
      Rails.application.routes.url_helpers.rails_blob_url(image, only_path: true)
    else
      '/placeholder.png'
    end
  end

  def image_path_no_placeholder
    if image.attached?
      Rails.application.routes.url_helpers.rails_blob_url(image, only_path: true)
    else
      nil
    end
  end

  def image_url
    image_path
  end

  def image_url=(url)
    downloaded_image = URI.open(url)
    if downloaded_image.content_type.start_with?('image/')
      filename = File.basename(URI.parse(url).path)
      self.image.attach(io: downloaded_image, filename: filename)
    end
  end

  def cropped_image_data=(cropped_image_data)
    if cropped_image_data.present?
      image_data = cropped_image_data.gsub(/^data:image\/\w+;base64,/, '')
      image_data = Base64.decode64(image_data)
      temp_file = Tempfile.new(['cropped_image', '.jpg'])
      temp_file.binmode
      temp_file.write(image_data)
      temp_file.rewind

      self.image.attach(io: temp_file, filename: 'profile_image.jpg')
      self.save!
      temp_file.close
      temp_file.unlink
    else
      self.image.purge
    end
  end

  included do
    has_one_attached :image, dependent: :destroy
  end
end
