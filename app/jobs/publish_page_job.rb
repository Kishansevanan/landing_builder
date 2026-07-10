class PublishPageJob
  include Sidekiq::Job
  sidekiq_options queue: "publishing", retry: 3

  def perform(page_id)
    page = Page.find(page_id)
    html, css = LayoutCompiler.new(page.layout).call

    page.page_publications.create!(html: html, css: css)
    page.update!(status: :published, published_at: Time.current)
  end
end
