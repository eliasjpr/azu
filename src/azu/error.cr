module Azu
  class Error < Exception
    getter status : Int32 = 500
    getter title : String = "Internal Server Error"
    getter detail : String = "Internal Server Error"
    getter source : String = ""
    getter errors : Array(String)? = nil

    delegate :log, :env, to: Azu

    def initialize(@detail = "", @source = "")
    end

    def self.from_exception(ex)
      new detail: ex.message.not_nil!
    end

    def link
      "https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/#{status}"
    end

    def to_json
      {
        status: status,
        link:   link,
        title:  title,
        detail: detail,
        errors: errors,
        source: source,
      }.to_json
    end

    def render(context)
      view = ErrorView.new(context, self)
      context.response.reset
      context.response.status_code = status
      context.response.print ContentNegotiator.content(context, view)
      print_log
    end

    private def print_log
      log.error detail
      log.error inspect_with_backtrace if env.development?
    end
  end

  class MissingParam < Error
    getter title = "Missing params"
    getter status : Int32 = 400

    def initialize(@errors = Array(String).new)
    end
  end

  class BadRequest < Error
    getter title = "Invalid json"
    getter status : Int32 = 400
  end

  class InvalidJson < Error
    getter title = "Invalid json"
    getter status : Int32 = 400
  end

  class NotFound < Error
    getter title = "Not found"
    getter status : Int32 = 404
  end

  class NotAcceptable < Error
    getter title = "Not acceptable"
    getter status : Int32 = 406
  end
end
