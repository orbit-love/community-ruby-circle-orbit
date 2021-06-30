#!/usr/bin/env ruby
# frozen_string_literal: true

require "circle_orbit"
require "thor"

module CircleOrbit
  module Scripts
    class CheckComments < Thor
      desc "render", "check for new comments in Spaces posts and push them to Orbit"
      def render(*params)
        client = CircleOrbit::Client.new(historical_import: params[0])
        client.comments
      end
    end
  end
end
