class LayoutCompiler
  TAG_FOR_TYPE = { "text" => "p", "image" => "img", "button" => "a" }.freeze

  def initialize(layout)
    @layout = layout
  end

  def call
    css_rules = []
    body = @layout["elements"].map { |element| render_element(element, css_rules) }.join
    ["<div class=\"page\">#{body}</div>", css_rules.join("\n")]
  end

  private

  BASE_CSS = {
    "button" => "display: inline-block; padding: 8px 16px; text-decoration: none; font-weight: 600; background-color: #0a7065; color: #ffffff; border-radius: 6px; font-size: 14px;",
    "text"   => "font-size: 16px; color: #1a1a17; margin: 0;",
    "image"  => ""
  }.freeze

  def render_element(element, css_rules)
    class_name = "el-#{element['id']}"
    base = BASE_CSS[element["type"]] || ""
    css_rules << ".#{class_name} { position: absolute; #{base} #{style_string(element['style'])} }"

    case element["type"]
    when "image"
      "<img class=\"#{class_name}\" src=\"#{CGI.escapeHTML(element['props']['src'].to_s)}\">"
    when "button"
      "<a class=\"#{class_name}\" href=\"#{CGI.escapeHTML(element['props']['href'].to_s)}\">#{CGI.escapeHTML(element['props']['label'].to_s)}</a>"
    else
      "<p class=\"#{class_name}\">#{CGI.escapeHTML(element['props']['text'].to_s)}</p>"
    end
  end

  def style_string(style)
    return "" unless style
    style.map { |k, v| "#{k.gsub(/([A-Z])/) { "-#{$1.downcase}" }}: #{v};" }.join(" ")
  end
end