# frozen_string_literal: true

module CircleOrbit
  class Circle
    def initialize(params = {})
      @circle_api_key = params.fetch(:circle_api_key)
      @circle_community_id = params.fetch(:circle_community_id)
      @circle_url = params.fetch(:circle_url)
      @orbit_api_key = params.fetch(:orbit_api_key)
      @orbit_workspace = params.fetch(:orbit_workspace)
    end

    def process_posts
      spaces = get_spaces
      require "byebug"
      byebug

      spaces.each do |space|
        posts = get_posts(space["id"])

        posts.each do |post|
          CircleOrbit::Orbit.call(
            type: "post",
            data: post,
            orbit_api_key: @orbit_api_key,
            orbit_workspace: @orbit_workspace
          )
        end
      end
    end

    def process_comments
        comments = get_comments

        return if comments.nil? || comments.empty?

        comments.each do |comment|
            CircleOrbit::Orbit.call(
                type: "comment",
                data: comment,
                orbit_api_key: @orbit_api_key,
                orbit_workspace: @orbit_workspace
            )
        end
    end

    private

    def get_spaces
      url = URI("#{@circle_url}/api/v1/spaces?community_id=#{@circle_community_id}")

      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = true

      request = Net::HTTP::Get.new(url)
      request["Authorization"] = "Token #{@circle_api_key}"

      response = https.request(request)

      response = JSON.parse(response.body)
    end

    def get_posts(id)
      url = URI("#{@circle_url}/api/v1/posts?community_id=#{@circle_community_id}&space_id=#{id}")

      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = true

      request = Net::HTTP::Get.new(url)
      request["Authorization"] = "Token #{@circle_api_key}"

      response = https.request(request)

      response = JSON.parse(response.body)
    end

    def get_comments
        url = URI("#{@circle_url}/api/v1/comments?community_id=#{@circle_community_id}")

        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = true
  
        request = Net::HTTP::Get.new(url)
        request["Authorization"] = "Token #{@circle_api_key}"
  
        response = https.request(request)
  
        response = JSON.parse(response.body)
    end
  end
end
