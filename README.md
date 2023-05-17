# Sangoro
A Ruby program to change the exif creation time stamp of JPEGs or PNGs.<br>


# Installation
To use the Sangoro tool you require:
<ul>
  <li> <a href="https://www.ruby-lang.org/en/downloads/"><code>ruby</code></a> (v>=2.3.3)
  <li><a href="https://rubygems.org/pages/download">RubyGems package manager</a></li>
</ul>
as well as the following Ruby gems:  
<ul>
  <li><code>fastimage</code>
  <li><code>fileutils</code>
  <li><code>gtk3</code>
  <li><code>mini_exiftool</code></li>
</ul>  

On Mac you might need the exiftool installed. I recommend installing it using the Brew package manager:
```brew install exiftool```

Get the Sangoro tool by typing ```gem install sangoro``` in your command line. This will install the sangoro gem as well as the gems mentined above.
Now you can just run ```sangoro``` in your command line.

# Usage
1. Select a JPEG/PNG file by clicking on "Select image"
2. You will see the file name and the creation date & time on the right side, if available.
3. Now you can specify by how many hours, minutes and/or seconds you want the time stamp to move. You also need to choose whether to move the timestamp forward or back.
4. If you want to apply this change to all images in the folder, check the box below.
5. Click "Apply". 
6. You are done. The exif creation timestamp of the selected image(s) was adjusted as specified.

# Remarks  
If you have any remarks, bugs, questions etc. please tell me, I'd be happy to help. 