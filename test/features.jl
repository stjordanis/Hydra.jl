using SPMD, Test
using SPMD: shuffle

@test lane() == lanewidth() == 1

@test @spmd(4, lane()) == 1

@test @spmd(4, lanewidth()) == 4

@test @spmd(4, lanesum(5)) == 20

@test @spmd(4, shuffle(lane(), 4+1-lane())) == 4

@test @spmd(4, shuffle(2lane(), 3)) == 6

function if_statement(x)
  a = x + 1
  if a > 10
    a += 1000
  elseif a > 5
    a += 100
  else
    a += 10
  end

  if x > 0
    a += 10
  else
    a -= 10
  end
  return a
end

function while_loop(x)
  a = x + 1
  i = 0
  while x > i
    if x >= 10
      a += 3
    elseif x >= 5
      a += 2
    else
      a += 1
    end
    i += 1
  end
  a
end

function for_loop(x)
  a = x + 1
  for i=1:x
    if x > 10
      a += x
    else
      a -= x
    end
  end
  a
end


mask = SPMD.vect(true,true,true,true)

input = Vector{Int32}([1,6,11,-1])
@test SPMD.spmd(mask, if_statement, SPMD.vect(input...)) == SPMD.vect(map(if_statement, input)...)

input = Vector{Int32}([5,5,5,5])
@test SPMD.spmd(mask, while_loop, SPMD.vect(input...)) == SPMD.vect(map(while_loop, input)...)

input = Vector{Int32}([1,5,12,-3])
@test SPMD.spmd(mask, while_loop, SPMD.vect(input...)) == SPMD.vect(map(while_loop, input)...)

input = Vector{Int32}([2,32,-1,21])
@test SPMD.spmd(mask, for_loop, SPMD.vect(input...)) == SPMD.vect(map(for_loop, input)...)
