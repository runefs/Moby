
context :MethodCall, :rewrite_call? do
  role :interpretation_context do
    contracts do
      self.contracts || {}
    end
    roles do
      self.roles || {}
    end
    role_aliases do
      self.role_aliases || {}
    end
  end

  role :method do
    call_in_block? do
      @in_block unless @in_block == nil
      (@in_block = (method && method[0] == :lvar))
    end

    get_role_definition do
      is_call_expression = method && method[0] == :call
      self_is_instance_expression = (is_call_expression && !method[1])
      role_name = nil
      role_name = method[2] if self_is_instance_expression
      if (not self_is_instance_expression) and method[1]
        role_name = method[1][2] if method[1][1] == nil and method[1][0] == :call #call role field is instance
        role_name = interpretation_context.role_aliases[method[1][1]] if method[1][0] == :lvar #local var potentially bound
      end
      role = role_name ? interpretation_context.roles[role_name] : nil
      [role , (role ? role_name : nil)]
    end

    role_method_call? do |method_name|

      return nil,nil unless method

      role,role_name = method.get_role_definition #is it a call to a role getter

      in_block = method.call_in_block?
      role_name = interpretation_context.role_aliases[role_name] if in_block
      is_role_method = role && role.has_key?(method_name)

      return role_name, is_role_method
    end
  end

  rewrite_call? do
    method_name = method[2]
    if method[0] == :call
      role_name, is_role_method = method.role_method_call? method_name
      if is_role_method #role_name only returned if it's a role method call
        method[1] = nil #remove call to attribute
        method[2] = "self_#{role_name}_#{method_name}".to_sym
      else # it's an instance method invocation
        (interpretation_context.contracts[role_name] ||= []) << method_name
      end
    else
      p "method[0] was #{method[0]}"
    end
  end
  initialize do |method, interpretation_context|
    raise "No method supplied" unless method

    @method = method
    @interpretation_context = interpretation_context
  end
end