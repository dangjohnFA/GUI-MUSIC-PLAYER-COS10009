require 'gosu'

TOP_COLOR = Gosu::Color.new(0xFF1EB1FA)
BACKGROUND_COLOR = Gosu::Color.argb(0xff_252526)
ARTWORK_WIDTH = 544

module ZOrder
  BACKGROUND, MIDDLE, TOP = *0..2
end

module ScreenType
  ALBUMS, TRACKS = *0..1
end

class MusicPlayerWindow < Gosu::Window
  def initialize
    @background_image = Gosu::Image.new("Main_Background.jpeg")
  super @background_image.width, @background_image.height
  self.caption = "Music Player"

  @font = Gosu::Font.new(100)
  @album_font = Gosu::Font.new(60)
  @button_font = Gosu::Font.new(50)
  @song_font = Gosu::Font.new(40)
  @title = "CHOOSE AND CHILL WITH THESE ALBUMS"

  @albums = [
    { image: Gosu::Image.new("images/Ed Sheeran.jpg"), title: "+-=:x", artist: "Ed Sheeran", background: Gosu::Image.new("Elements/Background1.PNG"), songs: [], song_paths: [] },
    { image: Gosu::Image.new("images/Crash Adams.jpg"), title: "Too Hot To Touch", artist: "Crash Adams", background: Gosu::Image.new("Elements/Background2.JPG"), songs: [], song_paths: [] },
    { image: Gosu::Image.new("images/Alan Walker.jpg"), title: "Who Am I", artist: "Alan Walker", background: Gosu::Image.new("Elements/Background3.JPG"), songs: [], song_paths: [] },
    { image: Gosu::Image.new("images/Hatsune Miku.jpg"), title: "Miku", artist: "Hatsune Miku", background: Gosu::Image.new("Elements/Background4.JPG"), songs: [], song_paths: [] }
  ]

  @middle_image = Gosu::Image.new("Elements/MenuButton.png")
  @home_button_image = Gosu::Image.new("Elements/Home_Button.png")
  @home_button_hover_image = Gosu::Image.new("Elements/Home_Button_Hover.png")
  @track_box_image = Gosu::Image.new("Elements/Track_Box.png")

  @album_width = 400
  @album_height = 400

  @current_view = :main_menu
  @selected_album = nil
  @song_font = Gosu::Font.new(60)

  # New button images
  @play_btn = Gosu::Image.new("elements/Play.png")
  @play_btn_hover = Gosu::Image.new("elements/Play_Hover.png")
  @pause_btn = Gosu::Image.new("elements/Pause.png")
  @pause_btn_hover = Gosu::Image.new("elements/Pause_Hover.png")
  @backward_btn = Gosu::Image.new("elements/Backward.png")
  @backward_btn_hover = Gosu::Image.new("elements/Backward_Hover.png")
  @forward_btn = Gosu::Image.new("elements/Forward.png")
  @forward_btn_hover = Gosu::Image.new("elements/Forward_Hover.png")
  @loop_btn = Gosu::Image.new("elements/Loop.png")
  @random_btn = Gosu::Image.new("elements/random.png")

  @looping = false  # Add a flag to track the loop state
  @loop_btn_active = false  # Add a flag to track the loop button state
  
  # Music player state
  @current_song = nil
  @current_song_index = 0  # Track the current song index
  @playing = false
  @paused = false  # Add this line to track the pause state
  @song_position = 0  # Track the current position of the song


  # Load songs from file
  load_songs_from_file("Albums.txt")
