#!/usr/bin/env ruby
# frozen_string_literal: true

require "circle_orbit"
require "thor"

module CircleOrbit
  module Scripts
    class CheckPosts < Thor
      desc "render", "check for new posts in Circle Spaces and push them to Orbit"
      def render
        client = CircleOrbit::Client.new
        client.posts
      end
    end
  end
end