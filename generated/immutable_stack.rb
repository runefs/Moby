class ImmutableStack
         def pop() [@head, @tail]

 end
   def push(element) ImmutableStack.new(element, self)

 end
   def self.empty() @empty ||= self.new(nil, nil)

 end
   def each() yield(head)
t = tail
until (t == ImmutableStack.empty) do
  (h, t = t.pop
  yield(h))
end

 end
   def initialize(h,t) @head = h
@tail = t
self.freeze

 end

           attr_reader :head, :tail
           end