@def title = "Causal Inference: What If (Chapters 1 - 9)"
@def date = "2026-04-18"
@def tags = ["julia", "what-if"]
@def rss_pubdate = Date(2026, 04, 18)

---

I'm rereading Miguel Hernan's excellent Causal Inference textbook and working the examples in julia as I go. Chapters 1-9 are light on models, since they generally don't consider uncertainty due to sampling.

The first example gives us the counterfactual outcomes for heart surgery in Table 1.1 and the observed outcomes in Table 1.2. The average causal effect is zero by any measure, but the associational effect measures all show effect.  

```julia
# Table 1.1
using TidierData

hearts = @chain DataFrame(in = split("""
Rheia 0 1 1 0 0 0
Kronos 1 0 0 0 1 0
Demeter 0 0 1 0 0 0
Hades 0 0 0 0 0 0
Hestia 0 0 1 1 0 0
Poseidon 1 0 0 1 0 0
Hera 0 0 1 1 0 0
Zeus 0 1 0 1 1 0
Artemis 1 1 1 0 1 1
Apollo 1 0 0 0 1 1
Leto 0 1 1 0 0 1
Ares 1 1 0 1 1 1
Athena 1 1 1 1 1 1
Hephaestus 0 1 0 1 1 1
Aphrodite 0 1 1 1 1 1
Polyphemus 0 1 0 1 1 1
Persephone 1 1 1 1 1 1
Hermes 1 0 0 1 0 1
Hebe 1 0 1 1 0 1
Dionysus 1 0 0 1 0 1""", "\n"))
begin
    @separate(in, (Name, Y0, Y1, V, A, Y, L), " ")
    @mutate(
        Y0 = as_integer(Y0), 
        Y1 = as_integer(Y1), 
        V = as_integer(V),
        A = as_integer(A),
        Y = as_integer(Y),
        L = as_integer(L),
        V2 = 1
    )
end

PrY01 = mean(hearts.Y0)
PrY11 = mean(hearts.Y1)

risk_diff = PrY11 - PrY01 # 0.0
risk_ratio = PrY11 / PrY01 # 1.0

PrY10 = mean(1 .- hearts.Y1)
PrY00 = mean(1 .- hearts.Y0)

odds_ratio = (PrY11/PrY10)/(PrY01/PrY00) # 1.0
```

```julia
PrY1 = @chain hearts begin
    groupby(:A)
    combine(:Y => (x -> sum(x) // length(x)) => [:Y])
end
    
PrY1A0, PrY1A1 = PrY1.Y
PrY0A0, PrY0A1 = 1 .- PrY1.Y
 
associational_risk_diff = PrY1A1 - PrY1A0 # 10/91
associational_risk_ratio = PrY1A1 / PrY1A0 # 49/39
associational_odds_ratio = (PrY1A1/PrY0A1)/(PrY1A0/PrY0A0) # 14/9 
```

# Chapter 2

Chapter 2's examples concern the analysis of the heart data as a randomized experiment. If the randomization is assumed to be marginal, we get a positive risk ratio. If conditional, calculating the CRR can be done directly or through IPW to get the same answer (RR = 1.0). 

```julia
PrY1 = @chain hearts begin
    groupby(:A)
    combine(:Y => (x -> sum(x) // length(x)) => [:Y])
end

PrY1A0, PrY1A1 = PrY1.Y

rr_marginal_experiment = PrY1A1 / PrY1A0

PrY1_L = @chain hearts begin
    groupby([:L, :A])
    combine(
        :Y => (x -> sum(x) // length(x)) => :PrY, 
        :Y => length => :n
    )
end

crr = @chain PrY1_L begin
    groupby([:L])
    combine([:PrY, :n] => ((x,y) -> x * sum(y)) => :wsum, :A)
    groupby([:A])
    combine([:wsum] => (x -> sum(x)/20) => :crr)
end

/(crr.crr...) # 1/1

# IP weighted

ipw = @chain PrY1_L begin
    groupby(:L)
    @mutate(ipw = sum(n)/n)
    @ungroup()
    groupby(:A)
    @summarize(outcomes = sum(ipw * PrY * n))
end

/(ipw.outcomes...) # 1.0
```

# Chapter 

```julia
@chain hearts begin
    groupby(:V)
    @summarize(PrY1 = mean(Y1), PrY0 = mean(Y0))
    @mutate(RR = PrY1/PrY0, RD = PrY1-PrY0)
end
```


```julia
hearts2 = @chain DataFrame(in = split("""
Cybele 0 0 0
Saturn 0 0 1
Ceres 0 0 0
Pluto 0 0 0
Vesta 0 1 0
Neptune 0 1 0
Juno 0 1 1
Jupiter 0 1 1
Diana 1 0 0
Phoebus 1 0 1
Latona 1 0 0
Mars 1 1 1
Minerva 1 1 1
Vulcan 1 1 1
Venus 1 1 1
Seneca 1 1 1
Proserpina 1 1 1
Mercury 1 1 0
Juventas 1 1 0
Bacchus 1 1 0""", "\n")) begin
    @separate(in, (Name, L, A, Y), " ")
    @mutate(L = as_integer(L), A = as_integer(A), Y = as_integer(Y), V2 = 0)
end

@chain @bind_rows(@select(hearts, Name, L, A, Y, V2), hearts2) begin
    groupby([:L, :A])
    combine(
        :Y => (x -> sum(x) // length(x)) => :PrY, 
        :Y => length => :n
    )
    @ungroup
    groupby(:L)
    @mutate(ipw = sum(n)/n)
    @ungroup
    groupby(:A)
    @summarize(PrY = sum(ipw * PrY * n)/40)
end
```

```julia
@chain hearts2 begin
    groupby([:L, :A])
    combine(
        :Y => (x -> sum(x) // length(x)) => :PrY, 
        :Y => length => :n
    )
    @ungroup
    groupby(:L)
    @mutate(ipw = sum(n)/n)
    @ungroup()
    groupby(:A)
    @summarize(PrY = sum(ipw * PrY * n)/20)
end
```
