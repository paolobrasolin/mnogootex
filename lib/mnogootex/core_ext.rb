# frozen_string_literal: true

class Object
  def if
    tap { |object| break unless yield object }
  end

  def unless
    tap { |object| break if yield object }
  end
end
