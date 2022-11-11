
def format(value)
  value.to_s.reverse.scan(/.{1,3}/).join('.').reverse
end

# Dumme møgspell
examples = 100_000
armor_class = 16
attack_bonus = 4
rolls = {}
rounds_before_rest = 10
attacks_pr_round = 1
number_of_shield_spells = 3
number_of_damage_dice = 1
damage_die = 10
damage_die_bonus = 4
last_round_skipped = false
print = false

examples.times do |roll|
  puts "#{roll}" if roll.positive? && roll.modulo(10_000) == 0
  current_number_of_shield_spells = number_of_shield_spells
  last_round_skipped = false
  puts "New day!" if print
  rounds_before_rest.times do |round|
    id = "#{roll}-#{round}".to_sym
    primary_roll = rand(20) + 1
    second_roll = rand(20) + 1
    third_roll = rand(20) + 1
    disadv_roll = [primary_roll, second_roll].min
    shield_bonus = (current_number_of_shield_spells.positive? ? 5 : 0)
    phase_hit = ((disadv_roll + attack_bonus) >= armor_class)
    damage_dealt = rand(damage_die) + damage_die_bonus + 1

    rolls[id] = { 
      roll: primary_roll, 
      second_roll: second_roll,
      disadv_roll: disadv_roll,
      third_roll: third_roll,
      phase_hit: phase_hit,
      shield_hit: ((primary_roll + attack_bonus) >= armor_class + shield_bonus),
      shield_bonus: shield_bonus,
      remaining_shields: current_number_of_shield_spells,
      second_attack_hit: ((third_roll + attack_bonus) >= armor_class),
      second_attack_shield_hit: ((third_roll + attack_bonus) >= armor_class + shield_bonus),
      damage_dealt: damage_dealt
    }

    current_number_of_shield_spells -= 1 if rolls[id][:shield_hit] || rolls[id][:second_attack_shield_hit]
    puts rolls[id] if print
  end
end

phase_hits = 0
shield_hits = 0
second_phase_hit = 0
second_shield_hit = 0
damage_dealt_phase = 0
damage_dealt = 07

rolls.each do |k, v|
  phase_hits += 1 if v[:phase_hit]
  shield_hits += 1 if v[:shield_hit]
  second_phase_hit += 1 if v[:second_attack_hit]
  second_shield_hit += 1 if v[:second_attack_shield_hit]
  damage_dealt_phase += v[:damage_dealt] unless v[:phase_hit]
  damage_dealt += v[:damage_dealt]
end

puts "Antal dage testet #{examples}"
puts "Antal runder med indkommende attacks pr. dag: #{rounds_before_rest}"
puts "Antal indkommende attacks: #{attacks_pr_round}"
puts "Attack bonus pr. indkommende attack: +#{attack_bonus}"
puts "Mod AC: #{armor_class}"
puts "Antal Shield spells pr. dag: #{number_of_shield_spells}"
puts "Egen damage pr. runde #{number_of_damage_dice}d#{damage_die}+#{damage_die_bonus}"
puts ""
puts "Antal hits mod Phase (og dermed skippede runder): #{phase_hits}"
puts "Antal hits mod Shield: #{shield_hits}"
puts ""
puts "Antal andet hits ved brug af Phase: #{second_phase_hit}"
puts "Antal andet hits ved brug af Shield: #{second_shield_hit}"
puts ""
puts "Antal samlet antal hits ved brug af Phase: #{phase_hits + second_phase_hit}"
puts "Antal samlet antal hits ved brug af Phase: #{shield_hits + second_shield_hit}"
puts ""
puts "Gennemsnitligt Phase Damage output pr. dag: #{format(damage_dealt_phase/examples)}"
puts "Gennemsnitligt Damage output pr dag: #{format(damage_dealt/examples)}"