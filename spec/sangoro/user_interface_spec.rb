require 'gtk3'
require 'fileutils'
require 'fastimage'
require 'mini_exiftool'
require 'sangoro/user_interface'
require 'sangoro/basic_elements'
require 'sangoro/actions'

module Sangoro
  describe UserInterface do

    before do 
      @interface = UserInterface.new
    end

    it "checks the title of the window" do
      expect(@interface.window.title).to eq "sangoro"
    end

    it "checks that the following buttons are deactivated at the beginning" do 
      expect(@interface.button_set[:apply_all_btn].sensitive?).to eq false
      expect(@interface.button_set[:forward_btn].sensitive?).to eq false
      expect(@interface.button_set[:backward_btn].sensitive?).to eq false
      expect(@interface.button_set[:apply_btn].sensitive?).to eq false
      expect(@interface.img_parameters[:new_hour_ent].sensitive?).to eq false
      expect(@interface.img_parameters[:new_min_ent].sensitive?).to eq false
      expect(@interface.img_parameters[:new_sec_ent].sensitive?).to eq false
    end

    it "checks the label and the placeholder for the file name" do 
      img_name_label, img_name_text = Actions.prepare_orig_meta("file name", @interface.box_set[:img_name_box])
      expect(img_name_label.label).to eq "file name: "
      expect(img_name_text.label).to eq " --"
    end

    it "checks the label and the placeholder for the original creation time stamp" do
      img_time_label, img_time_text = Actions.prepare_orig_meta("creation date & time", @interface.box_set[:img_time_box])
      expect(img_time_label.label).to eq "creation date & time: "
      expect(img_time_text.label).to eq " --"
    end 
  end
end