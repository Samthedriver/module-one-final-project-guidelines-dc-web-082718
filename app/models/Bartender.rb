class Bartender < ActiveRecord::Base
  # has many drinks through bartender_drink
  belongs_to :bar
  has_many :bartender_drinks
  has_many :drinks, through: :bartender_drinks

  def list_drinks
    self.reload
    self.drinks.each {|drink| puts "      #{drink.name}"}
  end

  # Can learn new drink
  def learn_drink(drink_name)
    self.reload
    # Check if max limit of specializations is reached
    # Can specialize in 2 drinks max.
    self.drinks.each do |drink|
      if drink.name == drink_name
        puts "#{self.name} already specializes in #{drink_name}."
        return
      end
    end
    if self.drinks.size < 2
      new_drink = Drink.find_or_create_by(name: drink_name)
      BartenderDrink.create(bartender_id: self.id, drink_id: new_drink.id)
      puts "#{self.name} now knows how to make a really good #{new_drink.name}."
    else
      my_drinks = self.drinks.collect{ |drink| drink.name}
      puts "#{self.name} can only specialize in two drinks."
      puts "#{self.name}'s specialties are a #{my_drinks[0]} and a #{my_drinks[1]}'."
    end
  end

  # Can drop a specialization
  def drop_specialization(drink_id)
    # Delete drink_id in bartender_drinks for this bartender
    drop = BartenderDrink.where("bartender_id = ? AND drink_id = ?",
    self.id, drink_id)[0]
    self.reload
    puts "#{self.name} no longer specializes in #{Drink.find(drink_id).name}."
    drop.destroy
  end

  # Can quit working at a bar
  def quits_bar
    self.reload
    if self.bar_id == nil
      puts "#{self.name} is already unemployed."
      return
    end
    puts "#{self.name} has quit working at #{self.bar.name}."
    self.bar_id = nil
    self.save
  end

  #list all bartenders that dont have a job.
  def self.unemployed
    Bartender.all.where(bar_id: nil)
  end

  def self.common_drinks
    # self.reload
    pop_drinks = []
    Drink.all.each do |drink|
      if drink.bartenders.size > 0
        pop_drinks << {:drink => drink.name, :count => drink.bartenders.size}
      end
    end
    pop_drinks.sort_by! do |hash|
      -hash[:count]
    end

    count = 1
    pop_drinks.each do |hash|
      puts "#{hash[:drink]} is currently made by #{hash[:count]} bartender(s)."
      if count == 3
        return
      else
        count += 1
      end
    end

  end

  def self.rarest_drinks
    # self.reload
    pop_drinks = []
    Drink.all.each do |drink|
      if drink.bartenders.size > 0
        pop_drinks << {:drink => drink.name, :count => drink.bartenders.size}
      end
    end
    pop_drinks.sort_by! do |hash|
      hash[:count]
    end

    count = 1
    pop_drinks.each do |hash|
      puts "#{hash[:drink]} is currently made by #{hash[:count]} bartender(s)."
      if count == 3
        return
      else
        count += 1
      end
    end

  end

  def self.unemployed_bartender_drinks
    # self.reload
    puts "    These drinks are not on any menu but currently are provided by unemployed bartenders."
    unavailable_drinks = []

    Drink.all.each do |drink|
      if drink.bartenders.size > 0
        available = false
        drink.bartenders.each do |bartender|
          # puts "Bartender bar id: #{bartender.bar_id}  Drink: #{drink.name}"
          if bartender.bar_id != nil
            available = true
          end
          # if bartender.bar_id != nil
          #   available = true
          # end
        end

        if !available
          unavailable_drinks << drink.name
          puts "  Drink name: #{drink.name}"
          drink.bartenders.each do |bartender|
            puts "    - Bartender name: #{bartender.name}"
          end
        end
      end
      #puts unavailable_drinks
    end
  end
end
