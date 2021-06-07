# frozen_string_literal: true

require "spec_helper"

RSpec.describe CircleOrbit::Interactions::Post do
    let(:subject) do
        CircleOrbit::Interactions::Post.new(
            post_title: "Test Title",
            body: "A post body",
            created_at: "2021-06-04T07:16:04.000Z",
            id: "1234",
            space: "spaced",
            url: "https://orbit.circle.so",
            author: "Ben Greenberg",
            email: "devrel@orbit.love",
            workspace_id: "1234",
            api_key: "12345"
        )
    end

    describe "#call" do
        context "when the type is a Post" do
            it "returns a Post Object" do
                stub_request(:post, "https://app.orbit.love/api/v1/1234/activities")
                .with(
                  headers: { 'Authorization' => "Bearer 12345", 'Content-Type' => 'application/json' },
                  body: "{\"activity\":{\"activity_type\":\"circle:post\",\"tags\":[\"channel:circle\"],\"key\":\"circle-post-1234\",\"title\":\"New post in the spaced Space in Circle\",\"description\":\"## Test Title\\n\\nA post body\\n\",\"occurred_at\":\"2021-06-04T07:16:04.000Z\",\"link\":\"https://orbit.circle.so\",\"member\":{\"name\":\"Ben Greenberg\",\"email\":\"devrel@orbit.love\"}},\"identity\":{\"source\":\"circle\",\"email\":\"devrel@orbit.love\"}}"
                )
                .to_return(
                  status: 200,
                  body: {
                    response: {
                      code: 'SUCCESS'
                    }
                  }.to_json.to_s
                )
      
              content = subject.construct_body
      
              expect(content[:activity][:key]).to eql("circle-post-1234")                
            end
        end
    end
end