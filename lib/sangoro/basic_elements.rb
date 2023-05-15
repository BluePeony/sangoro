module Sangoro
  module BasicElements

    # define the parameters of the image
    def self.define_img_parameters
      img_parameters = {
        hour_set: false,
        min_set: false,
        sec_set: false,
        new_hour_val: 0,
        new_min_val: 0,
        new_sec_val: 0,
        new_hour_ent: Gtk::Entry.new,      
        new_min_ent: Gtk::Entry.new,      
        new_sec_ent: Gtk::Entry.new,      
        photo: MiniExiftool.new(), 
        success_label: Gtk::Label.new()
      }

      img_parameters[:new_hour_ent].set_max_length(2)
      img_parameters[:new_hour_ent].set_width_chars(5)
      img_parameters[:new_min_ent].set_max_length(2)
      img_parameters[:new_min_ent].set_width_chars(5)
      img_parameters[:new_sec_ent].set_max_length(2)
      img_parameters[:new_sec_ent].set_width_chars(5)

      return img_parameters
    end

    # define the window
    def self.define_window
      window = Gtk::Window.new
      window.title = "sangoro"
      window.border_width = 20
      window.signal_connect("destroy") {
        Gtk.main_quit
        false
      }

      return window
    end

    # define the individual boxes
    def self.define_boxes 

      return {
        apply_cancel_box: Gtk::Box.new(:horizontal, 0),
        for_back_box: Gtk::Box.new(:vertical, 0),
        forward_back_box: Gtk::Box.new(:vertical, 0),
        img_name_box: Gtk::Box.new(:horizontal, 0),
        img_name_time_box: Gtk::Box.new(:vertical, 0),
        img_time_box: Gtk::Box.new(:horizontal, 0),
        main_box: Gtk::Box.new(:vertical, 0),
        meta_data_box: Gtk::Box.new(:vertical, 0),
        new_time_box: Gtk::Box.new(:horizontal, 0),
        select_box: Gtk::Box.new(:horizontal, 0)
      }
      
    end

    # define all necessary buttons
    def self.define_buttons
      apply_all_btn = Gtk::CheckButton.new("apply to all images in the folder accordingly")
      forward_btn = Gtk::RadioButton.new(:label => "forward")
      backward_btn = Gtk::RadioButton.new(:label => "back", :member => forward_btn)
      select_img_btn = Gtk::Button.new(:label => "Select image", :use_underline => nil, :stock_id => nil)
      apply_btn = Gtk::Button.new(:label => "Apply", :use_underline => nil, :stock_id => nil)
      quit_btn = Gtk::Button.new(:label => "Quit", :use_underline => nil, :stock_id => nil)

      return {apply_all_btn: apply_all_btn, forward_btn: forward_btn, backward_btn: backward_btn, select_img_btn: select_img_btn, apply_btn: apply_btn, quit_btn: quit_btn }
    end

  end
end