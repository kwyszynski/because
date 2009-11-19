require 'logger'

class Because
  def self.of(reason, &block)
    arr = (Thread.current[:because] ||= []) << reason
    begin
      block.call
    ensure
      arr.slice!(arr.length - 1)
    end
  end
end

Logger.class_eval do  
  [:debug, :info, :warn, :error, :fatal].each do |level|
    
    alias_method "#{level}_without_because".to_sym, level
    
    define_method(level) do |*args, &block|
      progname = args.slice!(0)
      because_arr = Thread.current[:because]
      
      if progname && !block_given? && !because_arr.nil?
        because_arr.reverse.each { |it| progname << ", because #{it}" }
      end
      
      send "#{level}_without_because".to_sym, progname, &block
    end
  end
end