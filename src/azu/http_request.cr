require "mime"

# :nodoc:
class HTTP::Request
  @path_params = {} of String => String
  @accept : Array(MIME::MediaType)? = nil

  def content_type : MIME::MediaType
    if content = headers["Content-Type"]?
      MIME::MediaType.parse(content)
    else
      MIME::MediaType.parse("text/plain")
    end
  end

  def path_params
    @path_params
  end

  def path_params=(params)
    @path_params = params
  end

  def accept : Array(MIME::MediaType) | Nil
    @accept ||= (
      if header = headers["Accept"]?
        header.split(",").map { |a| MIME::MediaType.parse(a) }.sort do |a, b|
          (b["q"]?.try &.to_f || 1.0) <=> (a["q"]?.try &.to_f || 1.0)
        end
      end
    )
  end
end
