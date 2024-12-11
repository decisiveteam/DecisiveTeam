class AttachmentsController < ApplicationController
  def show
    file_extension = params[:extension] || params[:format]
    name_with_extension = "#{params[:name]}.#{file_extension}"
    attachment = current_resource.attachments.find_by(name: name_with_extension)
    return render status: 404, plain: 'Attachment Not Found' unless attachment
    file = attachment.file
    redirect_to rails_blob_path(file, disposition: "inline")
  end

  private

  def current_resource_model
    if params[:note_id]
      Note
    elsif params[:decision_id]
      Decision
    elsif params[:commitment_id]
      Commitment
    end
  end
end