module Timecop::TestHelpers
  def on(*args, &block)
    time = if args.count > 1
             Time.now.change(month: args[0], day: args[1])
           else
             args[0]
           end
    Timecop.travel(time, &block)
  end
end
