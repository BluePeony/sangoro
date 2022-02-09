# Sangoro
A ruby script to change the time stamp of JPEG creation

# Installation
Following needs to be installed prior to running the script:
- ruby (v >= 2.3.3)

Gems:
- gtk3 (```gem install gtk3```)
- fileutils (```gem install fileutils```)
- fast_image (```gem install fast_image```)
- mini_exiftool (```gem install mini_exiftool```)

After the you installed ruby and the gems, clone this repo to your local computer via 
```git clone https://github.com/BluePeony/sangoro.git```
Now you can just run ```ruby /path-to-your-local-sangoro/sangoro.rb``` in your command line.

#Usage
1. Select a JPEG file by clicking on "Select image"
2. You will see the file name and the creation date & time on the right side, if available.
3. Now you can specify by how many hours, minutes and/or seconds you want the time stamp to move. You also need to choose whether to move the timestamp forward or back.
4. If you want to apply this change to all JPEGs in the folder, check the box below.
5. Click "Apply". 
6. You are done. The creation timestamp of the selected image(s) was adjusted as specified.
