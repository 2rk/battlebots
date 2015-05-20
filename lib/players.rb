require 'proxy'
require 'bots/the_closer'
require 'bots/the_bully'
require 'bots/the_chicken'
require 'bots/the_thinker'

module BattleBots
  module Players

    def player_list
      [ Proxy.new(self, TheCloser), 
        Proxy.new(self, TheBully),
        Proxy.new(self, TheThinker),
        Proxy.new(self, TheChicken)].shuffle
    end
  end
end