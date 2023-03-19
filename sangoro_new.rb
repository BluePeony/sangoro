require 'gtk3'
require 'fileutils'
require 'fastimage'
require 'mini_exiftool'

class Interface

	def initialize
		@hour_set = false
		@min_set = false
		@sec_set = false
		@new_hour_val = 0
		@new_min_val = 0
		@new_sec_val = 0
		@new_hour_ent = Gtk::Entry.new
		@new_hour_ent.set_max_length(2)
		@new_hour_ent.set_width_chars(5)
		@new_min_ent = Gtk::Entry.new
		@new_min_ent.set_max_length(2)
		@new_min_ent.set_width_chars(5)
		@new_sec_ent = Gtk::Entry.new
		@new_sec_ent.set_max_length(2)
		@new_sec_ent.set_width_chars(5)
		@photo = MiniExiftool.new()
		@success_label = Gtk::Label.new()

		# define the window, the boxes and the buttons
		define_window
		define_boxes
		define_buttons

	end

	# define the window
	def define_window
		@window = Gtk::Window.new
		@window.title = "sangoro"
		@window.border_width = 20
		@window.signal_connect("destroy") {
			Gtk.main_quit
			false
		}
	end

	# define the individual boxes
	def define_boxes
		@apply_cancel_box = Gtk::Box.new(:horizontal, 0)
		@for_back_box = Gtk::Box.new(:vertical, 0)
		@forward_back_box = Gtk::Box.new(:vertical, 0)
		@img_name_box = Gtk::Box.new(:horizontal, 0)
		@img_name_time_box = Gtk::Box.new(:vertical, 0)
		@img_time_box = Gtk::Box.new(:horizontal, 0)
		@main_box = Gtk::Box.new(:vertical, 0)
		@meta_data_box = Gtk::Box.new(:vertical, 0)
		@new_time_box = Gtk::Box.new(:horizontal, 0)
		@select_box = Gtk::Box.new(:horizontal, 0)
	end

	# define all necessary buttons
	def define_buttons
		@apply_all_btn = Gtk::CheckButton.new("apply to all images in the folder accordingly")
		@forward_btn = Gtk::RadioButton.new(:label => "forward")
		@backward_btn = Gtk::RadioButton.new(:label => "back", :member => @forward_btn)
		@select_img_btn = Gtk::Button.new(:label => "Select image", :use_underline => nil, :stock_id => nil)
		@apply_btn = Gtk::Button.new(:label => "Apply", :use_underline => nil, :stock_id => nil)
		@quit_btn = Gtk::Button.new(:label => "Quit", :use_underline => nil, :stock_id => nil)

	end

	def toggle_btn_sensitivity(sensitive_mode)
		@apply_all_btn.sensitive = sensitive_mode
		@forward_btn.sensitive = sensitive_mode
		@backward_btn.sensitive = sensitive_mode
		@apply_btn.sensitive = sensitive_mode
		@new_hour_ent.sensitive = sensitive_mode
		@new_min_ent.sensitive = sensitive_mode
		@new_sec_ent.sensitive = sensitive_mode
	end

	# define the actions for the SELECT button
	def run_select_action(img_name_text, img_time_text)
		@hour_set = false
		@min_set = false
		@sec_set = false
		@new_hour_ent.set_text("")
		@new_min_ent.set_text("")
		@new_sec_ent.set_text("")
		@apply_all_btn.set_active(false)
		@forward_btn.set_active(true)
		@success_label.set_markup("<span font_desc='0'>Creation time successfully changed!</span>")
		dialog = Gtk::FileChooserDialog.new(:title => "select image", :parent => @window, :action => Gtk::FileChooserAction::OPEN, 
		:buttons => [[Gtk::Stock::OPEN, Gtk::ResponseType::ACCEPT], [Gtk::Stock::CANCEL, Gtk::ResponseType::CANCEL]])

		# process the selected image
		if dialog.run == Gtk::ResponseType::ACCEPT
			selected_file = dialog.filename
			@photo = MiniExiftool.new(selected_file)
			img_name_text.set_text("                         #{File.basename(selected_file)}")
			if @photo.datetimeoriginal
				img_time_text.set_text("   #{@photo.datetimeoriginal.to_s}")
				toggle_btn_sensitivity(true)
			else
				img_time_text.set_text("   No creation time available")
				toggle_btn_sensitivity(false)
				@success_label.set_markup("<span font_desc='13' color='orange'>The original creation timestamp could not be detected. Therefore, it is not possible to change the timestamp.</span>")
			end

			dialog.destroy

			return [selected_file, img_name_text, img_time_text]
		end
	end

	# prepare the box for the original meta data of an image
	def prepare_orig_meta(label_text, box)
		label = Gtk::Label.new("#{label_text}: ")
		text = Gtk::Label.new(" --")
		box.pack_start(label, :expand => false, :fill => false, :padding => 0)
		box.pack_start(text, :expand => false, :fill => false, :padding => 10)
		return [label, text]
	end

	# process the time shift entered by the user
	def process_time_unit(time_ent)
		new_time = []
		single_digits = ["00", "01", "02", "03", "04", "05", "06", "07", "08", "09"]
		if (time_ent.text.to_i.to_s == time_ent.text) || single_digits.include?(time_ent.text)
			new_time << time_ent.text.to_i
			new_time << true
		else
			time_ent.set_text("")
		end
		return new_time
	end

	# define the actions for the ACCEPT button		
	def run_accept_action(img_time_text, selected_file)
		count = 0
		time_diff = 0
		image_wording = "image"
		if @hour_set
			time_diff += @new_hour_val*3600
		end
		if @min_set
			time_diff += @new_min_val*60
		end
		if @sec_set 
			time_diff += @new_sec_val
		end

		if @backward_btn.active?
			time_diff *= -1
		end

		# apply the new time for the selected image only
		if !@apply_all_btn.active?
			count = change_time_single(time_diff, count, img_time_text) 
		# apply the new time for all images in the folder
		else
			count = change_time_all(selected_file, time_diff, count, img_time_text) 	
			image_wording = "images" if count > 1		
		end

		@success_label.set_markup("<span font_desc='13' color='green'>Creation time successfully changed! #{count} #{image_wording} affected.</span>")
	end

	#change the creation time for a single image
	def change_time_single(time_difference, count, img_time_text)
		if @photo.datetimeoriginal 
			@photo.datetimeoriginal += time_difference
			img_time_text.set_markup("<span color='green'>   #{@photo.datetimeoriginal.to_s} </span>")
			count += 1
		end
		if @photo.createdate
			@photo.createdate += time_difference
		end	
		if @photo.save	
			puts "We did it!"
		end
		
		return count	
	end

	# change the creation time for all images in the folder
	def change_time_all(selected_file, time_difference, count, img_time_text)
		dir_path = File.dirname(selected_file)
		all_images = []
		all_entries = Dir.entries(dir_path)
		all_entries.each do |el|
			el.downcase!
			if el.include?(".jpg") || el.include?(".jpeg")
				all_images << el
			end
		end
		
		all_images.each do |im|
			miniexif_img = MiniExiftool.new("#{dir_path}/#{im}")
			if miniexif_img.datetimeoriginal
				miniexif_img.datetimeoriginal += time_difference
				count += 1
			end
			if miniexif_img.createdate
				miniexif_img.createdate += time_difference 
			end	
			miniexif_img.save
			if im == File.basename(selected_file)
				img_time_text.set_markup("<span color='green'>   #{miniexif_img.datetimeoriginal.to_s} </span>")
			end
		end
		return count
	end


	# packs all the boxes
	def pack_boxes
		
		# pack the SELECT box
		select_align = Gtk::Alignment.new 0,0,0,0
		@select_box.pack_start(@select_img_btn, :expand => false, :fill => true, :padding => 0)
		@select_box.pack_start(select_align, :expand => true, :fill => true, :padding => 0)
		@select_box.pack_start(@img_name_time_box, :expand => true, :fill => true, :padding => 0)

		# pack the FORWARD/BACK box
		@for_back_box.pack_start(@forward_btn, :expand => true, :fill => true, :padding => 0)
		@for_back_box.pack_start(@backward_btn, :expand => true, :fill => true, :padding => 0)

		# pack the new time box
		move_time_label = Gtk::Label.new("move the creation time ")
		new_hour_label = Gtk::Label.new("h ")
		new_min_label = Gtk::Label.new("min ")
		new_sec_label = Gtk::Label.new("sec ")
		@new_time_box.pack_start(move_time_label, :expand => true, :fill => true, :padding => 0)
		@new_time_box.pack_start(@new_hour_ent, :expand => true, :fill => true, :padding => 0)
		@new_time_box.pack_start(new_hour_label, :expand => true, :fill => true, :padding => 3)
		@new_time_box.pack_start(@new_min_ent, :expand => true, :fill => true, :padding => 0)
		@new_time_box.pack_start(new_min_label, :expand => true, :fill => true, :padding => 3)
		@new_time_box.pack_start(@new_sec_ent, :expand => true, :fill => true, :padding => 0)
		@new_time_box.pack_start(new_sec_label, :expand => true, :fill => true, :padding => 3)
		@new_time_box.pack_start(@for_back_box, :expand => true, :fill => true, :padding => 10)

		# pack the meta_change_box
		@meta_data_box.pack_start(@select_box, :expand => true, :fill => true, :padding => 0)
		@meta_data_box.pack_start(@new_time_box, :expand => true, :fill => true, :padding => 20)
		@meta_data_box.pack_start(@apply_all_btn, :expand => true, :fill => true, :padding => 0)
		@meta_data_box.pack_start(@success_label, :expand => true, :fill => true, :padding => 5)

		# pack the @apply_cancel_box
		apply_align = Gtk::Alignment.new 0, 0, 0, 0
		@apply_cancel_box.pack_start(apply_align, :expand => true, :fill => true, :padding => 0) 
		@apply_cancel_box.pack_start(@quit_btn, :expand => false, :fill => true, :padding => 5)
		@apply_cancel_box.pack_start(@apply_btn, :expand => false, :fill => true, :padding => 5)

		# pack the main box
		@main_box.pack_start(@meta_data_box, :expand => false, :fill => true, :padding => 0)
		@main_box.pack_start(@apply_cancel_box, :expand => false, :fill => true, :padding => 0)
	end

	# main method - shows the window with all the buttons and abilities to select images and change meta data
	def run		

		@window.add(@main_box)

		# prepare meta data for the chosen image - file name and original creation time
		img_name_label, img_name_text = prepare_orig_meta("file name", @img_name_box)
		img_time_label, img_time_text = prepare_orig_meta("creation date & time", @img_time_box)

		@img_name_time_box.pack_start(@img_name_box, :expand => true, :fill => true, :padding => 0)
		@img_name_time_box.pack_start(@img_time_box, :expand=> true, :fill => true, :padding => 0)

		# execute the action for the SELECT button
		selected_file = ""		
		@select_img_btn.signal_connect("clicked") { 
			selected_file, img_name_text, img_time_text = run_select_action(img_name_text, img_time_text) 
		}

		# define new time - process the input for the new hour, minutes and seconds
		 @new_hour_ent.signal_connect("key_release_event") {
		 	@new_hour_val, @hour_set = process_time_unit(@new_hour_ent)			
		 }

		@new_min_ent.signal_connect("key_release_event") {
			@new_min_val, @min_set = process_time_unit(@new_min_ent)
		}		

		@new_sec_ent.signal_connect("key_release_event") {
			@new_sec_val, @sec_set = process_time_unit(@new_sec_ent)
		}
		

		# execute the action when the the ACCEPT button is clicked
		@apply_btn.signal_connect("clicked") { 
			run_accept_action(img_time_text, selected_file) 
		}

		# define the action for the QUIT button
		@quit_btn.signal_connect("clicked") do |w| 
			Gtk.main_quit
			false
		end

		# pack all the boxes
		pack_boxes

		# show everything
		@window.show_all

		# run the program
		Gtk.main
	end

end
