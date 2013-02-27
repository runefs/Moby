require 'sourcify'
require 'sorcerer'

module SourceCleaner
 private

  #cleans up the string for further processing and separates arguments from body
  def block2source(method_name, &block)
    source = block.to_sexp
    raise 'unknown format' unless source[0] == :iter or source.length != 4
    args = get_args source[2]
    body = source[3]
    return args, body
  end

  def get_args(sexp)
    return nil unless sexp
    return sexp[1] if sexp[0] == :lasgn
    sexp = sexp[1][1..-1] # array or arguments
    args = []
    sexp.each { |e|
      args << e[1]
    }
    args.join(',')
  end

 def lambda2method (method_name, method)
    arguments, body  = method.arguments, method.body
    transform_ast body
    block = Ruby2Ruby.new.process(body)
    args = "(#{arguments})" if arguments
    "\ndef #{method_name} #{args}\n#{block} end\n"
 end
end
