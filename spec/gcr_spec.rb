require_relative "./spec_helper"

describe GCR do
  subject { described_class }

  describe "#cassette_dir" do
    it "raises if not configured" do
      subject.cassette_dir = nil

      expect {
        subject.cassette_dir
      }.to raise_exception(GCR::ConfigError)
    end

    it "returns cassette dir if configured" do
      expect(subject.cassette_dir).to eq(TMP_DIR)
    end
  end

  describe "#with_cassette" do
    it "records" do
      # Record
      subject.with_cassette("foo") do
        expect(Greetings::Client.hello("bob")).to eq("hello bob")
        expect(Greetings::Client.hello("sue")).to eq("hello sue")
        expect(Greetings::Client.hello("sue")).to eq("hello sue")
      end

      Greetings::Server.stop

      # Play
      subject.with_cassette("foo") do
        expect(Greetings::Client.hello("bob")).to eq("hello bob")
        expect(Greetings::Client.hello("sue")).to eq("hello sue")
        expect(Greetings::Client.hello("sue")).to eq("hello sue")
        expect {
          Greetings::Client.hello("fred")
        }.to raise_exception(GCR::NoRecording)
      end
    end
  end
end
