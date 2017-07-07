require 'gosu'

class SnakeWindow < Gosu::Window
  def initialize
    super(480, 480)
    self.caption = "Snake"

    apple_image = Gosu::Image.new("assets/apple.png")
    @apple = Apple.new(480, 480, apple_image)

    @body = Gosu::Image.new("assets/body.png")

    @background = Gosu::Image.new("assets/space.png", :tileable => true)
    @snake = Snake.new(100, 120, 5, @body)
    @game_over = false
    @score = 0
    @font = Gosu::Font.new(64, :name => "assets/arcade.ttf")
  end

  def draw
    @background.draw(0, 0, 0)
    @apple.draw
    @snake.draw
    @font.draw("Score: #{@score}", 5, 0, 10)

    if @game_over
      @font.draw("Press space", 5, 40, 11)
      @font.draw("to play", 5, 80, 11)
    end
  end

  def check_apple
    if @snake.eating?(@apple)
      @snake.add_piece
      @snake.speed_up
      @score += 1
      @apple.randomize_position
    end
  end

  def start_over
    @game_over = false
    @snake = Snake.new(100, 120, 5, @body)
    @score = 0
  end

  def update
    start_over if @game_over && Gosu.button_down?(Gosu::KbSpace)
    return if @game_over

    check_apple
    current_direction = @snake.head.direction

    new_direction =
      case
      when Gosu.button_down?(Gosu::KB_LEFT) && current_direction != :right
        :left
      when Gosu.button_down?(Gosu::KB_RIGHT) && current_direction != :left
        :right
      when Gosu.button_down?(Gosu::KB_UP) && current_direction != :down
        :up
      when Gosu.button_down?(Gosu::KB_DOWN) && current_direction != :up
        :down
      else
        nil
      end

    @snake.head.change_direction(new_direction) if new_direction
    @snake.move

    if @snake.dead?
      @game_over = true
    end
  end
end

class Apple
  attr_reader :x, :y

  def initialize(window_width, window_length, image)
    @window_width = window_width
    @window_length = window_length
    randomize_position
    @image = image
  end

  def randomize_position
    @x = Random.rand(0..@window_width).round(-1)
    @y = Random.rand(0..@window_length).round(-1)
  end

  def draw
    @image.draw(x, y, 100)
  end
end

class Snake
  LENGTH = 10.freeze

  attr_reader :pieces, :delay

  def initialize(x, y, length, image)
    @image = image
    @pieces = []
    length.times do |i|
      @pieces << SnakeBody.new(x, y + (i+1)*LENGTH, :up)
    end
    @last_moved = Time.now
    @delay = 0.1
  end

  def draw
    @pieces.each do |body|
      @image.draw(body.x, body.y, 0)
    end
  end

  def eating?(apple)
    apple.x == head.x && apple.y == head.y
  end

  def head
    pieces[0]
  end

  def speed_up
    @delay *= 0.99
  end

  def add_piece
    new_body = @pieces.last.dup
    case new_body.direction
    when :up
      new_body.down(LENGTH)
    when :down
      new_body.up(LENGTH)
    when :left
      new_body.right(LENGTH)
    when :right
      new_body.left(LENGTH)
    end
    @pieces.push(new_body)
  end

  def dead?
    head.x < 0 || head.x > 479 || head.y < 0 || head.y > 479
  end

  def move
    if Time.now - @last_moved > delay
      @pieces.pop
      new_body = @pieces[0].dup
      new_body.send(new_body.direction, LENGTH)
      @pieces.unshift(new_body)
      @last_moved = Time.now
    end
  end
end

class SnakeBody
  attr_reader :x, :y, :direction

  def initialize(x, y, direction)
    @x = x
    @y = y
    @direction = direction
  end

  def change_direction(direction)
    @direction = direction
  end

  def down(amount)
    @y += amount
  end

  def up(amount)
    @y -= amount
  end

  def left(amount)
    @x -= amount
  end

  def right(amount)
    @x += amount
  end
end

SnakeWindow.new.show
