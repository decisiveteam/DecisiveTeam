class Pages::MainController < ApplicationController

  def index
    if pages_domain?
      render layout: layout, html: "<h1>Pages</h1>"
    elsif pages_enabled?
      @pages = Page.where(studio: current_studio, published: true).order(published_at: :desc)
      # Let rails view template handle rendering
    else
      render plain: '404 not found', status: 404
    end
  end

  def new
    if pages_enabled?
      @scratchpad_links = [] unless pages_domain?
      render layout: layout
    else
      render plain: '404 not found', status: 404
    end
  end

  def publish
    if pages_enabled?
      page = Page.create!(
        user: current_user,
        title: params[:title],
        path: params[:path],
        markdown: params[:markdown],
        published: true,
        published_at: Time.now,
        settings: params[:settings] || {}
      )
      redirect_to page.full_studio_path
    else
      render plain: '404 not found', status: 404
    end
  end

  def show
    @page = Page.find_by(path: params[:path], published: true)
    if @page
      @page_title = @page.title
      @show_studio_name = studio_domain?
      if pages_domain?
        render layout: 'pages', html: @page.html.html_safe
      else
        # Let rails view template handle rendering
      end
    else
      render plain: '404 not found', status: 404
    end
  end

  private

  def solo_domain
    ENV['PAGES_DOMAIN']
  end

  def feature_name
    'pages'
  end

  def pages_domain?
    solo_domain?
  end

  def pages_enabled?
    feature_enabled?
  end

  def layout
    if pages_domain?
      'pages'
    elsif @page
      'pages_with_studio_name'
    else
      'application'
    end
  end

  def current_resource_model
    Page
  end

end