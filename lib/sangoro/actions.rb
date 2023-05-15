module Sangoro
  module Actions

    # toggles the sensitivity between active and inactive
    def self.toggle_sensitivity(button_set, img_parameters, sensitive_mode)
      button_set[:apply_all_btn].sensitive = sensitive_mode
      button_set[:forward_btn].sensitive = sensitive_mode
      button_set[:backward_btn].sensitive = sensitive_mode
      button_set[:apply_btn].sensitive = sensitive_mode
      img_parameters[:new_hour_ent].sensitive = sensitive_mode
      img_parameters[:new_min_ent].sensitive = sensitive_mode
      img_parameters[:new_sec_ent].sensitive = sensitive_mode

      return [button_set, img_parameters]
    end

    # prepare the box for the original meta data of an image
    def self.prepare_orig_meta(label_text, box)
      label = Gtk::Label.new("#{label_text}: ")
      text = Gtk::Label.new(" --")
      box.pack_start(label, :expand => false, :fill => false, :padding => 0)
      box.pack_start(text, :expand => false, :fill => false, :padding => 10)
      return [label, text]
    end

    # define the actions for the SELECT button
    def self.run_select_action(window, img_parameters, button_set, img_name_text, img_time_text)
      img_parameters[:hour_set] = false
      img_parameters[:min_set] = false
      img_parameters[:sec_set] = false
      img_parameters[:new_hour_ent].set_text("")
      img_parameters[:new_min_ent].set_text("")
      img_parameters[:new_sec_ent].set_text("")
      button_set[:apply_all_btn].set_active(false)
      button_set[:forward_btn].set_active(true)
      img_parameters[:success_label].set_markup("<span font_desc='0'>Creation time successfully changed!</span>")
      dialog = Gtk::FileChooserDialog.new(:title => "select image", :parent => window, :action => Gtk::FileChooserAction::OPEN, 
      :buttons => [[Gtk::Stock::OPEN, Gtk::ResponseType::ACCEPT], [Gtk::Stock::CANCEL, Gtk::ResponseType::CANCEL]])

      # process the selected image
      if dialog.run == Gtk::ResponseType::ACCEPT
        selected_file = dialog.filename
        img_parameters[:photo] = MiniExiftool.new(selected_file)
        img_name_text.set_text("                         #{File.basename(selected_file)}")
        if img_parameters[:photo].datetimeoriginal
          img_time_text.set_text("   #{img_parameters[:photo].datetimeoriginal.to_s}")
          button_set, img_parameters = toggle_sensitivity(button_set, img_parameters, true)
        else
          img_time_text.set_text("   No creation time available")
          button_set, img_parameters = toggle_sensitivity(button_set, img_parameters, false)
          img_parameters[:success_label].set_markup("<span font_desc='13' color='orange'>The original creation timestamp could not be detected. Therefore, it is not possible to change the timestamp.</span>")
        end

        dialog.destroy

        return [selected_file, img_name_text, img_time_text]
      end
    end

    # process the time shift entered by the user
    def self.process_time_unit(time_ent)
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
    def self.run_accept_action(img_parameters, button_set, img_time_text, selected_file)
      count = 0
      time_diff = 0
      image_wording = "image"
      if img_parameters[:hour_set]
        time_diff += img_parameters[:new_hour_val]*3600
      end
      if img_parameters[:min_set]
        time_diff += img_parameters[:new_min_val]*60
      end
      if img_parameters[:sec_set] 
        time_diff += img_parameters[:new_sec_val]
      end

      if button_set[:backward_btn].active?
        time_diff *= -1
      end

      # apply the new time for the selected image only
      if !button_set[:apply_all_btn].active?
        count = change_time_single(img_parameters, time_diff, count, img_time_text) 
      # apply the new time for all images in the folder
      else
        count = change_time_all(selected_file, time_diff, count, img_time_text)   
        image_wording = "images" if count > 1   
      end

      img_parameters[:success_label].set_markup("<span font_desc='13' color='green'>Creation time successfully changed! #{count} #{image_wording} affected.</span>")
    end

    #change the creation time for a single image
    def self.change_time_single(img_parameters, time_difference, count, img_time_text)
      if img_parameters[:photo].datetimeoriginal 
        img_parameters[:photo].datetimeoriginal += time_difference
        img_time_text.set_markup("<span color='green'>   #{img_parameters[:photo].datetimeoriginal.to_s} </span>")
        count += 1
      end
      if img_parameters[:photo].createdate
        img_parameters[:photo].createdate += time_difference
      end 
      img_parameters[:photo].save      
      return count  
    end

    # change the creation time for all images in the folder
    def self.change_time_all(selected_file, time_difference, count, img_time_text)
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
        if im.downcase == File.basename(selected_file).downcase
          img_time_text.set_markup("<span color='green'>   #{miniexif_img.datetimeoriginal.to_s} </span>")
        end
      end
      return count
    end

    # packs all the boxes
    def self.pack_boxes(box_set, button_set, img_parameters)
      
      # pack the SELECT box
      select_align = Gtk::Alignment.new 0,0,0,0
      box_set[:select_box].pack_start(button_set[:select_img_btn], :expand => false, :fill => true, :padding => 0)
      box_set[:select_box].pack_start(select_align, :expand => true, :fill => true, :padding => 0)
      box_set[:select_box].pack_start(box_set[:img_name_time_box], :expand => true, :fill => true, :padding => 0)

      # pack the FORWARD/BACK box
      box_set[:for_back_box].pack_start(button_set[:forward_btn], :expand => true, :fill => true, :padding => 0)
      box_set[:for_back_box].pack_start(button_set[:backward_btn], :expand => true, :fill => true, :padding => 0)

      # pack the new time box
      move_time_label = Gtk::Label.new("move the creation time ")
      new_hour_label = Gtk::Label.new("h ")
      new_min_label = Gtk::Label.new("min ")
      new_sec_label = Gtk::Label.new("sec ")
      box_set[:new_time_box].pack_start(move_time_label, :expand => true, :fill => true, :padding => 0)
      box_set[:new_time_box].pack_start(img_parameters[:new_hour_ent], :expand => true, :fill => true, :padding => 0)
      box_set[:new_time_box].pack_start(new_hour_label, :expand => true, :fill => true, :padding => 3)
      box_set[:new_time_box].pack_start(img_parameters[:new_min_ent], :expand => true, :fill => true, :padding => 0)
      box_set[:new_time_box].pack_start(new_min_label, :expand => true, :fill => true, :padding => 3)
      box_set[:new_time_box].pack_start(img_parameters[:new_sec_ent], :expand => true, :fill => true, :padding => 0)
      box_set[:new_time_box].pack_start(new_sec_label, :expand => true, :fill => true, :padding => 3)
      box_set[:new_time_box].pack_start(box_set[:for_back_box], :expand => true, :fill => true, :padding => 10)

      # pack the meta_change_box
      box_set[:meta_data_box].pack_start(box_set[:select_box], :expand => true, :fill => true, :padding => 0)
      box_set[:meta_data_box].pack_start(box_set[:new_time_box], :expand => true, :fill => true, :padding => 20)
      box_set[:meta_data_box].pack_start(button_set[:apply_all_btn], :expand => true, :fill => true, :padding => 0)
      box_set[:meta_data_box].pack_start(img_parameters[:success_label], :expand => true, :fill => true, :padding => 5)

      # pack the @apply_cancel_box
      apply_align = Gtk::Alignment.new 0, 0, 0, 0
      box_set[:apply_cancel_box].pack_start(apply_align, :expand => true, :fill => true, :padding => 0) 
      box_set[:apply_cancel_box].pack_start(button_set[:quit_btn], :expand => false, :fill => true, :padding => 5)
      box_set[:apply_cancel_box].pack_start(button_set[:apply_btn], :expand => false, :fill => true, :padding => 5)

      # pack the main box
      box_set[:main_box].pack_start(box_set[:meta_data_box], :expand => false, :fill => true, :padding => 0)
      box_set[:main_box].pack_start(box_set[:apply_cancel_box], :expand => false, :fill => true, :padding => 0)
    end

  end
end