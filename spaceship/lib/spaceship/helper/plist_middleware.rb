require 'faraday'

module FaradayMiddleware
  class PlistMiddleware < Faraday::Middleware
    def initialize(app, options = {})
      super(app)
      require 'plist' unless Object.const_defined?(:Plist)
    end

    def call(environment)
      @app.call(environment).on_complete do |env|
        if env.response_headers['content-type']&.include?('plist')
          env.body = parse_plist(env.body)
        end
      end
    end

    private

    def parse_plist(body)
      return body unless body
      body = body.force_encoding("UTF-8")
      Plist.parse_xml(body)
    rescue
      body
    end
  end
end

Faraday::Response.register_middleware(plist: FaradayMiddleware::PlistMiddleware)
