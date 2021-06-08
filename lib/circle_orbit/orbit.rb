# frozen_string_literal: true

require "net/http"
require "json"

module CircleOrbit
  class Orbit
    def self.call(type:, data:, orbit_workspace:, orbit_api_key:)
      if type == "post"
        CircleOrbit::Interactions::Post.new(
          post_title: data["name"],
          body: data["body"]["body"],
          created_at: data["body"]["created_at"],
          id: data["body"]["record_id"],
          space: data["space_name"],
          url: data["url"],
          author: data["user_name"],
          email: data["user_email"],
          workspace_id: orbit_workspace,
          api_key: orbit_api_key
        )
      end

      if type == "comment"
        CircleOrbit::Interactions::Comment.new(
          post_title: data["post_name"],
          body: data["body"]["body"],
          created_at: data["body"]["created_at"],
          id: data["body"]["record_id"],
          space: data["space_slug"].gsub(/-/, " ").capitalize,
          url: data["url"],
          author: data["user_name"],
          email: data["user_email"],
          workspace_id: orbit_workspace,
          api_key: orbit_api_key
        )
      end
    end
  end
end
