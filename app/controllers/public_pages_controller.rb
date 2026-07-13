class PublicPagesController < ActionController::Base
  def show
    slug = params[:slug]
    page = Page.published.find_by!(slug: slug)
    cache_key = "page:#{slug}:publication:#{page.published_at.to_i}"
    publication = Rails.cache.fetch(cache_key, expires_in: 1.day) do
      pub = page.latest_publication
      { html: pub.html, css: pub.css }
    end
    render html: <<~HTML.html_safe, layout: false
      <!DOCTYPE html>
      <html>
        <head>
          <meta charset="utf-8">
          <style>
            body { margin: 0; }
            .page { position: relative; min-height: 100vh; }
            #{publication[:css]}
          </style>
        </head>
        <body>#{publication[:html]}</body>
      </html>
    HTML
  end
end
