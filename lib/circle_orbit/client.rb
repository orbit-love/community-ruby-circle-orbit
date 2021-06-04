# frozen_string_literal: true

require "dotenv/load"
require "net/http"
require "json"

# Create a client to log Circle activities in your Orbit workspace
# Credentials can either be passed in to the instance or be loaded
# from environment variables
#
# @example
#   client = CircleOrbit::Client.new
#
# @option params [String] :orbit_api_key
#   The API key for the Orbit API
#
# @option params [String] :orbit_workspace
#   The workspace ID for the Orbit workspace
#
# @option params [String] :circle_api_key
#   The API key for the Circle API
#
# @option params [String] :circle_url
#   The URL of the Circle community
#
# @param [Hash] params
#
# @return [CircleOrbit::Client]
#
module CircleOrbit
  class Client
    attr_accessor :orbit_api_key, :orbit_workspace, :circle_api_key, :circle_url, :circle_community_id

    def initialize(params = {})
      @orbit_api_key = params.fetch(:orbit_api_key, ENV["ORBIT_API_KEY"])
      @orbit_workspace = params.fetch(:orbit_workspace, ENV["ORBIT_WORKSPACE_ID"])
      @circle_api_key = params.fetch(:circle_api_key, ENV["CIRCLE_API_KEY"])
      @circle_url = params.fetch(:circle_url, ENV["CIRCLE_URL"])
      @circle_community_id = circle_community_id

      after_initialize!
    end

    def posts
      CircleOrbit::Circle.new(
        circle_api_key: @circle_api_key,
        circle_url: @circle_url,
        circle_community_id: @circle_community_id,
        orbit_api_key: @orbit_api_key,
        orbit_workspace: @orbit_workspace
      ).process_posts
    end

    def comments
      CircleOrbit::Circle.new(
        circle_api_key: @circle_api_key,
        circle_url: @circle_url,
        circle_community_id: @circle_community_id,
        orbit_api_key: @orbit_api_key,
        orbit_workspace: @orbit_workspace
      ).process_comments
    end

    private

    def after_initialize!
      @circle_url = sanitize_url(@circle_url)
    end

    def sanitize_url(url)
      return url.delete_suffix("/") if url[-1, 1] == "/"

      url
    end

    def circle_community_id
      @circle_community_id ||= begin
        return ENV["CIRCLE_COMMUNITY_ID"] if ENV["CIRCLE_COMMUNITY_ID"]

        url = URI("#{@circle_url}/api/v1/communities")

        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = true

        request = Net::HTTP::Get.new(url)
        request["Authorization"] = "Token #{@circle_api_key}"

        response = https.request(request)

        response = JSON.parse(response.body)

        response[0]["id"]
      end
    end
  end
end
