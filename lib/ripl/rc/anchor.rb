
require 'ripl'

module Ripl::Rc; end
module Ripl::Rc::Anchor
  def loop_eval(str)
    case obj_or_binding = (config[:rc_anchor] ||= []).last
      when NilClass
        super

      when Binding
        @binding = obj_or_binding
        super

      else
        obj_or_binding.instance_eval(str, "(#{@name})", @line)
    end
  end

  def prompt
    if kind_of?(Ripl::Rc::Color) &&
       obj_or_binding = (config[:rc_anchor] ||= []).last

      super.sub(obj_or_binding.inspect, format_result(obj_or_binding))
    else
      super
    end
  end

  module Imp
    def anchor obj_or_binding
      if Ripl.config[:rc_init].nil?
        Ripl::Runner.load_rc(Ripl.config[:riplrc])
        Ripl.config[:rc_init] = true
      end

      (Ripl.config[:rc_anchor] ||= []) << obj_or_binding
      Ripl::Shell.create(Ripl.config.merge(
        :name   => obj_or_binding.inspect,
        :prompt => obj_or_binding.inspect              +
                   "(#{Ripl.config[:rc_anchor].size})" +
                   Ripl.config[:prompt])).loop
      Ripl.config[:rc_anchor].pop
    end
  end
end

Ripl::Shell.include(Ripl::Rc::Anchor)

Ripl.extend(Ripl::Rc::Anchor::Imp)
Ripl.config[:prompt] ||= Ripl::Shell::OPTIONS[:prompt]