class PublicPagesController < ActionController::Base
  def show
    slug = params[:slug]
    publication = Rails.cache.fetch("page:#{slug}:publication") do
      pub = Page.published.find_by!(slug: slug).latest_publication
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