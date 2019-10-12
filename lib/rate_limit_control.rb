require "rate_limit_control/version"

class RateLimitControl
  attr_reader :action, :allowed_requests, :session_counter, :storage, :timeout

  def initialize(configs)
    @action = "locked_#{configs[:action]}_#{configs[:id]}"
    @allowed_requests = configs[:allowed_requests]
    @session_counter = "#{configs[:action]}_#{configs[:id]}"
    @storage = configs[:storage]
    @timeout = configs[:timeout]
    call
    yield
  end

  private

  def call
    if session_counter_created?
      increment_session_counter
      set_action_as_blocked if actions_exceed_the_total_of_allowed?
    else
      create_session_counter
    end

    action_blocked_log
    while action_blocked?; end
    action_executed_log
  end

  def session_counter_created?
    storage.get(session_counter) != nil
  end

  def increment_session_counter
    storage.incr(session_counter)
  end

  def set_action_as_blocked
    storage.set(action, true)
    storage.expire(action, action_timeout)
  end

  def actions_exceed_the_total_of_allowed?
    total_of_actions_executed >= allowed_requests
  end

  def create_session_counter
    storage.set(session_counter, 0)
    storage.expire(session_counter, timeout)
  end

  def action_blocked_log
    puts "Action is blocked" if action_blocked?
  end

  def action_blocked?
    storage.get(action) != nil
  end

  def action_executed_log
    puts action
    puts "Request executed at #{Time.now.to_s}"
  end

  def action_timeout
    actions_ahead = (total_of_actions_executed / allowed_requests) || 1
    actions_ahead * timeout
  end

  def total_of_actions_executed
    storage.get(session_counter).to_i
  end
end
