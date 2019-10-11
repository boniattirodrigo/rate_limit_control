RSpec.describe RateLimitControl do
  it "has a version number" do
    expect(RateLimitControl::VERSION).not_to be nil
  end

  after { Redis.current.flushdb }

  let(:action_config) do
    {
      action: 'rate_limit_example',
      id: 'foobar',
      allowed_requests: 3,
      storage: Redis.new,
      timeout: 10
    }
  end

  let(:action) { "Any action you would like to execute" }

  context "when the actions do not exceed the total allowed" do
    before { expect_any_instance_of(described_class).not_to receive(:set_action_as_blocked) }

    it "runs the requested actions" do
      3.times { described_class.new(action_config) { action } }
    end
  end

  context "when the actions exceed the total allowed" do
    before { expect_any_instance_of(described_class).to receive(:set_action_as_blocked).once }

    it 'sets the action as blocked' do
      4.times { described_class.new(action_config) { action } }
    end
  end

  context "when an action stack is full" do
    let(:action_config_2) do
      {
        action: 'rate_limit_example_2',
        id: 'foobar',
        allowed_requests: 3,
        storage: Redis.new,
        timeout: 10
      }
    end

    before do
      expect_any_instance_of(described_class).not_to receive(:set_action_as_blocked)

      3.times { described_class.new(action_config) { action } }
    end

    it "does not block other actions" do
      3.times { described_class.new(action_config_2) { action } }
    end
  end
end
