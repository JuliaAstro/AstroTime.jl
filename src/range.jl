import Base: (:)

(:)(start::Epoch{S}, stop::Epoch{S}) where {S} = (:)(start, 1.0days, stop)

function (:)(start::Epoch{S}, step::Period, stop::Epoch{S}) where S
    step = seconds(step)
    step = start < stop ? step : -step
    StepRangeLen(start, step, floor(Int, value(stop-start)/value(step))+1)
end

Base.step(r::StepRangeLen{T}) where {T<:Epoch} = r.step

