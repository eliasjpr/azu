module Azu
  module ContentNegotiator
    extend self

    def content(context, view : Nil)
      context.response.status_code = 204
      ""
    end

    def content(context, view : String)
      context.response.content_type = "text/plain"
      view
    end

    def content(context, view : Azu::View)
      accept = context.request.accept
      return view.text unless accept
      accept.each do |a|
        case a.sub_type.not_nil!
        when "html"
          context.response.content_type = a.to_s
          return view.html
        when "json"
          context.response.content_type = a.to_s
          return view.json
        when "xml"
          context.response.content_type = a.to_s
          return view.xml
        when "plain", "*"
          context.response.content_type = a.to_s
          return view.text
        else
          next
        end
      end
    end
  end
end
