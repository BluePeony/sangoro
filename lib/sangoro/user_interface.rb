require 'gtk3'
require 'fileutils'
require 'fastimage'
require 'mini_exiftool'
require_relative 'basic_elements'
require_relative 'actions'

module Sangoro

	class UserInterface
		attr_reader :window, :button_set, :img_parameters, :box_set

		def initialize

			# initialize parameters for the image
			@img_parameters = BasicElements.define_img_parameters

			# define the window, the boxes and the buttons
			@window = BasicElements.define_window
			@box_set = BasicElements.define_boxes
			@button_set = BasicElements.define_buttons
			@button_set, @img_parameters = Actions.toggle_sensitivity(@button_set, @img_parameters, false)

		end

		# main method - shows the window with all the buttons and abilities to select images and change meta data
		def run		

			@window.add(@box_set[:main_box])

			# prepare meta data for the chosen image - file name and original creation time
			img_name_label, img_name_text = Actions.prepare_orig_meta("file name", @box_set[:img_name_box])
			img_time_label, img_time_text = Actions.prepare_orig_meta("creation date & time", @box_set[:img_time_box])

			@box_set[:img_name_time_box].pack_start(@box_set[:img_name_box], :expand => true, :fill => true, :padding => 0)
			@box_set[:img_name_time_box].pack_start(@box_set[:img_time_box], :expand=> true, :fill => true, :padding => 0)

			# execute the action for the SELECT button
			selected_file = ""		
			@button_set[:select_img_btn].signal_connect("clicked") { 
				selected_file, img_name_text, img_time_text = Actions.run_select_action(window, @img_parameters, @button_set, img_name_text, img_time_text) 
			}

			# define new time - process the input for the new hour, minutes and seconds
			 @img_parameters[:new_hour_ent].signal_connect("key_release_event") {
			 	@img_parameters[:new_hour_val], @img_parameters[:hour_set] = Actions.process_time_unit(@img_parameters[:new_hour_ent])			
			 }

			@img_parameters[:new_min_ent].signal_connect("key_release_event") {
				@img_parameters[:new_min_val], @img_parameters[:min_set] = Actions.process_time_unit(@img_parameters[:new_min_ent])
			}		

			@img_parameters[:new_sec_ent].signal_connect("key_release_event") {
				@img_parameters[:new_sec_val], @img_parameters[:sec_set] = Actions.process_time_unit(@img_parameters[:new_sec_ent])
			}

			# execute the action when the the ACCEPT button is clicked
			@button_set[:apply_btn].signal_connect("clicked") { 
				Actions.run_accept_action(@img_parameters, @button_set, img_time_text, selected_file) 
			}

			# define the action for the QUIT button
			@button_set[:quit_btn].signal_connect("clicked") do |w| 
				Gtk.main_quit
				false
			end

			# pack all the boxes
			Actions.pack_boxes(@box_set, @button_set, @img_parameters)

			# show everything
			@window.show_all

			# run the program
			Gtk.main
		end

	end
end