# frozen_string_literal: true

require "json"
require "action_view"
require_relative "../utils"

module CircleOrbit
  module Interactions
    class Post
      def initialize(post_title:, body:, created_at:, id:, space:, url:, author:, email:, workspace_id:, api_key:)
        @post_title = post_title
        @body = CircleOrbit::Utils.sanitize_body(body)
        @created_at = created_at
        @id = id
        @space = space
        @url = url
        @author = author
        @email = email
        @workspace_id = workspace_id
        @api_key = api_key

        after_initialize!
      end

      def after_initialize!
        OrbitActivities::Request.new(
          api_key: @api_key,
          workspace_id: @workspace_id,
          user_agent: "community-ruby-circle-orbit/#{CircleOrbit::VERSION}",
          action: "new_activity",
          body: construct_body.to_json
        )
      end

      def construct_body
        {
          activity: {
            activity_type: "circle:post",
            tags: ["channel:circle"],
            key: "circle-post-#{@id}",
            title: "New post in the #{@space} Space in Circle",
            description: construct_description(@post_title, @body),
            occurred_at: @created_at,
            link: @url,
            member: {
              name: @author,
              email: @email
            }
          },
          identity: {
            source: "circle",
            email: @email
          }
        }
      end

      def construct_description(title, body)
        return body if title == "" || title.nil?

        <<~HEREDOC
          ## #{title}

          #{body}
        HEREDOC
      end
    end
  end
end
