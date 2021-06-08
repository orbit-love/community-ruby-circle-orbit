# frozen_string_literal: true

require "spec_helper"

RSpec.describe CircleOrbit::Utils do
  describe "#sanitize_body" do
    it "removes HTML tags" do
      body = "<html><body><p>something</p></body></html>"

      expect(described_class.sanitize_body(body)).to eql("something")
    end

    it "strips new line tags and adds white spaces" do
      body = "\n\nsomething"

      expect(described_class.sanitize_body(body)).to eql("  something")
    end

    it "does not raise an exception if there are no new line tags in the body" do
      body = "something"

      expect(described_class.sanitize_body(body)).to eql("something")
    end
  end
end
