# frozen_string_literal: true

module CircleOrbit
  class Utils
    def self.sanitize_body(body)
      body = ActionView::Base.full_sanitizer.sanitize(body)

      body&.gsub!("\n", " ")

      body
    end
  end
end
