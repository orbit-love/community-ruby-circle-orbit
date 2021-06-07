# frozen_string_literal: true

require "spec_helper"

RSpec.describe CircleOrbit::Client do
    before(:all) do
        stub_request(:get, "https://orbit.circle.so/api/v1/communities").
        with(
          headers: {
            'Accept'=>'*/*',
            'Authorization'=>'Token abc123',
          }).
        to_return(
            status: 200, 
            body: "[{\"id\":12345,\"name\":\"Orbit\",\"slug\":\"orbit\",\"icon_url\":null,\"logo_url\":\"https://d2y5h3osumboay.cloudfront.net/4oligohmu5xkqkr36pf3mhvzhiay\",\"owner_id\":1234567,\"is_private\":true,\"space_ids\":[114489,114547],\"last_visited_by_current_user\":true,\"default_existing_member_space_id\":null,\"root_url\":\"orbit.circle.so\",\"display_on_switcher\":true,\"prefs\":{\"has_posts\":true,\"has_spaces\":true,\"brand_color\":\"#3D2D85\",\"has_invited_member\":true}}]", 
            headers: {}
        )
    end

    let(:subject) do
        CircleOrbit::Client.new(
        orbit_api_key: "12345",
        orbit_workspace: "test",
        circle_api_key: "abc123",
        circle_url: "https://orbit.circle.so"
        )
    end

    it "initializes with arguments passed in directly" do
        expect(subject).to be_truthy
    end

    it "initializes with credentials from environment variables" do
        allow(ENV).to receive(:[]).with("ORBIT_API_KEY").and_return("12345")
        allow(ENV).to receive(:[]).with("ORBIT_WORKSPACE").and_return("test")
        allow(ENV).to receive(:[]).with("CIRCLE_API_KEY").and_return("abc123")
        allow(ENV).to receive(:[]).with("CIRCLE_URL").and_return("https://orbit.circle.so")

        expect(CircleOrbit::Client).to be_truthy
    end

    it "removes the trailing slash on the Circle community URL" do
        stub_request(:get, "https://orbit.circle.so/api/v1/communities").
        with(
          headers: {
            'Accept'=>'*/*',
            'Authorization'=>'Token abc123',
          }).
        to_return(
            status: 200, 
            body: "[{\"id\":12345,\"name\":\"Orbit\",\"slug\":\"orbit\",\"icon_url\":null,\"logo_url\":\"https://d2y5h3osumboay.cloudfront.net/4oligohmu5xkqkr36pf3mhvzhiay\",\"owner_id\":1234567,\"is_private\":true,\"space_ids\":[114489,114547],\"last_visited_by_current_user\":true,\"default_existing_member_space_id\":null,\"root_url\":\"orbit.circle.so\",\"display_on_switcher\":true,\"prefs\":{\"has_posts\":true,\"has_spaces\":true,\"brand_color\":\"#3D2D85\",\"has_invited_member\":true}}]", 
            headers: {}
        )
        
        client = CircleOrbit::Client.new(
            orbit_api_key: "12345",
            orbit_workspace: "test",
            circle_api_key: "abc123",
            circle_url: "https://orbit.circle.so/"
        )

        expect(client.circle_url).to eql("https://orbit.circle.so")
    end
end