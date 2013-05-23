require 'test/unit'
require_relative 'test_helper'

class MaroonInternal

end
#Context::generate_files_in('.')
class ContextTest < Test::Unit::TestCase

  def test_role_method_call
    name = :MyContextRoleMethodCall
    role_name = :rol

    c=Context.define name do
      role role_name do
        def rolem(x, y)
          x+y
        end
      end
      def add(x,y)
        rol.rolem x,y
      end
    end

    assert_equal(7, MyContextRoleMethodCall.new.send(:self_rol_rolem, 3, 4))
    assert_equal(7, MyContextRoleMethodCall.new.add(3, 4))
  end

  def xtest_simple
    name = :MyContextSimple
    role_name = :r
    Context.define name do
      role role_name do
      end
    end
    assert(Kernel::const_defined? name)
  end

  def xtest_bind
    name = :MyContextBind

    c= Context.define name do
      role :role_name do
        def sum
          @sum += role_name
        end
      end
      def inter
        @sum = 0
        [1,2].each {|p|
          bind :p=>:role_name
          role_name.sum()
        }
        @sum
      end
    end
    assert(Kernel::const_defined? name)
    assert_equal(3, MyContextBind.new.inter)
  end

  def xtest_role_method
    name = :MyContext
    role_name = :rol
    Context.define name do
      role role_name do
        def rolem
          0+1
        end
      end
    end
    assert_equal(1, MyContext.new.send(:self_rol_rolem))
  end

  def xtest_role_method_args
    name = :MyContextArgs
    role_name = :rol
    Context.define name do
      role role_name do
        def rolem(x, y)
          x+y
        end
      end
    end
    assert_equal(7, MyContextArgs.new.send(:self_rol_rolem, 3, 4))
  end

  def xtest_role_method_splat
    name = :MyContextSplat
    role_name = :rol
    Context.define name do
      role role_name do
        def rolem(x, *args)
          x+(args[0])
        end
      end
    end
    assert_equal(7, MyContextSplat.new.send(:self_rol_rolem, 3, 4))
  end

  def xtest_role_method_block
    name = :MyContextBlock
    role_name = :rol
    c= Context.define name do
      role :num do
        def next
          num + 3
        end
      end

      role role_name do
        def rolem(*args, &b)
          res = 0
          args.each { |x|
            bind :x=>:num
            res = b.call res, num.next
          }
          res
        end
      end
    end
    assert_equal(9, MyContextBlock.new.send(:self_rol_rolem, 3, 4) { |x, res| res + x })
  end

  def xtest_class_method_block
    name = :MyContextClass
    role_name = :rol
    Context.define name do
      role :dummy do end
      role role_name do
        def rolem(*args, &b)
          res = 0
          args.each { |x|
            res = b.call res, x
          }
          res
        end
      end

      def self.mul(x, y)
        x*y
      end

      def power(x, y)
        x**y
      end

      def self.pow(x,y)
        x**y
      end
    end
    ctx = MyContextClass.new


    assert_equal(8, ctx.power(2, 3))
    assert_equal(16, MyContextClass::pow(2, 4))
    assert_equal(12, MyContextClass::mul(3, 4))
    assert_equal(7, ctx.send(:self_rol_rolem, 3, 4) { |x, res| res + x })
  end

end
