def format(value)
  value.to_s.reverse.scan(/.{1,3}/).join('.').reverse
end

# Dumme møgspell
examples = 10
armor_class = 16
attack_bonus = 4
rolls = {}
combats_pr_day = 4 # This is how many combats pr. day
combat_rounds = 3 # This is how many rounds a combat lasts
attacks_pr_round = 2
number_of_shield_spells = 3
number_of_damage_dice = 1
damage_die = 10
damage_die_bonus = 4
print = true

examples.times do |d|
  day = d + 1
  puts day.to_s if day.positive? && day.modulo(10_000) == 0
  puts 'New combat!' if print
  current_number_of_shield_spells = number_of_shield_spells
  combats_pr_day.times do |c|
    combat = c + 1
    combat_rounds.times do |r|
      round = r + 1
      shield_used = false # Effective against all attacks in this round
      attacks_pr_round.times do |att|
        attack_no = att + 1
        id = "#{day}-#{combat}-#{round}-#{attack_no}".to_sym
        primary_roll = rand(1..20)
        second_roll = rand(1..20)
        disadv_roll = [primary_roll, second_roll].min
        shield_bonus = (current_number_of_shield_spells.positive? ? 5 : 0)

        # Will the primary attack hit
        primary_hits = primary_roll + attack_bonus >= armor_class
        dis_adv_hits = disadv_roll + attack_bonus >= armor_class
        will_shield_prevent_hit = primary_hits && primary_roll + attack_bonus >= armor_class + shield_bonus

        # If this is the first round and if the dis_adv hit hits, next round will be skipped
        # We simply wont calculate damage for this round in this case
        phase_hit = if attack_no == 1 && dis_adv_hits

        hit = false
        hit = true if attack_no == 1 && dis_adv_hits
        hit = true if primary_hits && !will_shield_prevent_hit

        damage_dealt = rand(1..damage_die) + damage_die_bonus
        shield_used = shield_hit if shield_hit && !shield_used

        rolls[id] = {
          id: id,
          roll: primary_roll,
          second_roll: second_roll,
          disadv_roll: disadv_roll,
          hit: hit,
          damage_dealt: damage_dealt
        }

        puts rolls[id] if print
      end

      # Remove a shield charge if used in the round
      current_number_of_shield_spells -= 1 if shield_used
    end
  end
end

phase_hits = 0
shield_hits = 0
second_phase_hit = 0
second_shield_hit = 0
damage_dealt_phase = 0
damage_dealt = 0

rolls.each do |_k, v|
  phase_hits += 1 if v[:phase_hit]
  shield_hits += 1 if v[:shield_hit]
  second_phase_hit += 1 if v[:second_attack_hit]
  second_shield_hit += 1 if v[:second_attack_shield_hit]
  damage_dealt_phase += v[:damage_dealt] unless v[:skip_round]
  damage_dealt += v[:damage_dealt]
end

puts "Antal dage testet #{examples}"
puts "Antal kampe pr. dag: #{combats_pr_day}"
puts "Antal runder pr. kamp: #{combat_rounds}"
puts "Antal indkommende attacks hver runde: #{attacks_pr_round}"
puts "Attack bonus pr. indkommende attack: +#{attack_bonus}"
puts "Mod AC: #{armor_class}"
puts "Antal Shield spells pr. dag: #{number_of_shield_spells}"
puts "Egen damage pr. runde #{number_of_damage_dice}d#{damage_die}+#{damage_die_bonus}"
puts ''
puts "Antal hits mod Phase (og dermed skippede runder): #{phase_hits}"
puts "Antal hits mod Shield: #{shield_hits}"
puts ''
puts "Antal samlet antal hits ved brug af Phase: #{phase_hits + second_phase_hit}"
puts "Antal samlet antal hits ved brug af Phase: #{shield_hits + second_shield_hit}"
puts ''
puts "Gennemsnitligt Phase Damage output pr. dag: #{format(damage_dealt_phase / examples)}"
puts "Gennemsnitligt Damage output pr dag: #{format(damage_dealt / examples)}"
