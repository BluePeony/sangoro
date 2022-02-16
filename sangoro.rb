require 'gtk3'
require 'fileutils'
require 'fastimage'
require 'mini_exiftool'

#---------------First initialisation of variables---------------
all_images = []
dir_path = ""
hour_set = false
min_set = false
sec_set = false
new_hour_val = 0
new_min_val = 0
new_sec_val = 0
new_hour_ent = Gtk::Entry.new
new_hour_ent.set_max_length(2)
new_hour_ent.set_width_chars(5)
new_min_ent = Gtk::Entry.new
new_min_ent.set_max_length(2)
new_min_ent.set_width_chars(5)
new_sec_ent = Gtk::Entry.new
new_sec_ent.set_max_length(2)
new_sec_ent.set_width_chars(5)
photo = MiniExiftool.new()
selected_file = ""
single_digits = ["00", "01", "02", "03", "04", "05", "06", "07", "08", "09"]
success_label = Gtk::Label.new()
success_label.set_markup("<span font_desc='0'>Creation time successfully changed!</span>")

#---------------Define the fonts---------------
sourcesans = Pango::FontDescription.new('SourceSansPro 12')
asap = Pango::FontDescription.new('Asap 12')
karmilla = Pango::FontDescription.new('Karmilla 12')
prozalibre = Pango::FontDescription.new('ProzaLibre 12')
dosis = Pango::FontDescription.new('Dosis-Regular 12')

#---------------Define the window---------------
window = Gtk::Window.new
window.title = "sangoro"
window.override_font(prozalibre)
window.border_width = 20
window.signal_connect("destroy") {
	Gtk.main_quit
	false
}

#---------------Define the boxes---------------
apply_cancel_box = Gtk::Box.new(:horizontal, 0)
for_back_box = Gtk::Box.new(:vertical, 0)
forward_back_box = Gtk::Box.new(:vertical, 0)
img_name_box = Gtk::Box.new(:horizontal, 0)
img_name_time_box = Gtk::Box.new(:vertical, 0)
img_time_box = Gtk::Box.new(:horizontal, 0)
main_box = Gtk::Box.new(:vertical, 0)
meta_data_box = Gtk::Box.new(:vertical, 0)
new_time_box = Gtk::Box.new(:horizontal, 0)
select_box = Gtk::Box.new(:horizontal, 0)

window.add(main_box)

#---------------Define the FORWARD, BACKWARD and APPLY ALL buttons---------------
apply_all_btn = Gtk::CheckButton.new("apply to all images in the folder accordingly")
forward_btn = Gtk::RadioButton.new(:label => "forward")
backward_btn = Gtk::RadioButton.new(:label => "back", :member => forward_btn)

#---------------Meta data for the chosen image - file name and original creation time---------------
img_name_label = Gtk::Label.new("file name: ")
img_name_text = Gtk::Label.new("                         --")
img_name_label.override_font(prozalibre)
img_name_text.override_font(prozalibre)
img_name_box.pack_start(img_name_label, :expand => false, :fill => false, :padding => 0)
img_name_box.pack_start(img_name_text, :expand => false, :fill => false, :padding => 10)

img_time_label = Gtk::Label.new("creation date & time: ")
img_time_text = Gtk::Label.new("   --")
img_time_label.override_font(prozalibre)
img_time_text.override_font(prozalibre)
img_time_box.pack_start(img_time_label, :expand => false, :fill => false, :padding => 0)
img_time_box.pack_start(img_time_text, :expand => false, :fill => false, :padding => 10)

img_name_time_box.pack_start(img_name_box, :expand => true, :fill => true, :padding => 0)
img_name_time_box.pack_start(img_time_box, :expand=> true, :fill => true, :padding => 0)

#---------------Define the SELECT button---------------
select_img_btn = Gtk::Button.new(:label => "Select image", :use_underline => nil, :stock_id => nil)
select_img_btn.child.override_font(prozalibre)
select_img_btn.signal_connect("clicked") do |w|
	hour_set = false
	min_set = false
	sec_set = false
	new_hour_ent.set_text("")
	new_min_ent.set_text("")
	new_sec_ent.set_text("")
	apply_all_btn.set_active(false)
	forward_btn.set_active(true)
	all_images = []
	success_label.set_markup("<span font_desc='0'>Creation time successfully changed!</span>")
	dialog = Gtk::FileChooserDialog.new(:title => "select image", :parent => window, :action => Gtk::FileChooserAction::OPEN, 
	:buttons => [[Gtk::Stock::OPEN, Gtk::ResponseType::ACCEPT], [Gtk::Stock::CANCEL, Gtk::ResponseType::CANCEL]])

	if dialog.run == Gtk::ResponseType::ACCEPT
		selected_file = dialog.filename
		dir_path = dialog.current_folder
		photo = MiniExiftool.new(selected_file)
		img_name_text.set_text("                         #{File.basename(selected_file)}")
		if photo.datetimeoriginal
			img_time_text.set_text("   #{photo.datetimeoriginal.to_s}")
		else
			img_time_text.set_text("   No creation time available")
		end
		
	end

	dialog.destroy

end

#---------------Define the new time---------------
move_time_label = Gtk::Label.new("move the creation time ")


new_hour_ent.signal_connect("key_release_event") {
	if (new_hour_ent.text.to_i.to_s == new_hour_ent.text) || single_digits.include?(new_hour_ent.text)
		new_hour_val = new_hour_ent.text.to_i
		hour_set = true
	else
		new_hour_ent.set_text("")
	end
	
}
new_hour_label = Gtk::Label.new("h ")

