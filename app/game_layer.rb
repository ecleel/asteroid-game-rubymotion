class GameLayer < Joybox::Core::Layer
  scene
  
  def on_enter
    background = Sprite.new file_name: 'background.png', position: Screen.center
    self << background
    
    @rocket = Sprite.new file_name: 'rocket.png', position: Screen.center, alive: true
    self << @rocket
    
    on_touches_began do |touches, event|
      touch = touches.any_object
      @rocket.run_action Move.to position: touch.location
    end
    
    schedule_update do |dt|
      launch_asteroids
      check_for_collisions if @rocket[:alive]
    end
  end
  
  MaximumAsteroids = 10
  def launch_asteroids
    @asteroids ||= Array.new
    
    if @asteroids.size <= MaximumAsteroids
      missing_asteroids = MaximumAsteroids - @asteroids.size
      missing_asteroids.times do
        asteroid = AsteroidSprite.new
        move_action = Move.to position: asteroid.end_position, duration: 4.0
        callback_action = Callback.with { |asteroid| @asteroids.delete asteroid }
        asteroid.run_action Sequence.with actions: [move_action, callback_action]
        
        self << asteroid
        @asteroids << asteroid
      end
    end
  end
  
  def check_for_collisions
    @asteroids.each do |asteroid|
      if CGRectIntersectsRect(asteroid.bounding_box, @rocket.bounding_box)
        @asteroids.each(&:stop_all_actions)
        @rocket[:alive] = false
        @rocket.run_action Blink.with times: 20, duration: 3.0
        break
      end
    end
  end
end