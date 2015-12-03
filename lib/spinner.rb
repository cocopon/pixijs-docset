class Spinner
  def initialize()
    @state = 0
  end

  def init(opt_message = '')
    @state = 0
    print("#{opt_message}|")
  end

  def finish(opt_message = '')
    print("\b#{opt_message}\n")
  end

  def spin()
    case @state
    when 0
      print("\b/")
    when 1
      print("\b-")
    when 2
      print("\b\\")
    when 3
      print("\b|")
    when 4
      print("\b/")
    when 5
      print("\b-")
    when 6
      print("\b\\")
    when 7
      print("\b|")
    end
    @state = (@state + 1) % 8

    STDOUT.flush()
  end
end
