```julia
using DataFrames
using TidierData

state_list = DataFrame[]

prizes = [14000, 10000, 7000, 5000, 5000, 5000, 5000, 5000,
   2500, 2500, 2500, 2500, 2500, 2500, 2500, 2500, 2500, 2500]

for i in 1:10000
    current_state = DataFrame(
        id = 1:63,
        kills = vcat(
            repeat([5], 1),
            repeat([4], 2),
            repeat([3], 2),
            repeat([2], 21),
            repeat([1], 18),
            repeat([0], 63-44)
        ),
        post_r3_kills = vcat(
            repeat([5], 1),
            repeat([4], 2),
            repeat([3], 2),
            repeat([2], 21),
            repeat([1], 18),
            repeat([0], 63-44)
        ),
    )

    for round in 1:45
        killer = rand(1:nrow(current_state))
        killed = rand(vcat(1:(killer-1), (killer+1):nrow(current_state)))
        current_state.kills[killer] += 1
        delete!(current_state, [killed])
    end

    sort!(current_state, :kills, rev = true)
    current_state.iter .= i
    current_state.prize = prizes

    push!(state_list, current_state)
end

@chain vcat(state_list...) begin
    @group_by(post_r3_kills, id)
    @summarize(av_win = sum(prize)/10000)
    @summarize(ev = mean(av_win))
    @arrange(desc(ev))
end
```
