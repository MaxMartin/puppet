
unless defined? JRUBY_VERSION
  Process.maxgroups = 1024
end

module RDoc
  def self.caller(skip=nil)
    in_gem_wrapper = false
    Kernel.caller.reject { |call|
      in_gem_wrapper ||= call =~ /#{Regexp.escape $0}:\d+:in `load'/
    }
  end
end


require "yaml"
require "puppet/util/zaml.rb"

class Symbol
  def to_zaml(z)
    z.emit("!ruby/sym ")
    to_s.to_zaml(z)
  end
  def <=> (other)
    self.to_s <=> other.to_s
  end
end

[Object, Exception, Integer, Struct, Date, Time, Range, Regexp, Hash, Array, Float, String, FalseClass, TrueClass, Symbol, NilClass, Class].each { |cls|
  cls.class_eval do
    def to_yaml(ignored=nil)
      ZAML.dump(self)
    end
  end
}

def YAML.dump(*args)
  ZAML.dump(*args)
end

#
# Workaround for bug in MRI 1.8.7, see
#     http://redmine.ruby-lang.org/issues/show/2708
# for details
#
if RUBY_VERSION == '1.8.7'
  class NilClass
    def closed?
      true
    end
  end
end

class Object
  # The following code allows callers to make assertions that are only
  # checked when the environment variable PUPPET_ENABLE_ASSERTIONS is
  # set to a non-empty string.  For example:
  #
  #   assert_that { condition }
  #   assert_that(message) { condition }
  if ENV["PUPPET_ENABLE_ASSERTIONS"].to_s != ''
    def assert_that(message = nil)
      unless yield
        raise Exception.new("Assertion failure: #{message}")
      end
    end
  else
    def assert_that(message = nil)
    end
  end
end
