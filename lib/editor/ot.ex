# # NOTE: object shit becomes processes
#
# # After an operation is constructed, the user of the library can specify the
# # actions of an operation (skip/insert/delete) with these three builder
# # methods. They all return the operation for convenient chaining.
#
# # Skip over a given number of characters.
# def retain(n)
#   fail 'retain expects an integer' unless n.is_a? Integer
#
#   return self if n == 0
#
#   # this probs gotta go
#   @base_length += n
#   @target_length += n
#
#   if retain_op?(@ops.last) do
#     # The last op is a retain op => we can merge them into one op.
#     @ops[-1] += n
#   else
#     # Create a new op.
#     @ops.push(n)
#   end
#
#   return self
# end
#
#
#   # Insert a string at the current position.
#   def insert(str)
#     fail 'insert expects a string' unless str.is_a? String
#
#     return self if str == ''
#
#     @target_length += str.length
#
#     if insert_op?(ops.last)
#       # Merge insert op.
#       @ops[-1] += str
#     elsif delete_op?(ops.last)
#       # It doesn't matter when an operation is applied whether the operation
#       # is delete(3), insert("something") or insert("something"), delete(3).
#       # Here we enforce that in this case, the insert op always comes first.
#       # This makes all operations that have the same effect when applied to
#       # a document of the right length equal in respect to the `equals` method.
#       if insert_op?(ops[-2])
#         @ops[-2] += str
#       else
#         @ops.insert(-2, str)
#       end
#     else
#       @ops.push(str)
#     end
#
#     return self
#   end
#
#
#   # Delete a string at the current position.
#   def delete(n)
#     fail 'delete expects an integer or a string' unless n.is_a?(Integer) || n.is_a?(String)
#
#     n = n.length if n.is_a? String
#
#     return self if n == 0
#
#     n = -n if n > 0
#
#     @base_length -= n
#
#     if delete_op?(@ops.last) do
#       @ops[-1] += n
#     else
#       @ops.push(n)
#     end
#
#     return self
#   end
#
#   # Tests whether this operation has no effect.
#   def noop?
#     return @ops.length == 0 || (@ops.length == 1 && retain_op?(@ops[0]))
#   end
#
#
#   # Apply an operation to a string, returning a new string. Throws an error if
#  # there's a mismatch between the input string and the operation.
#  def apply(str)
#    if str.length != base_length
#      fail "The operation's base length must be equal to the string's length."
#    end
#
#    new_str = ''
#    str_index = 0
#
#    @ops.each do |op|
#      if retain_op?(op)
#        if (str_index + op) > str.length
#          fail "Operation can't retain more characters than are left in the string."
#        end
#
#        # Copy skipped part of the old string.
#        new_str += str.slice(str_index, op)
#        str_index += op
#      elsif insert_op?(op)
#        # Insert string.
#        new_str += op
#      else
#        # delete op
#        str_index -= op
#      end
#    end
#
#    if (str_index != str.length)
#      fail "The operation didn't operate on the whole string."
#    end
#
#    return new_str
#  end
#
#
#
#     # Transform takes two operations A and B that happened concurrently and
#     # produces two operations A' and B' (in an array) such that
#     # `apply(apply(S, A), B') = apply(apply(S, B), A')`. This function is the
#     # heart of OT.
#     def self.transform(operation1, operation2)
#       if (operation1.base_length != operation2.base_length)
#         fail 'Both operations have to have the same base length'
#       end
#
#       operation1prime = TextOperation.new
#       operation2prime = TextOperation.new
#
#       ops1 = operation1.ops
#       ops2 = operation2.ops
#
#       i1 = 0
#       i2 = 0
#
#       op1 = ops1[i1]
#       op2 = ops2[i2]
#
#       loop do
#         # At every iteration of the loop, the imaginary cursor that both
#         # operation1 and operation2 have that operates on the input string must
#         # have the same position in the input string.
#
#         if op1.nil? && op2.nil?
#           # end condition: both ops1 and ops2 have been processed
#           break
#         end
#
#         # next two cases: one or both ops are insert ops
#         # => insert the string in the corresponding prime operation, skip it in
#         # the other one. If both op1 and op2 are insert ops, prefer op1.
#         if insert_op?(op1)
#           operation1prime.insert(op1)
#           operation2prime.retain(op1.length)
#           op1 = ops1[i1 += 1]
#           next
#         end
#
#         if insert_op?(op2)
#           operation1prime.retain(op2.length)
#           operation2prime.insert(op2)
#           op2 = ops2[i2 += 1]
#           next
#         end
#
#         if op1.nil?
#           fail 'Cannot transform operations: first operation is too short.'
#         end
#         if op2.nil?
#           fail 'Cannot transform operations: first operation is too long.'
#         end
#
#         minl = nil
#
#         if retain_op?(op1) && retain_op?(op2)
#           # Simple case: retain/retain
#           if op1 > op2
#             minl = op2
#             op1 -= op2
#             op2 = ops2[i2 += 1]
#           elsif (op1 == op2)
#             minl = op2
#             op1 = ops1[i1 += 1]
#             op2 = ops2[i2 += 1]
#           else
#             minl = op1
#             op2 -= op1
#             op1 = ops1[i1 += 1]
#           end
#
#           operation1prime.retain(minl)
#           operation2prime.retain(minl)
#         elsif delete_op?(op1) && delete_op?(op2)
#           # Both operations delete the same string at the same position. We don't
#           # need to produce any operations, we just skip over the delete ops and
#           # handle the case that one operation deletes more than the other.
#           if -op1 > -op2
#             op1 -= op2
#             op2 = ops2[i2 += 1]
#           elsif (op1 == op2)
#             op1 = ops1[i1 += 1]
#             op2 = ops2[i2 += 1]
#           else
#             op2 -= op1
#             op1 = ops1[i1 += 1]
#           end
#         # next two cases: delete/retain and retain/delete
#         elsif delete_op?(op1) && retain_op?(op2)
#           if -op1 > op2
#             minl = op2
#             op1 += op2
#             op2 = ops2[i2 += 1]
#           elsif (-op1 == op2)
#             minl = op2
#             op1 = ops1[i1 += 1]
#             op2 = ops2[i2 += 1]
#           else
#             minl = -op1
#             op2 += op1
#             op1 = ops1[i1 += 1]
#           end
#
#           operation1prime.delete(minl)
#         elsif retain_op?(op1) && delete_op?(op2)
#           if op1 > -op2
#             minl = -op2
#             op1 += op2
#             op2 = ops2[i2 += 1]
#           elsif (op1 == -op2)
#             minl = op1
#             op1 = ops1[i1 += 1]
#             op2 = ops2[i2 += 1]
#           else
#             minl = op1
#             op2 += op1
#             op1 = ops1[i1 += 1]
#           end
#
#           operation2prime.delete(minl)
#         else
#           throw new Error("The two operations aren't compatible")
#         end
#       end
#
#       return [operation1prime, operation2prime]
#     end
#   end
