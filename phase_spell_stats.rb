def format(value)
  value.to_s.reverse.scan(/.{1,3}/).join('.').reverse
end

# Dumme møgspell
# Vi registrerer et antal dage med et vist antal kampe og et vist antal attacks mod pc'en pr. runde
# Vi registrerer alle attacks og antallet af 'Ville have ramt'
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
    phase_hit = false
    combat_rounds.times do |r|
      round = r + 1
      shield_active = false # Effective against all attacks in this round
      skip_damage = phase_hit
      phase_hit = false
      attacks_pr_round.times do |att|
        attack_no = att + 1
        id = "#{day}-#{combat}-#{round}-#{attack_no}".to_sym
        primary_roll = rand(1..20)
        second_roll = rand(1..20)
        disadv_roll = [primary_roll, second_roll].min
        shield_bonus = (current_number_of_shield_spells.positive? || shield_active ? 5 : 0)

        # Will the primary attack hit
        primary_hits = primary_roll + attack_bonus >= armor_class

        # Phase
        # Only relevant on attack 1
        dis_adv_hits = disadv_roll + attack_bonus >= armor_class
        # If this is the first attack and if the dis_adv hit hits, next round will be skipped
        phase_hit = true if attack_no == 1 && dis_adv_hits

        # We need to register all attacks where the Shield prevents the attack
        will_shield_prevent_hit = primary_hits && primary_roll + attack_bonus >= armor_class + shield_bonus
        shield_active = true if primary_hits && will_shield_prevent_hit

        if skip_damage
          damage_dealt = 0
        else
          damage_dealt = rand(1..damage_die) + damage_die_bonus 
        end
        
        rolls[id] = {
          id: id,
          roll: primary_roll,
          second_roll: second_roll,
          disadv_roll: disadv_roll,
          phase_hit: phase_hit,
          damage_dealt: damage_dealt,
        }

        puts rolls[id] if print
      end

      # Remove a shield charge if used in the round
      current_number_of_shield_spells -= 1 if shield_active
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
  damage_dealt_phase += v[:damage_dealt]
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
puts "Gennemsnitligt Phase Damage output pr. dag: #{format(damage_dealt_phase / examples)}"
puts "Gennemsnitligt Damage output pr dag: #{format(damage_dealt / examples)}"
