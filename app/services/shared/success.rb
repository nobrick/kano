class Shared::Success
  attr_reader :data
  def initialize(data)
    @data = data
  end

  def success?
    true
  end
end
