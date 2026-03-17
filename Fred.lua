-- Fred.lua
-- Compute and display P(infected | positive) given fixed sensitivity (99%), specificity, and prevalence.
-- Usage:
--   lua Fred.lua <prevalence_pct> [specificity_pct]
-- Example:
--   lua Fred.lua 5        
--   lua Fred.lua 0.01 99.5
-- if the specificity arg is omitted, it will just use 99, 99.9, 99.99 and 99.999
-- it only runs the integer check if the specificity arg wasn't omitted

local function ppv(specificity_pct, prevalence_pct)
  local sens = 0.99
  local spec = specificity_pct / 100
  local prev = prevalence_pct / 100

  local num = sens * prev
  local den = num + (1 - spec) * (1 - prev)
  return den > 0 and (num / den) or 0
end

local function usage()
  io.write("Usage: lua Fred.lua <prevalence_pct> [specificity_pct]\n")
  io.write("  prevalence_pct: 0.001 .. 50 (percent)\n")
  io.write("  specificity_pct: 0.0 .. 100 (percent). If omitted, uses 99, 99.9, 99.99, 99.999\n")
  io.write("Example: lua Fred.lua 5 99.5\n")
end


-- WHY IS IT NOT ZERO INDEXED
local function parse_args()
  if not arg or not arg[1] then
    usage()
    os.exit(1)
  end

  local prev = tonumber(arg[1])
  if not prev then
    io.write("prevalence must be a number\n")
    usage()
    os.exit(1)
  end
  if prev < 0.001 or prev > 50 then
    io.write("prevalence must be between 0.001 and 50\n")
    os.exit(1)
  end

  local specs
  if arg[2] then
    local spec = tonumber(arg[2])
    if not spec then
      io.write("specificity must be a number\n")
      os.exit(1)
    end
    specs = { spec }
  else
    specs = { 99.0, 99.9, 99.99, 99.999 }
  end

  return prev, specs
end

local function print_ppv_table(prevalence_pct, specs)
  io.write(string.format("Prevalence: %.4f%% (sensitivity=99%%)\n", prevalence_pct))
  io.write("Specificity\tPPV (P(infected|+))\n")
  for _, spec in ipairs(specs) do
    local ppv_pct = ppv(spec, prevalence_pct) * 100
    io.write(string.format("%.6f\t%.4f%%\n", spec, ppv_pct))
  end
end

local function integer_check(pop, prevalence_pct, specificity_pct)
  local prev = prevalence_pct / 100
  local sens = 0.99
  local spec = specificity_pct / 100

  local infected = math.floor(pop * prev + 0.5)
  local not_infected = pop - infected
  local true_pos = math.floor(infected * sens + 0.5)
  local true_neg = math.floor(not_infected * spec + 0.5)
  local false_pos = not_infected - true_neg
  local total_pos = true_pos + false_pos
  local ppv_val = total_pos > 0 and (true_pos / total_pos) or 0

  return {
    pop = pop,
    infected = infected,
    true_pos = true_pos,
    false_pos = false_pos,
    total_pos = total_pos,
    ppv = ppv_val,
  }
end

local prevalence_pct, specs = parse_args()

print_ppv_table(prevalence_pct, specs)

-- Integer Check if only one is specified
if #specs == 1 then
  local pop = 1000000
  local res = integer_check(pop, prevalence_pct, specs[1])
  io.write("\nInteger-check (N=", pop, ") using the same parameters:\n")
  io.write(string.format("  Infected: %d (%.4f%%)\n", res.infected, prevalence_pct))
  io.write(string.format("  True positives: %d\n", res.true_pos))
  io.write(string.format("  False positives: %d\n", res.false_pos))
  io.write(string.format("  Total positives: %d\n", res.total_pos))
  io.write(string.format("  Posterior = %.4f%%\n", res.ppv * 100))
end
