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

  def render_element(element, css_rules)
    class_name = "el-#{element['id']}"
    css_rules << ".#{class_name} { position: absolute; #{style_string(element['style'])} }"

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
    style.map { |k, v| "#{k}: #{v};" }.join(" ")
  end
end