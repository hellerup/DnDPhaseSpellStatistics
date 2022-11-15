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
number_of_own_attacks = 1
number_of_damage_dice = 1
damage_die = 10
damage_die_bonus = 4
print = false

examples.times do |d|
  day = d + 1
  puts day.to_s if day.positive? && day.modulo(10_000).zero?
  puts 'New example!' if print
  current_number_of_shield_spells = number_of_shield_spells
  phase_hit = false
  combats_pr_day.times do |c|
    puts 'New combat!' if print
    combat = c + 1
    combat_rounds.times do |r|
      puts 'New round!' if print
      round = r + 1
      shield_active = false # Effective against all attacks in this round
      skip_damage = phase_hit
      phase_hit = false

      # Perform own attacks
      damage_dealt = 0
      phase_missed_damage = 0
      number_of_own_attacks.times do
        damage_dealt += rand(1..damage_die) + damage_die_bonus
        phase_missed_damage += damage_dealt if skip_damage
      end

      attacks_pr_round.times do |att|
        attack_no = att + 1
        id = "#{day}-#{combat}-#{round}-#{attack_no}".to_sym
        primary_roll = rand(1..20)
        second_roll = rand(1..20)
        disadv_roll = [primary_roll, second_roll].min
        shield_bonus = ((current_number_of_shield_spells.positive? || shield_active) ? 5 : 0)

        # Will the primary attack hit
        primary_hit = primary_roll + attack_bonus >= armor_class

        # Phase
        # Only relevant on attack 1
        dis_adv_hits = disadv_roll + attack_bonus >= armor_class
        # If this is the first attack and if the dis_adv hit hits, next round will be skipped
        phase_prevented_hit = attack_no == 1 && primary_hit && !dis_adv_hits
        phase_hit ||= attack_no == 1 && dis_adv_hits

        # We need to register all attacks where the Shield prevents the attack
        shield_prevented_hit = shield_bonus.positive? && primary_hit && primary_roll + attack_bonus <= armor_class + shield_bonus
        shield_active = true if primary_hit && shield_prevented_hit

        rolls[id] = {
          id: id,
          roll: primary_roll,
          disadv_roll: disadv_roll,
          primary_hit: primary_hit,
          phase_prevented_hit: phase_prevented_hit,
          shield_prevented_hit: shield_prevented_hit,
          phase_hit: phase_hit,
          phase_missed_damage: phase_missed_damage,
          skip_damage: skip_damage,
          shield_bonus: shield_bonus,
          shield_active: shield_active,
          damage_dealt: damage_dealt
        }

        damage_dealt = 0
        phase_missed_damage = 0

        puts rolls[id] if print
      end

      # Remove a shield charge if used in the round
      current_number_of_shield_spells -= 1 if shield_active
    end
  end
end

primary_hits = 0
phase_prevented_hits = 0
shield_prevented_hits = 0
phase_missed_damage = 0
damage_dealt = 0
phase_missed_damage = 0

rolls.each do |_k, v|
  primary_hits += 1 if v[:primary_hit]
  phase_prevented_hits += 1 if v[:phase_prevented_hit]
  shield_prevented_hits += 1 if v[:shield_prevented_hit]
  damage_dealt += v[:damage_dealt]
  phase_missed_damage += v[:phase_missed_damage]
end

puts "Antal dage testet #{examples}"
puts "Antal kampe pr. dag: #{combats_pr_day}"
puts "Antal runder pr. kamp: #{combat_rounds}"
puts "Antal indkommende attacks hver runde: #{attacks_pr_round}"
puts "Antal attacks i alt: #{examples * combats_pr_day * combat_rounds * attacks_pr_round}"
puts "Attack bonus pr. indkommende attack: +#{attack_bonus}"
puts "Mod AC: #{armor_class}"
puts "Antal Shield spells pr. dag: #{number_of_shield_spells}"
puts "Egen damage pr. runde #{number_of_damage_dice}d#{damage_die}+#{damage_die_bonus}"
puts ''
puts "Antal totale hits: #{primary_hits}"
puts ''
puts "Antal hits som Phase afværgede #{phase_prevented_hits}"
puts ''
puts "Antal hits Shield afværgede: #{shield_prevented_hits}"
puts ''
puts "Damage gennemsnitlig pr. kamp: #{damage_dealt / examples / combats_pr_day}"
puts "Damage gennemsnitlig mistet ved Phase pr. kamp: #{phase_missed_damage / examples / combats_pr_day}"
puts "Damage gennemsnitlig i alt ved Phase pr. kamp: #{(damage_dealt - phase_missed_damage) / examples / combats_pr_day }"
