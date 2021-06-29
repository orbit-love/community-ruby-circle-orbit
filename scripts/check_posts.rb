#!/usr/bin/env ruby
# frozen_string_literal: true

require "circle_orbit"
require "thor"

module CircleOrbit
  module Scripts
    class CheckPosts < Thor
      desc "render", "check for new posts in Circle Spaces and push them to Orbit"
      def render(*params)
        client = CircleOrbit::Client.new(historical_import: params[0])
        client.posts
      end
    end
  end
end