new_min_ent = Gtk::Entry.new
new_min_ent.set_max_length(2)
new_min_ent.set_width_chars(5)
new_min_ent.signal_connect("key_release_event") {
	if (new_min_ent.text.to_i.to_s == new_min_ent.text) || single_digits.include?(new_min_ent.text)
		new_min_val = new_min_ent.text.to_i
		min_set = true
	else
		new_min_ent.set_text("")
	end
	
}
new_min_label = Gtk::Label.new("min ")

new_sec_ent = Gtk::Entry.new
new_sec_ent.set_max_length(2)
new_sec_ent.set_width_chars(5)
new_sec_ent.signal_connect("key_release_event") {
	if (new_sec_ent.text.to_i.to_s == new_sec_ent.text) || single_digits.include?(new_sec_ent.text)
		new_sec_val = new_sec_ent.text.to_i
		sec_set = true
	else
		new_sec_ent.set_text("")
	end
	
}
new_sec_label = Gtk::Label.new("sec ")

#---------------Define the ACCEPT and CANCEL buttons---------------
apply_btn = Gtk::Button.new(:label => "Apply", :use_underline => nil, :stock_id => nil)
apply_btn.child.override_font(prozalibre)
apply_btn.signal_connect("clicked") do |w|
	count = 0
	time_diff = 0
	if hour_set
		time_diff += new_hour_val*3600
	end
	if min_set
		time_diff += new_min_val*60
	end
	if sec_set 
		time_diff += new_sec_val
	end

	if backward_btn.active?
		time_diff *= -1
	end

	if !apply_all_btn.active? #apply for the selected image only
		if photo.datetimeoriginal 
			photo.datetimeoriginal += time_diff
			img_time_text.set_markup("<span color='green'>   #{photo.datetimeoriginal.to_s} </span>")
			count += 1
		end
		if photo.createdate
			photo.createdate += time_diff
		end	
		photo.save	
		
	else # apply for all images in the folder
		all_entries = Dir.entries(dir_path)
		all_entries.each do |el|
			if el.include?(".jpg") || el.include?(".jpeg") || el.include?(".JPG") || el.include?(".JPEG")
				all_images << el
			end
		end
		
		all_images.each do |im|
			miniexif_img = MiniExiftool.new("#{dir_path}/#{im}")
			if miniexif_img.datetimeoriginal
				miniexif_img.datetimeoriginal += time_diff
				count += 1
			end
			if miniexif_img.createdate
				miniexif_img.createdate += time_diff
			end	
			miniexif_img.save
			if im == File.basename(selected_file)
				img_time_text.set_markup("<span color='green'>   #{miniexif_img.datetimeoriginal.to_s} </span>")
			end
		end
	end
	success_label.set_markup("<span font_desc='16' color='green'>Creation time successfully changed! #{count} image(s) affected.</span>")
end

cancel_btn = Gtk::Button.new(:label => "Cancel", :use_underline => nil, :stock_id => nil)
cancel_btn.child.override_font(prozalibre)
cancel_btn.signal_connect("clicked") do |w| 
	Gtk.main_quit
	false
end

#---------------Pack all the boxes---------------

#---------------Pack the SELECT box---------------
select_align = Gtk::Alignment.new 0,0,0,0
select_box.pack_start(select_img_btn, :expand => false, :fill => true, :padding => 0)
select_box.pack_start(select_align, :expand => true, :fill => true, :padding => 0)
select_box.pack_start(img_name_time_box, :expand => true, :fill => true, :padding => 0)

#---------------Pack the FORWARD/BACK box---------------
for_back_box.pack_start(forward_btn, :expand => true, :fill => true, :padding => 0)
for_back_box.pack_start(backward_btn, :expand => true, :fill => true, :padding => 0)

#---------------Pack the new time box---------------
new_time_box.pack_start(move_time_label, :expand => true, :fill => true, :padding => 0)
new_time_box.pack_start(new_hour_ent, :expand => true, :fill => true, :padding => 0)
new_time_box.pack_start(new_hour_label, :expand => true, :fill => true, :padding => 3)
new_time_box.pack_start(new_min_ent, :expand => true, :fill => true, :padding => 0)
new_time_box.pack_start(new_min_label, :expand => true, :fill => true, :padding => 3)
new_time_box.pack_start(new_sec_ent, :expand => true, :fill => true, :padding => 0)
new_time_box.pack_start(new_sec_label, :expand => true, :fill => true, :padding => 3)
new_time_box.pack_start(for_back_box, :expand => true, :fill => true, :padding => 10)

#---------------Pack the meta_change_box---------------
meta_data_box.pack_start(select_box, :expand => true, :fill => true, :padding => 0)
meta_data_box.pack_start(new_time_box, :expand => true, :fill => true, :padding => 20)
meta_data_box.pack_start(apply_all_btn, :expand => true, :fill => true, :padding => 0)
meta_data_box.pack_start(success_label, :expand => true, :fill => true, :padding => 5)

#---------------Pack the apply_cancel_box---------------
apply_align = Gtk::Alignment.new 0, 0, 0, 0
apply_cancel_box.pack_start(apply_align, :expand => true, :fill => true, :padding => 0) 
apply_cancel_box.pack_start(cancel_btn, :expand => false, :fill => true, :padding => 5)
apply_cancel_box.pack_start(apply_btn, :expand => false, :fill => true, :padding => 5)

#---------------Pack the main box---------------
main_box.pack_start(meta_data_box, :expand => false, :fill => true, :padding => 0)
main_box.pack_start(apply_cancel_box, :expand => false, :fill => true, :padding => 0)

#---------------Show everything---------------
window.show_all

#---------------Run the program---------------
Gtk.main