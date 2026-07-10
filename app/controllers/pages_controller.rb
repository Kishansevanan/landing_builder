class PagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_page, only: %i[show update publish publication_status]

  def index
    @pages = current_user.pages.order(created_at: :desc)
  end

  def new
    @page = current_user.pages.new
  end

  def create
    @page = current_user.pages.new(page_create_params)
    @page.slug = generate_slug(@page.title) if @page.slug.blank?
    if @page.save
      redirect_to @page
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def update
    if @page.update(layout: params.require(:page).permit(layout: {})[:layout])
      head :ok
    else
      render json: @page.errors, status: :unprocessable_entity
    end
  end

  def publish
    PublishPageJob.perform_async(@page.id)
    render json: { queued_at: Time.current.iso8601 }
  end

  def publication_status
    render json: { published_at: @page.reload.published_at&.iso8601 }
  end

  private

  def set_page
    @page = current_user.pages.find(params[:id])
  end

  def page_create_params
    params.require(:page).permit(:title)
  end

  def generate_slug(title)
    return SecureRandom.hex(6) if title.blank?
    base = title.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/^-+|-+$/, "")
    base = SecureRandom.hex(6) if base.blank?
    slug = base
    n = 2
    while Page.exists?(slug: slug)
      slug = "#{base}-#{n}"
      n += 1
    end
    slug
  end
end