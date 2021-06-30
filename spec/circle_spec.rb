# frozen_string_literal: true

require "spec_helper"

RSpec.describe CircleOrbit::Circle do
  let(:subject) do
    CircleOrbit::Circle.new(
      orbit_api_key: "12345",
      orbit_workspace: "test",
      circle_api_key: "abc123",
      circle_url: "https://orbit.circle.so",
      circle_community_id: "123",
      historical_import: false
    )
  end

  describe "#process_posts" do
    context "with historical import set to false and no newer items than the latest activity for the type in Orbit" do
      it "posts no new posts to the Orbit workspace from Circle" do
        stub_request(:get, "https://orbit.circle.so/api/v1/posts?community_id=123&space_id=1234")
          .with(
            headers: {
              "Authorization" => "Token abc123"
            }
          )
          .to_return(status: 200)

        stub_request(:get, "https://app.orbit.love/api/v1/test/activities?activity_type=custom:circle:post&direction=DESC&items=10")
          .with(
            headers: {
              "Accept" => "application/json",
              "Authorization" => "Bearer 12345",
              "User-Agent" => "community-ruby-circle-orbit/#{CircleOrbit::VERSION}"
            }
          )
          .to_return(
            status: 200,
            body: {
              data: [
                {
                  id: "6",
                  type: "spec_activity",
                  attributes: {
                    action: "spec_action",
                    created_at: "2021-06-23T16:03:02.052Z",
                    key: "spec_activity_key#1",
                    occurred_at: "2021-04-01T16:03:02.050Z",
                    type: "SpecActivity",
                    tags: "[\"spec-tag-1\"]",
                    orbit_url: "https://localhost:3000/test/activities/6",
                    weight: "1.0"
                  },
                  relationships: {
                    activity_type: {
                      data: {
                        id: "20",
                        type: "activity_type"
                      }
                    }
                  },
                  member: {
                    data: {
                      id: "3",
                      type: "member"
                    }
                  }
                }
              ]
            }.to_json.to_s,
            headers: {}
          )

        allow(subject).to receive(:get_spaces).and_return([{ "id" => "1234" }])
        allow(subject).to receive(:get_posts).and_return(post_stub)

        expect(subject.process_posts).to eq("Sent 0 new posts to your Orbit workspace")
      end
    end
  end

  context "with historical import set to false and newer items than the latest activity for the type in Orbit" do
    it "posts the newer items to the Orbit workspace from Circle" do
      stub_request(:get, "https://orbit.circle.so/api/v1/posts?community_id=123&space_id=1234")
        .with(
          headers: {
            "Authorization" => "Token abc123"
          }
        )
        .to_return(status: 200)

      stub_request(:get, "https://app.orbit.love/api/v1/test/activities?activity_type=custom:circle:post&direction=DESC&items=10")
        .with(
          headers: {
            "Accept" => "application/json",
            "Authorization" => "Bearer 12345",
            "User-Agent" => "community-ruby-circle-orbit/#{CircleOrbit::VERSION}"
          }
        )
        .to_return(
          status: 200,
          body: {
            data: [
              {
                id: "6",
                type: "spec_activity",
                attributes: {
                  action: "spec_action",
                  created_at: "2021-06-01T16:03:02.052Z",
                  key: "spec_activity_key#1",
                  occurred_at: "2021-04-01T16:03:02.050Z",
                  type: "SpecActivity",
                  tags: "[\"spec-tag-1\"]",
                  orbit_url: "https://localhost:3000/test/activities/6",
                  weight: "1.0"
                },
                relationships: {
                  activity_type: {
                    data: {
                      id: "20",
                      type: "activity_type"
                    }
                  }
                },
                member: {
                  data: {
                    id: "3",
                    type: "member"
                  }
                }
              }
            ]
          }.to_json.to_s,
          headers: {}
        )

      stub_request(:post, "https://app.orbit.love/api/v1/test/activities")
        .with(
          body: "{\"activity\":{\"activity_type\":\"circle:post\",\"tags\":[\"channel:circle\"],\"key\":\"circle-post-741346\",\"title\":\"New post in the Introductions Space in Circle\",\"description\":\"## Sample Name\\n\\n\\n\",\"occurred_at\":null,\"link\":\"https://sample.circle.so/c/introductions/sample-name\",\"member\":{\"name\":\"Ploni Almoni\",\"email\":\"noemail@sample.com\"}},\"identity\":{\"source\":\"circle\",\"email\":\"noemail@sample.com\"}}",
          headers: {
            "Accept" => "application/json",
            "Authorization" => "Bearer 12345",
            "Content-Type" => "application/json",
            "User-Agent" => "community-ruby-circle-orbit/#{CircleOrbit::VERSION}"
          }
        )
        .to_return(status: 200, body: {
          response: {
            code: "SUCCESS"
          }
        }.to_json.to_s, headers: {})

      allow(subject).to receive(:get_spaces).and_return([{ "id" => "1234" }])
      allow(subject).to receive(:get_posts).and_return(post_stub)

      expect(subject.process_posts).to eq("Sent 1 new posts to your Orbit workspace")
    end
  end

  context "with historical import set to true" do
    it "posts all items to the Orbit workspace from Circle" do
      client = CircleOrbit::Circle.new(
        orbit_api_key: "12345",
        orbit_workspace: "test",
        circle_api_key: "abc123",
        circle_url: "https://orbit.circle.so",
        circle_community_id: "123",
        historical_import: true
      )

      stub_request(:get, "https://orbit.circle.so/api/v1/posts?community_id=123&space_id=1234")
        .with(
          headers: {
            "Authorization" => "Token abc123"
          }
        )
        .to_return(status: 200)

      stub_request(:get, "https://app.orbit.love/api/v1/test/activities?activity_type=custom:circle:post&direction=DESC&items=10")
        .with(
          headers: {
            "Accept" => "application/json",
            "Authorization" => "Bearer 12345",
            "User-Agent" => "community-ruby-circle-orbit/#{CircleOrbit::VERSION}"
          }
        )
        .to_return(
          status: 200,
          body: {
            data: [
              {
                id: "6",
                type: "spec_activity",
                attributes: {
                  action: "spec_action",
                  created_at: "2021-06-01T16:03:02.052Z",
                  key: "spec_activity_key#1",
                  occurred_at: "2021-06-01T16:03:02.050Z",
                  type: "SpecActivity",
                  tags: "[\"spec-tag-1\"]",
                  orbit_url: "https://localhost:3000/test/activities/6",
                  weight: "1.0"
                },
                relationships: {
                  activity_type: {
                    data: {
                      id: "20",
                      type: "activity_type"
                    }
                  }
                },
                member: {
                  data: {
                    id: "3",
                    type: "member"
                  }
                }
              }
            ]
          }.to_json.to_s,
          headers: {}
        )

      stub_request(:post, "https://app.orbit.love/api/v1/test/activities")
        .with(
          body: "{\"activity\":{\"activity_type\":\"circle:post\",\"tags\":[\"channel:circle\"],\"key\":\"circle-post-741346\",\"title\":\"New post in the Introductions Space in Circle\",\"description\":\"## Sample Name Post 2\\n\\n\\n\",\"occurred_at\":null,\"link\":\"https://sample.circle.so/c/introductions/sample-name-post-2\",\"member\":{\"name\":\"Ploni Almoni\",\"email\":\"noemail@sample.com\"}},\"identity\":{\"source\":\"circle\",\"email\":\"noemail@sample.com\"}}",
          headers: {
            "Accept" => "application/json",
            "Authorization" => "Bearer 12345",
            "Content-Type" => "application/json",
            "User-Agent" => "community-ruby-circle-orbit/#{CircleOrbit::VERSION}"
          }
        )
        .to_return(status: 200, body: {
          response: {
            code: "SUCCESS"
          }
        }.to_json.to_s, headers: {})

      stub_request(:post, "https://app.orbit.love/api/v1/test/activities")
        .with(
          body: "{\"activity\":{\"activity_type\":\"circle:post\",\"tags\":[\"channel:circle\"],\"key\":\"circle-post-741346\",\"title\":\"New post in the Introductions Space in Circle\",\"description\":\"## Sample Name\\n\\n\\n\",\"occurred_at\":null,\"link\":\"https://sample.circle.so/c/introductions/sample-name\",\"member\":{\"name\":\"Ploni Almoni\",\"email\":\"noemail@sample.com\"}},\"identity\":{\"source\":\"circle\",\"email\":\"noemail@sample.com\"}}",
          headers: {
            "Accept" => "application/json",
            "Authorization" => "Bearer 12345",
            "Content-Type" => "application/json",
            "User-Agent" => "community-ruby-circle-orbit/#{CircleOrbit::VERSION}"
          }
        )
        .to_return(status: 200, body: {
          response: {
            code: "SUCCESS"
          }
        }.to_json.to_s, headers: {})

      allow(client).to receive(:get_spaces).and_return([{ "id" => "1234" }])
      allow(client).to receive(:get_posts).and_return(posts_stub)

      expect(client.process_posts).to eq("Sent 2 new posts to your Orbit workspace")
    end
  end

  describe "#process_comments" do
    context "with historical import set to false and no newer items than the latest activity for the type in Orbit" do
      it "posts no new comments to the Orbit workspace from Circle" do
        stub_request(:get, "https://orbit.circle.so/api/v1/comments?community_id=123")
          .with(
            headers: {
              "Authorization" => "Token abc123"
            }
          )
          .to_return(status: 200)

        stub_request(:get, "https://app.orbit.love/api/v1/test/activities?activity_type=custom:circle:comment&direction=DESC&items=10")
          .with(
            headers: {
              "Accept" => "application/json",
              "Authorization" => "Bearer 12345",
              "User-Agent" => "community-ruby-circle-orbit/#{CircleOrbit::VERSION}"
            }
          )
          .to_return(
            status: 200,
            body: {
              data: [
                {
                  id: "6",
                  type: "spec_activity",
                  attributes: {
                    action: "spec_action",
                    created_at: "2021-06-23T16:03:02.052Z",
                    key: "spec_activity_key#1",
                    occurred_at: "2021-04-01T16:03:02.050Z",
                    type: "SpecActivity",
                    tags: "[\"spec-tag-1\"]",
                    orbit_url: "https://localhost:3000/test/activities/6",
                    weight: "1.0"
                  },
                  relationships: {
                    activity_type: {
                      data: {
                        id: "20",
                        type: "activity_type"
                      }
                    }
                  },
                  member: {
                    data: {
                      id: "3",
                      type: "member"
                    }
                  }
                }
              ]
            }.to_json.to_s,
            headers: {}
          )

        allow(subject).to receive(:get_comments).and_return(comment_stub)

        expect(subject.process_comments).to eq("Sent 0 new comments to your Orbit workspace")
      end
    end

    context "with historical import set to false and newer items than the latest activity for the type in Orbit" do
      it "posts the newer items to the Orbit workspace from Circle" do
        stub_request(:get, "https://orbit.circle.so/api/v1/comments?community_id=123")
          .with(
            headers: {
              "Authorization" => "Token abc123"
            }
          )
          .to_return(status: 200)

        stub_request(:get, "https://app.orbit.love/api/v1/test/activities?activity_type=custom:circle:comment&direction=DESC&items=10")
          .with(
            headers: {
              "Accept" => "application/json",
              "Authorization" => "Bearer 12345",
              "User-Agent" => "community-ruby-circle-orbit/#{CircleOrbit::VERSION}"
            }
          )
          .to_return(
            status: 200,
            body: {
              data: [
                {
                  id: "6",
                  type: "spec_activity",
                  attributes: {
                    action: "spec_action",
                    created_at: "2021-06-01T16:03:02.052Z",
                    key: "spec_activity_key#1",
                    occurred_at: "2021-06-01T16:03:02.050Z",
                    type: "SpecActivity",
                    tags: "[\"spec-tag-1\"]",
                    orbit_url: "https://localhost:3000/test/activities/6",
                    weight: "1.0"
                  },
                  relationships: {
                    activity_type: {
                      data: {
                        id: "20",
                        type: "activity_type"
                      }
                    }
                  },
                  member: {
                    data: {
                      id: "3",
                      type: "member"
                    }
                  }
                }
              ]
            }.to_json.to_s,
            headers: {}
          )

        stub_request(:post, "https://app.orbit.love/api/v1/test/activities")
          .with(
            body: "{\"activity\":{\"activity_type\":\"circle:comment\",\"tags\":[\"channel:circle\"],\"key\":\"circle-comment-456789\",\"title\":\"New comment in the Intros Space in Circle\",\"description\":\"### Comment on Post: *Sample Name*\\n\\nSample Body\\n\",\"occurred_at\":\"2021-06-04T12:29:31.000Z\",\"link\":\"https://example.com/post\",\"member\":{\"name\":\"Ploni Almoni\",\"email\":\"sample@example.com\"}},\"identity\":{\"source\":\"circle\",\"email\":\"sample@example.com\"}}",
            headers: {
              "Accept" => "application/json",
              "Authorization" => "Bearer 12345",
              "Content-Type" => "application/json",
              "User-Agent" => "community-ruby-circle-orbit/#{CircleOrbit::VERSION}"
            }
          )
          .to_return(status: 200, body: {
            response: {
              code: "SUCCESS"
            }
          }.to_json.to_s, headers: {})

        allow(subject).to receive(:get_comments).and_return(comment_stub)

        expect(subject.process_comments).to eq("Sent 1 new comments to your Orbit workspace")
      end
    end

    context "with historical import set to true" do
      it "posts all items to the Orbit workspace from Circle" do
        client = CircleOrbit::Circle.new(
          orbit_api_key: "12345",
          orbit_workspace: "test",
          circle_api_key: "abc123",
          circle_url: "https://orbit.circle.so",
          circle_community_id: "123",
          historical_import: true
        )

        stub_request(:get, "https://orbit.circle.so/api/v1/comments?community_id=123")
          .with(
            headers: {
              "Authorization" => "Token abc123"
            }
          )
          .to_return(status: 200)

        stub_request(:get, "https://app.orbit.love/api/v1/test/activities?activity_type=custom:circle:comment&direction=DESC&items=10")
          .with(
            headers: {
              "Accept" => "application/json",
              "Authorization" => "Bearer 12345",
              "User-Agent" => "community-ruby-circle-orbit/#{CircleOrbit::VERSION}"
            }
          )
          .to_return(
            status: 200,
            body: {
              data: [
                {
                  id: "6",
                  type: "spec_activity",
                  attributes: {
                    action: "spec_action",
                    created_at: "2021-06-01T16:03:02.052Z",
                    key: "spec_activity_key#1",
                    occurred_at: "2021-06-01T16:03:02.050Z",
                    type: "SpecActivity",
                    tags: "[\"spec-tag-1\"]",
                    orbit_url: "https://localhost:3000/test/activities/6",
                    weight: "1.0"
                  },
                  relationships: {
                    activity_type: {
                      data: {
                        id: "20",
                        type: "activity_type"
                      }
                    }
                  },
                  member: {
                    data: {
                      id: "3",
                      type: "member"
                    }
                  }
                }
              ]
            }.to_json.to_s,
            headers: {}
          )

        stub_request(:post, "https://app.orbit.love/api/v1/test/activities")
          .with(
            body: "{\"activity\":{\"activity_type\":\"circle:comment\",\"tags\":[\"channel:circle\"],\"key\":\"circle-comment-567890\",\"title\":\"New comment in the Intros Space in Circle\",\"description\":\"### Comment on Post: *Sample Name*\\n\\nSample Body\\n\",\"occurred_at\":\"2021-05-04T12:29:31.000Z\",\"link\":\"https://example.com/post\",\"member\":{\"name\":\"Ploni Almoni\",\"email\":\"sample@example.com\"}},\"identity\":{\"source\":\"circle\",\"email\":\"sample@example.com\"}}",
            headers: {
              "Accept" => "application/json",
              "Authorization" => "Bearer 12345",
              "Content-Type" => "application/json",
              "User-Agent" => "community-ruby-circle-orbit/#{CircleOrbit::VERSION}"
            }
          )
          .to_return(status: 200, body: {
            response: {
              code: "SUCCESS"
            }
          }.to_json.to_s, headers: {})

        stub_request(:post, "https://app.orbit.love/api/v1/test/activities")
          .with(
            body: "{\"activity\":{\"activity_type\":\"circle:comment\",\"tags\":[\"channel:circle\"],\"key\":\"circle-comment-456789\",\"title\":\"New comment in the Intros Space in Circle\",\"description\":\"### Comment on Post: *Sample Name*\\n\\nSample Body\\n\",\"occurred_at\":\"2021-06-04T12:29:31.000Z\",\"link\":\"https://example.com/post\",\"member\":{\"name\":\"Ploni Almoni\",\"email\":\"sample@example.com\"}},\"identity\":{\"source\":\"circle\",\"email\":\"sample@example.com\"}}",
            headers: {
              "Accept" => "application/json",
              "Authorization" => "Bearer 12345",
              "Content-Type" => "application/json",
              "User-Agent" => "community-ruby-circle-orbit/#{CircleOrbit::VERSION}"
            }
          )
          .to_return(status: 200, body: {
            response: {
              code: "SUCCESS"
            }
          }.to_json.to_s, headers: {})

        allow(client).to receive(:get_comments).and_return(comments_stub)

        expect(client.process_comments).to eq("Sent 2 new comments to your Orbit workspace")
      end
    end
  end

  def comment_stub
    [
      {
        "id" => 456_789,
        "body" => {
          "id" => 345_678,
          "name" => "body",
          "body" => "<div><!--block-->Sample Body</div>",
          "record_type" => "Comment",
          "record_id" => 456_789,
          "created_at" => "2021-06-04T12:29:31.000Z",
          "updated_at" => "2021-06-04T12:29:31.000Z"
        },
        "user_id" => 123_456,
        "user_name" => "Ploni Almoni",
        "user_email" => "sample@example.com",
        "likes_count" => 0,
        "user_avatar_url" => "https://example.com/avatar.png",
        "url" => "https://example.com/post",
        "user_posts_count" => 7,
        "user_topics_count" => 7,
        "user_likes_count" => 1,
        "user_comments_count" => 2,
        "post_id" => 123,
        "post_name" => "Sample Name",
        "space_id" => 345_890,
        "space_slug" => "intros",
        "community_id" => 4567,
        "parent_comment_id" => nil,
        "topic_id" => 123,
        "topic_name" => "Sample Name"
      }
    ]
  end

  def comments_stub
    [
      {
        "id" => 456_789,
        "body" => {
          "id" => 345_678,
          "name" => "body",
          "body" => "<div><!--block-->Sample Body</div>",
          "record_type" => "Comment",
          "record_id" => 456_789,
          "created_at" => "2021-06-04T12:29:31.000Z",
          "updated_at" => "2021-06-04T12:29:31.000Z"
        },
        "user_id" => 123_456,
        "user_name" => "Ploni Almoni",
        "user_email" => "sample@example.com",
        "likes_count" => 0,
        "user_avatar_url" => "https://example.com/avatar.png",
        "url" => "https://example.com/post",
        "user_posts_count" => 7,
        "user_topics_count" => 7,
        "user_likes_count" => 1,
        "user_comments_count" => 2,
        "post_id" => 123,
        "post_name" => "Sample Name",
        "space_id" => 345_890,
        "space_slug" => "intros",
        "community_id" => 4567,
        "parent_comment_id" => nil,
        "topic_id" => 123,
        "topic_name" => "Sample Name"
      },
      {
        "id" => 567_890,
        "body" => {
          "id" => 345_678,
          "name" => "body",
          "body" => "<div><!--block-->Sample Body</div>",
          "record_type" => "Comment",
          "record_id" => 567_890,
          "created_at" => "2021-05-04T12:29:31.000Z",
          "updated_at" => "2021-05-04T12:29:31.000Z"
        },
        "user_id" => 123_456,
        "user_name" => "Ploni Almoni",
        "user_email" => "sample@example.com",
        "likes_count" => 0,
        "user_avatar_url" => "https://example.com/avatar.png",
        "url" => "https://example.com/post",
        "user_posts_count" => 7,
        "user_topics_count" => 7,
        "user_likes_count" => 1,
        "user_comments_count" => 2,
        "post_id" => 123,
        "post_name" => "Sample Name",
        "space_id" => 345_890,
        "space_slug" => "intros",
        "community_id" => 4567,
        "parent_comment_id" => nil,
        "topic_id" => 123,
        "topic_name" => "Sample Name"
      }
    ]
  end

  def post_stub
    [
      {
        "id" => 741_346,
        "name" => "Sample Name",
        "body" => {
          "id" => nil,
          "name" => "body",
          "body" => nil,
          "record_type" => "Post",
          "record_id" => 741_346,
          "created_at" => nil,
          "updated_at" => nil
        },
        "slug" => "sample-name",
        "url" => "https://sample.circle.so/c/introductions/sample-name",
        "space_name" => "Introductions",
        "space_slug" => "introductions",
        "space_id" => 114_489,
        "user_id" => 1_090_928,
        "user_email" => "noemail@sample.com",
        "user_name" => "Ploni Almoni",
        "comments_count" => 0,
        "user_posts_count" => 7,
        "user_topics_count" => 7,
        "user_likes_count" => 1,
        "user_comments_count" => 2,
        "community_id" => 15_853,
        "hide_meta_info" => false,
        "user_avatar_url" => "https://example.com/avatar.png",
        "created_at" => "2021-06-08T14:57:33.736Z",
        "updated_at" => "2021-06-08T14:57:33.736Z",
        "custom_html" => nil
      }
    ]
  end

  def posts_stub
    [
      {
        "id" => 741_346,
        "name" => "Sample Name",
        "body" => {
          "id" => nil,
          "name" => "body",
          "body" => nil,
          "record_type" => "Post",
          "record_id" => 741_346,
          "created_at" => nil,
          "updated_at" => nil
        },
        "slug" => "sample-name",
        "url" => "https://sample.circle.so/c/introductions/sample-name",
        "space_name" => "Introductions",
        "space_slug" => "introductions",
        "space_id" => 114_489,
        "user_id" => 1_090_928,
        "user_email" => "noemail@sample.com",
        "user_name" => "Ploni Almoni",
        "comments_count" => 0,
        "user_posts_count" => 7,
        "user_topics_count" => 7,
        "user_likes_count" => 1,
        "user_comments_count" => 2,
        "community_id" => 15_853,
        "hide_meta_info" => false,
        "user_avatar_url" => "https://example.com/avatar.png",
        "created_at" => "2021-06-08T14:57:33.736Z",
        "updated_at" => "2021-06-08T14:57:33.736Z",
        "custom_html" => nil
      },
      {
        "id" => 1_234_567_890,
        "name" => "Sample Name Post 2",
        "body" => {
          "id" => nil,
          "name" => "body",
          "body" => nil,
          "record_type" => "Post",
          "record_id" => 741_346,
          "created_at" => nil,
          "updated_at" => nil
        },
        "slug" => "sample-name-post-2",
        "url" => "https://sample.circle.so/c/introductions/sample-name-post-2",
        "space_name" => "Introductions",
        "space_slug" => "introductions",
        "space_id" => 114_489,
        "user_id" => 1_090_928,
        "user_email" => "noemail@sample.com",
        "user_name" => "Ploni Almoni",
        "comments_count" => 0,
        "user_posts_count" => 7,
        "user_topics_count" => 7,
        "user_likes_count" => 1,
        "user_comments_count" => 2,
        "community_id" => 15_853,
        "hide_meta_info" => false,
        "user_avatar_url" => "https://example.com/avatar.png",
        "created_at" => "2021-05-23T14:57:33.736Z",
        "updated_at" => "2021-05-23T14:57:33.736Z",
        "custom_html" => nil
      }
    ]
  end
end
