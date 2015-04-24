require 'bullets'

module BattleBots
  class Proxy

    attr_reader :bot, :x, :y, :health

    def initialize(window, name)
      set_environmentals window

      @bot = name.new
      @name = @bot.name
      @speed, @strength, @stamina, @sight = 25, 25, 25, 25
      @ammo = 0

      @heading = 90
      @turret = 33
      @health = 100
    end

    def play
      reload
      observe_battlespace
      query_bot
      move_bot
      aim_turret
      fire!
    end

    def hit?(bullets)
      bullets.reject! do |bullet|
        if Gosu::distance(@x, @y, bullet.x, bullet.y) < 25
          @health -= 10
          true
        end
      end
    end

    def draw
      if @health > 0
        @body_image.draw_rot(@x, @y, 1, @heading)
        @turret_image.draw_rot(@x, @y, 1, @turret)
        @font.draw("#{@bot.name}: #{@health.to_i}", @x - 50, @y + 25, 0, 1.0, 1.0, 0xffffff00)
      end
    end

    def dead?
      true if @health < 1
    end


    private

    def set_environmentals(window)
      @window = window
      @body_image = Gosu::Image.new(window, "media/body.png")
      @turret_image = Gosu::Image.new(window, "media/turret.png")
      @font = Gosu::Font.new(window, Gosu::default_font_name, 20)

      @x, @y = window.width * rand(), window.height * rand()
      @vel_x = @vel_y = 0.0
    end

    def reload
      @ammo += 1
    end

    def query_bot
      @bot.think
    end

    def observe_battlespace
      battlespace = { 
        x: @x, y: @y, health: @health, turret: @turret, heading: @heading, contacts: []
      }

      @window.players.each do |enemy|
        unless @x == enemy.x && @y == enemy.y
          battlespace[:contacts] << [enemy.x, enemy.y, enemy.health]
        end
      end

      @bot.observe battlespace
    end

    def move_bot
      @heading += @bot.turn 

      vel = cap(@bot.drive, 1.0) * 0.25

      @vel_x += Gosu::offset_x(@heading, vel)
      @vel_y += Gosu::offset_y(@heading, vel)

      @x += @vel_x
      @y += @vel_y

      # The world is flat but it has fences
      @x = 0 if @x < 0
      @y = 0 if @y < 0      
      @x = @window.width if @x > @window.width
      @y = @window.height if @y > @window.height

      # Add velocity decay
      @vel_x *= 0.9
      @vel_y *= 0.9
    end

    def aim_turret
      @turret += @bot.aim
    end

    def fire!
      if @ammo > 0 && @bot.shoot
        @ammo = (100 - @strength) * -1
        @window.bullets << Bullet.new(@window, [@x, @y, @turret, Gosu::offset_x(@turret, @strength + @vel_x.abs), Gosu::offset_y(@turret, @strength + @vel_y.abs)])
      end
    end

    def cap(value, limit)
      value = limit if value.abs > limit
      value
    end
  end
end