end

  def load_songs_from_file(filename)
    File.readlines(filename).each do |line|
      album_index, song_title, song_path = line.chomp.split('|')
      album_index = album_index.to_i
      @albums[album_index][:songs] << song_title
      @albums[album_index][:song_paths] << song_path
    end
  end

  def button_down(id)
    element_spacing = 20  # Define element_spacing here
  
    if @current_view == :main_menu
      if id == Gosu::MS_LEFT
        @albums.each_with_index do |album, index|
          x = (width - (@albums.size * @album_width + (@albums.size - 1) * 50)) / 2 + index * (@album_width + 50)
          y = (height / 2) - (@album_height / 2) - 400
          if mouse_over?(x, y, @album_width, @album_height)
            @selected_album = album
            @current_view = :album_view
          end
        end
      end
    elsif @current_view == :album_view
      if id == Gosu::MS_LEFT
        if mouse_over?(home_button_x, home_button_y, @home_button_image.width * 7, @home_button_image.height * 7) ||
           mouse_over?(back_text_x, back_text_y, @button_font.text_width("Back"), @button_font.height)
          @current_view = :main_menu
        else
          @selected_album[:songs].each_with_index do |song, index|
            song_x = (width - @song_font.text_width(song)) / 2
            song_y = (height / 2) + @album_height / 2 - 150 + 100 + index * 60
            if mouse_over?(song_x, song_y, @song_font.text_width(song), @song_font.height)
              @current_song_index = index  # Update the current song index
              @current_song = Gosu::Song.new(@selected_album[:song_paths][index])
              @current_song.play
              @playing = true
              puts "Playing song: #{song}"
            end
          end
  
          # Calculate track_box_y
          track_box_y = (height / 2) + @album_height / 2 - 150
          controls_y = track_box_y + @track_box_image.height * 3 + 60
  
          # Define the exact coordinates and dimensions for the play button
          play_x = (width - @play_btn.width * 3) / 2 - 50  # Move 50 pixels to the left
          play_y = controls_y
          play_width = @play_btn.width * 3
          play_height = @play_btn.height * 3
  
          # Define the exact coordinates and dimensions for the pause button
          pause_x = play_x + play_width + element_spacing - 50  # Move 50 pixels to the left
          pause_y = controls_y
          pause_width = @pause_btn.width * 3
          pause_height = @pause_btn.height * 3
  
          # Define the exact coordinates and dimensions for the backward button
          backward_x = play_x - play_width - element_spacing - 50  # Move 50 pixels further to the left
          backward_y = controls_y
          backward_width = @backward_btn.width * 3
          backward_height = @backward_btn.height * 3
  
          # Define the exact coordinates and dimensions for the forward button
          forward_x = pause_x + pause_width + element_spacing + 50  # Move 50 pixels further to the right
          forward_y = controls_y
          forward_width = @forward_btn.width * 3
          forward_height = @forward_btn.height * 3
  
          # Define the exact coordinates and dimensions for the loop button
          loop_x = play_x + (play_width - @loop_btn.width * 0.25) / 2  # Center the loop button under the play button
          loop_y = play_y + play_height + element_spacing  # Place it right under the play button
          loop_width = @loop_btn.width * 0.25  # Scale down the loop button to 0.25
          loop_height = @loop_btn.height * 0.25

          # Define the exact coordinates and dimensions for the random button
          random_x = pause_x + (pause_width - @loop_btn.width * 0.25) / 2  # Align with the pause button
          random_y = pause_y + pause_height + element_spacing  # Place it right under the pause button
          random_width = @loop_btn.width * 0.25  # Scale down the random button to 0.25
          random_height = @loop_btn.height * 0.25
  
          # Check if the play button is clicked
          if mouse_over?(play_x, play_y, play_width, play_height)
            if !@playing && @current_song
              @current_song.play(true)  # Ensure the song resumes from the paused position
              @playing = true
              puts "Resuming song"
            end
          end
  
          # Check if the pause button is clicked
          if mouse_over?(pause_x, pause_y, pause_width, pause_height)
            if @playing && @current_song
              @current_song.pause
              @playing = false
              puts "Pausing song"
            end
          end
  
          # Check if the backward button is clicked
          if mouse_over?(backward_x, backward_y, backward_width, backward_height)
            if @current_song
              @current_song_index -= 1
              if @current_song_index < 0
                @current_song_index = @selected_album[:songs].size - 1  # Wrap around to the last song
              end
              @current_song = Gosu::Song.new(@selected_album[:song_paths][@current_song_index])
              @current_song.play
              @playing = true
              puts "Playing previous song: #{@selected_album[:songs][@current_song_index]}"
            end
          end
  
          # Check if the forward button is clicked
          if mouse_over?(forward_x, forward_y, forward_width, forward_height)
            if @current_song
              @current_song_index += 1
              if @current_song_index >= @selected_album[:songs].size
                @current_song_index = 0  # Wrap around to the first song
              end
              @current_song = Gosu::Song.new(@selected_album[:song_paths][@current_song_index])
              @current_song.play
              @playing = true
              puts "Playing next song: #{@selected_album[:songs][@current_song_index]}"
            end
          end
  
          # Check if the loop button is clicked
          if mouse_over?(loop_x, loop_y, loop_width, loop_height)
            @loop_enabled = !@loop_enabled  # Toggle the loop state
            update_loop_button_state
          end

          # Check if the random button is clicked
          if mouse_over?(random_x, random_y, random_width, random_height)
            play_random_song
          end
        end
      end
    end
  end


  def button_up(id)
    if id == Gosu::MS_LEFT
      # Reset any flags or states if needed
    end
  end
   def draw
    if @current_view == :main_menu
      draw_main_menu
    elsif @current_view == :album_view
      draw_album_view
    end
  end

  def draw_main_menu
    @background_image.draw(0, 0, 0)
    @font.draw_text(@title, (width - @font.text_width(@title)) / 2, 150, 1, 1.0, 1.0, Gosu::Color::WHITE)

    start_x = (width - (@albums.size * @album_width + (@albums.size - 1) * 50)) / 2

    @albums.each_with_index do |album, index|
      x = start_x + index * (@album_width + 50)
      y = (height / 2) - (@album_height / 2) - 400

      if mouse_over?(x, y, @album_width, @album_height)
        draw_border(x, y, @album_width, @album_height, Gosu::Color::CYAN)
        title_x = x + (@album_width - @album_font.text_width(album[:title])) / 2
        title_y = y + @album_height + 10
        draw_border(title_x, title_y, @album_font.text_width(album[:title]), @album_font.height, Gosu::Color::CYAN)
      end

      album[:image].draw(x, y, 1, @album_width.to_f / album[:image].width, @album_height.to_f / album[:image].height)
      @album_font.draw_text(album[:title], x + (@album_width - @album_font.text_width(album[:title])) / 2, y + @album_height + 10, 1, 1.0, 1.0, Gosu::Color::WHITE)
    end

    middle_x = (width - @middle_image.width) / 2
    middle_y = (height / 2) - (@middle_image.height / 2) + 500
    @middle_image.draw(middle_x, middle_y, 1)
  end

  def draw_album_view
    if @selected_album
      scale_x = width.to_f / @selected_album[:background].width
      scale_y = height.to_f / @selected_album[:background].height
      scale_factor = [scale_x, scale_y].min
      scaled_width = (@selected_album[:background].width * scale_factor).to_i
      scaled_height = (@selected_album[:background].height * scale_factor).to_i
      offset_x = (width - scaled_width) / 2
      offset_y = (height - scaled_height) / 2
      @selected_album[:background].draw(offset_x, offset_y, 0, scale_factor, scale_factor)
      
      album_image_x = (width - @album_width * 1.5) / 2
      album_image_y = 300
      @selected_album[:image].draw(album_image_x, album_image_y, 1, @album_width.to_f / @selected_album[:image].width * 1.5, @album_height.to_f / @selected_album[:image].height * 1.5)
      
      artist_y = album_image_y - 100
      @album_font.draw_text(@selected_album[:artist], (width - @album_font.text_width(@selected_album[:artist])) / 2, artist_y, 1, 1.0, 1.0, Gosu::Color::RED)
      
      track_box_x = (width - @track_box_image.width * 3) / 2
      track_box_y = (height / 2) + @album_height / 2 - 150
      track_box_height = @track_box_image.height * 3 + 350  # Decrease the height of the track box to cover the buttons below it
      @track_box_image.draw(track_box_x, track_box_y, 1, 3, track_box_height.to_f / @track_box_image.height)
      
      track_box_title_y = track_box_y + 20
      @album_font.draw_text(@selected_album[:title], (width - @album_font.text_width(@selected_album[:title])) / 2, track_box_title_y, 1, 1.0, 1.0, Gosu::Color::CYAN)
      
      @selected_album[:songs].each_with_index do |song, index|
        song_x = (width - @song_font.text_width(song)) / 2
        song_y = track_box_y + 100 + index * 60
        color = mouse_over?(song_x, song_y, @song_font.text_width(song), @song_font.height) ? Gosu::Color::YELLOW : Gosu::Color::WHITE
        @song_font.draw_text(song, song_x, song_y, 1, 1.0, 1.0, color)
      end
  
      # Draw new elements below the track box
      controls_y = track_box_y + @track_box_image.height * 3 + 60  # Move elements down by 60 pixels
      element_spacing = 40  # Increase spacing for better visual arrangement
      total_width = @backward_btn.width * 3 + @play_btn.width * 3 + @pause_btn.width * 3 + @forward_btn.width * 3 + element_spacing * 3
      start_x = (width - total_width) / 2
  
      # Define the exact coordinates and dimensions for the play button
      play_x = (width - @play_btn.width * 3) / 2 - 50  # Move 50 pixels to the left
      play_y = controls_y
      play_width = @play_btn.width * 3
      play_height = @play_btn.height * 3
  
      # Draw backward button
      if mouse_over?(start_x, controls_y, @backward_btn.width * 3, @backward_btn.height * 3)
        @backward_btn_hover.draw(start_x, controls_y, 1, 3, 3)
      else
        @backward_btn.draw(start_x, controls_y, 1, 3, 3)
      end
  
      # Draw play button
      play_x = start_x + @backward_btn.width * 3 + element_spacing
      if mouse_over?(play_x, controls_y, @play_btn.width * 3, @play_btn.height * 3)
        @play_btn_hover.draw(play_x, controls_y, 1, 3, 3)
      else
        @play_btn.draw(play_x, controls_y, 1, 3, 3)
      end
  
      # Draw pause button
      pause_x = play_x + @play_btn.width * 3 + element_spacing
      pause_y = controls_y  # Define pause_y
      pause_width = @pause_btn.width * 3
      pause_height = @pause_btn.height * 3
      if mouse_over?(pause_x, pause_y, pause_width, pause_height)
        @pause_btn_hover.draw(pause_x, pause_y, 1, 3, 3)
      else
        @pause_btn.draw(pause_x, pause_y, 1, 3, 3)
      end
  
      # Draw forward button
      forward_x = pause_x + pause_width + element_spacing
      if mouse_over?(forward_x, controls_y, @forward_btn.width * 3, @forward_btn.height * 3)
        @forward_btn_hover.draw(forward_x, controls_y, 1, 3, 3)
      else
        @forward_btn.draw(forward_x, controls_y, 1, 3, 3)
      end
  
      # Draw loop button
      loop_x = play_x + (play_width - @loop_btn.width * 0.25) / 2
      loop_y = play_y + play_height + element_spacing  # Place it right under the play button
      @loop_btn.draw(loop_x, loop_y, 1, 0.25, 0.25)  # Scale down the loop button to 0.25
      if @loop_enabled
        draw_border(loop_x, loop_y, @loop_btn.width * 0.25, @loop_btn.height * 0.25, Gosu::Color::CYAN)
      end
  
      # Draw random button
      random_x = pause_x + (pause_width - @random_btn.width * 0.5) / 2
      random_y = pause_y + pause_height + element_spacing  # Place it right under the pause button
      if mouse_over?(random_x, random_y, @random_btn.width * 0.5, @random_btn.height * 0.5)
        @random_btn.draw(random_x, random_y, 1, 0.5, 0.5)
      else
        @random_btn.draw(random_x, random_y, 1, 0.5, 0.5)
      end
  
      # Draw home button
      if mouse_over?(home_button_x, home_button_y, @home_button_image.width * 7, @home_button_image.height * 7)
        @home_button_image.draw(home_button_x, home_button_y, 1, 7, 7)
        @button_font.draw_text("Back", back_text_x, back_text_y, 1, 1.0, 1.0, Gosu::Color::WHITE)
      else
        @home_button_hover_image.draw(home_button_x, home_button_y, 1, 7, 7)
        @button_font.draw_text("Back", back_text_x, back_text_y, 1, 1.0, 1.0, Gosu::Color::CYAN)
      end
    end
  end
  def draw_border(x, y, width, height, color)
    draw_line(x, y, color, x + width, y, color, 2)
    draw_line(x, y, color, x, y + height, color, 2)
    draw_line(x + width, y, color, x + width, y + height, color, 2)
    draw_line(x, y + height, color, x + width, y + height, color, 2)
  end 
  def update_loop_button_state
    if @loop_enabled
      start_song_looping if @current_song
    else
      stop_song_looping if @current_song
    end
  end

  def start_song_looping
    # Set up the song to loop
    @current_song.play(true)
  end
  
  def stop_song_looping
    # Stop the song from looping
    @current_song.play(false)
  end

  def update
    super
    check_song_finished if @playing && @loop_enabled
  end

  def check_song_finished
    if @current_song && !@current_song.playing?
      @current_song.play(true)
    end
  end
  def play_random_song
    random_index = rand(@selected_album[:songs].size)
    @current_song_index = random_index
    @current_song = Gosu::Song.new(@selected_album[:song_paths][random_index])
    @current_song.play
    @playing = true
    puts "Playing random song: #{@selected_album[:songs][random_index]}"
  end
  def home_button_x
    0
  end

  def home_button_y
    0
  end

  def back_text_x
    @home_button_image.width * 7 + 10
  end

  def back_text_y
    @home_button_image.height * 3
  end

  def mouse_over?(x, y, width, height)
    mouse_x >= x && mouse_x <= x + width && mouse_y >= y && mouse_y <= y + height
  end

  def draw_border(x, y, width, height, color)
    draw_line(x, y, color, x + width, y, color, 2)
    draw_line(x, y, color, x, y + height, color, 2)
    draw_line(x + width, y, color, x + width, y + height, color, 2)
    draw_line(x, y + height, color, x + width, y + height, color, 2)
  end
end

window = MusicPlayerWindow.new
window.show
