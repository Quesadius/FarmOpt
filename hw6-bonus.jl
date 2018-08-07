
# Joe Atkins
# CS 524
# HW 6-bonus
# 6AUG18
using Gurobi, JuMP, NamedArrays


# Utilizing Miller-Tucker-Zemlin Example from Canvas and adapting to problem
ordering = [:1, :2, :3, :4, :5]
durations = [40 32 50 28 47]
cleanings = [ 0 10  6 15  9
              4  0  6 17  8
             10 11  0 20 14
              7 15  6  0  2
              5  8  7  7  0]

c = NamedArray(cleanings,(ordering,ordering))
N = size(cleanings,1);

# Subtour printing helper functions
# HELPER FUNCTION: returns the cycle starting with paint START.
function getSubtour(x,start)
    subtour = [start]
    while true
        j = subtour[end]
        for k in ordering
            if x[j,k] == 1
                push!(subtour,k)
                break
            end
        end
        if subtour[end] == start
            break
        end
    end
    return subtour
end

# HELPER FUNCTION: returns a list of all cycles
function getAllSubtours(x)
    nodesRemaining = ordering
    subtours = []
    while length(nodesRemaining) > 0
        subtour = getSubtour(x,nodesRemaining[1])
        push!(subtours, subtour)
        nodesRemaining = setdiff(nodesRemaining,subtour)
    end
    return subtours
end

m = Model(solver = GurobiSolver(OutputFlag=0))

@variable(m, x[ordering,ordering], Bin)                          # Binary variables for edge following from paint to paint
@constraint(m, c1[j in ordering], sum( x[i,j] for i in ordering ) == 1)      # one out-edge
@constraint(m, c2[i in ordering], sum( x[i,j] for j in ordering ) == 1)      # one in-edge
@constraint(m, c3[i in ordering], x[i,i] == 0 )                            # no self-loops
@objective(m, Min, sum( x[i,j]*cleanings[i,j] for i in ordering, j in ordering ))   # minimize total cleaning time
                                    
# MTZ variables and constraints
@variable(m, u[ordering])
@constraint(m, c4[i in ordering, j in ordering[2:end]], u[i] - u[j] + N*x[i,j] <= N-1 )  #MTZ Subtour elimination constraint from slide of trix




solve(m)
xx = getvalue(x)
println()
println("For optimal ordering any starting point will do,")
println("but an ordering starting the week with 1 and ending")
println("the week cleaning in preparation for 1 is:")
subtours = getAllSubtours(xx)  # get ordering of paint mixes
sleep(1)
display(subtours)
println()
#sol = NamedArray(zeros(Int,N,N),(ordering,ordering))
#for i in ordering
#    for j in ordering
#        sol[i,j] = Int(xx[i,j])
#    end
#end
#println(sol)
#println()
println("Total time is ", getobjectivevalue(m) + sum(durations), " minutes.")


