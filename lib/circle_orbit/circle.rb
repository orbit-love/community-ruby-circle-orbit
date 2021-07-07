# frozen_string_literal: true

module CircleOrbit
  class Circle
    def initialize(params = {})
      @circle_api_key = params.fetch(:circle_api_key)
      @circle_community_id = params.fetch(:circle_community_id)
      @circle_url = params.fetch(:circle_url)
      @orbit_api_key = params.fetch(:orbit_api_key)
      @orbit_workspace = params.fetch(:orbit_workspace)
      @historical_import = params.fetch(:historical_import, false)
    end

    def process_posts
      spaces = get_spaces

      spaces.each do |space|
        posts = get_posts(space["id"])

        times = 0
        orbit_timestamp = last_orbit_activity_timestamp(type: "post")

        posts.each do |post|
          next if post.nil? || post.empty?

          unless @historical_import && orbit_timestamp
            next if post["created_at"] < orbit_timestamp unless orbit_timestamp.nil?
          end

          if orbit_timestamp && @historical_import == false
            next if post["created_at"] < orbit_timestamp
          end

          times += 1

          CircleOrbit::Orbit.call(
            type: "post",
            data: post,
            orbit_api_key: @orbit_api_key,
            orbit_workspace: @orbit_workspace
          )
        end

        output = "Sent #{times} new posts to your Orbit workspace"

        puts output
        return output
      end
    end

    def process_comments
      comments = get_comments

      return if comments.nil? || comments.empty?

      times = 0
      orbit_timestamp = last_orbit_activity_timestamp(type: "comment")
      comments.each do |comment|
        next if comment.nil? || comment.empty?

        unless @historical_import && orbit_timestamp
          next if comment["body"]["created_at"] < orbit_timestamp unless orbit_timestamp.nil?
        end

        if orbit_timestamp && @historical_import == false
          next if comment["body"]["created_at"] < orbit_timestamp
        end

        times += 1

        CircleOrbit::Orbit.call(
          type: "comment",
          data: comment,
          orbit_api_key: @orbit_api_key,
          orbit_workspace: @orbit_workspace
        )
      end
      output = "Sent #{times} new comments to your Orbit workspace"

      puts output
      return output
    end

    private

    def get_spaces
      url = URI("#{@circle_url}/api/v1/spaces?community_id=#{@circle_community_id}")

      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = true

      request = Net::HTTP::Get.new(url)
      request["Authorization"] = "Token #{@circle_api_key}"

      response = https.request(request)

      JSON.parse(response.body)
    end

    def get_posts(id)
      page = 1
      posts = []
      looped_at_least_once = false

      while page >= 1
        page += 1 if looped_at_least_once
        url = URI("#{@circle_url}/api/v1/posts?community_id=#{@circle_community_id}&space_id=#{id}&page=#{page}")

        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = true

        request = Net::HTTP::Get.new(url)
        request["Authorization"] = "Token #{@circle_api_key}"

        response = https.request(request)

        response = JSON.parse(response.body)
        posts << response unless response.empty? || response.nil?
        looped_at_least_once = true

        break if response.empty? || response.nil?
      end

      posts.flatten!
    end

    def get_comments
      url = URI("#{@circle_url}/api/v1/comments?community_id=#{@circle_community_id}")

      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = true

      request = Net::HTTP::Get.new(url)
      request["Authorization"] = "Token #{@circle_api_key}"

      response = https.request(request)

      JSON.parse(response.body)
    end

    def last_orbit_activity_timestamp(type: )
      @last_orbit_activity_timestamp ||= begin
        if type == "post"
          activity_type = "custom:circle:post"
        end

        if type == "comment"
          activity_type = "custom:circle:comment"
        end

        OrbitActivities::Request.new(
          api_key: @orbit_api_key,
          workspace_id: @orbit_workspace,
          user_agent: "community-ruby-circle-orbit/#{CircleOrbit::VERSION}",
          action: "latest_activity_timestamp",
          filters: { activity_type: activity_type }
        ).response
      end
    end
  end
end
