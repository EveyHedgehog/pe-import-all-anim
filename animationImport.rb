require 'zlib'

module RPG; end

class RPG::AudioFile
  def initialize(name = '', volume = 100, pitch = 100)
    @name = name
    @volume = volume
    @pitch = pitch
  end
  attr_accessor :name
  attr_accessor :volume
  attr_accessor :pitch
end

class RPG::SE < RPG::AudioFile
  def play
    unless @name.empty?
      Audio.se_play('Audio/SE/' + @name, @volume, @pitch)
    end
  end
  def self.stop
    Audio.se_stop
  end
end

class Color
  attr_reader :red, :green ,:blue ,:alpha

  # The red value (0-255). Values out of range are automatically corrected.
  def red=(num)
    @red = constrain num, 0..255
  end

  # The green value (0-255). Values out of range are automatically corrected.
  def green=(num)
    @green = constrain num, 0..255
  end

  # The blue value (0-255). Values out of range are automatically corrected.
  def blue=(num)
    @blue = constrain num, 0..255
  end

  # The alpha value (0-255). Values out of range are automatically corrected.
  def alpha=(num)
    @alpha = constrain num, 0..255
  end

  # Creates a Color object. If alpha is omitted, it is assumed at 255.
  def initialize(red, green, blue, alpha=255)
    set red, green, blue, alpha
  end

  # Sets all components at once.
  def set(red, green, blue, alpha=255)
    self.red   = red
    self.green = green
    self.blue  = blue
    self.alpha = alpha
  end

private

  def constrain(val, range)
    if val >= range.min && val <= range.max
      val
    elsif val < range.min
      range.min
    elsif val > range.max
      range.max
    end
  end

  def self._load args
    #?
  end

end

class Win32API
  @@RGSSWINDOW=nil
  #@@GetCurrentThreadId=Win32API.new('kernel32','GetCurrentThreadId', '%w()','l')
  #@@GetWindowThreadProcessId=Win32API.new('user32','GetWindowThreadProcessId', '%w(l p)','l')
  #@@FindWindowEx=Win32API.new('user32','FindWindowEx', '%w(l l p p)','l')

  def Win32API.SetWindowText(text)
    hWnd =  pbFindRgssWindow
    #swp = Win32API.new('user32', 'SetWindowTextA', %(l, p), 'i')
    #swp.call(hWnd, text.to_s)
  end

 # Added by Peter O. as a more reliable way to get the RGSS window
  def Win32API.pbFindRgssWindow
    return @@RGSSWINDOW if @@RGSSWINDOW
    processid=[0].pack('l')
    threadid=@@GetCurrentThreadId.call
    nextwindow=0
    begin
      nextwindow=@@FindWindowEx.call(0,nextwindow,"RGSS Player",0)
      if nextwindow!=0
        wndthreadid=@@GetWindowThreadProcessId.call(nextwindow,processid)
        if wndthreadid==threadid
          @@RGSSWINDOW=nextwindow
          return @@RGSSWINDOW
        end
      end
    end until nextwindow==0
    raise "Can't find RGSS player window"
    return 0
  end

  def Win32API.SetWindowPos(w, h)
    hWnd =  pbFindRgssWindow
    windowrect=Win32API.GetWindowRect
    clientsize=Win32API.client_size
    xExtra=windowrect.width-clientsize[0]
    yExtra=windowrect.height-clientsize[1]
    #swp = Win32API.new('user32', 'SetWindowPos', %(l, l, i, i, i, i, i), 'i')
    #win = swp.call(hWnd, 0, windowrect.x, windowrect.y,w+xExtra,h+yExtra, 0)
    return win
  end

  def Win32API.client_size
    hWnd =  pbFindRgssWindow
    rect = [0, 0, 0, 0].pack('l4')
    #Win32API.new('user32', 'GetClientRect', %w(l p), 'i').call(hWnd, rect)
    width, height = rect.unpack('l4')[2..3]
    return width, height
  end

  def Win32API.GetWindowRect
    hWnd =  pbFindRgssWindow
    rect = [0, 0, 0, 0].pack('l4')
    #Win32API.new('user32', 'GetWindowRect', %w(l p), 'i').call(hWnd, rect)
    x,y,width, height = rect.unpack('l4')
    return Rect.new(x,y,width-x,height-y)
  end
end

class Bitmap

  # Gets the font used to draw a string with the {Bitmap#draw_text} method.
  # @return [Font] the font used to draw a string with the {Bitmap#draw_text} method.
  attr_accessor :font

  # Gets the bitmap width.
  attr_reader :width

  # Gets the bitmap height.
  attr_reader :height

  # Gets the bitmap rectangle.
  # @return [Rect] the bitmap rectangle.
  attr_reader :rect

  # A new instance of {Bitmap}.
  # @overload initialize(filename)
  #   Loads the graphic file specified in filename and creates a bitmap object.
  #   Also automatically searches files included in RGSS-RTP and encrypted archives. File extensions may be omitted.
  #   @return [Bitmap] a bitmap of the graphic file specified in filename.
  # @overload initialize(width, height)
  #   Creates a bitmap object with the specified size.
  #   @return [Bitmap] a bitmap oject with the specified size.
  def intialize(*args)
    if args.size == 1
      load_file args[0]
    elsif args.size == 2
      @width = args[0]
      @height = args[1]
    end
  end

  # Frees the bitmap. If the bitmap has already been freed, does nothing.
  def dispose
    raise "not implemented"

    @disposed = true
  end

  # @return [true,false] _true_ if the bitmap has been freed.
  def disposed?
    @disposed
  end

  # Performs a block transfer from the src_bitmap box src_rect to the specified bitmap coordinates (x, y).
  # Opacity can be set from 0 to 255.
  #
  # @param [Number] x
  # @param [Number] y
  # @param [Bitmap] src_bitmap the bitmap to transfer.
  # @param [Rect] src_rect the box section of the src_rect to transfer.
  # @param [Number] opacity the opacity to use for the src_bitmap. Valid values: (0..255).
  def blt(x, y, src_bitmap, src_rect, opacity = 255)
    raise "not implemented"
  end

  # Performs a block transfer from the src_bitmap box src_rect to the specified bitmap box dest_rect (Rect).
  # opacity can be set from 0 to 255.
  #
  # @param [Rect] dest_rect
  # @param [Bitmap] src_bitmap
  # @param [Rect] src_rect
  # @param [Number] opacity
  def stretch_blt(dest_rect, src_bitmap, src_rect, opacity = 255)
    raise "not implemented"
  end

  # Fills the bitmap box (x, y, width, height) or rect (Rect) with color (Color).
  # @overload fill_rect(x, y, width, height, color)
  # @overload fill_rect(rect, color)
  def fill_rect(*args)
    raise "not implemented"
  end

  # Clears the entire bitmap.
  def clear
    raise "not implemented"
  end

  # Gets the {Color} at the specified pixel (x, y).
  def get_pixel(x, y)
    raise "not implemented"
  end

  # Sets the specified pixel (x, y) to the specified {Color}.
  def set_pixel(x, y, color)
    raise "not implemented"
  end

  # Changes the bitmap's hue within 360 degrees of displacement.
  # This process is time-consuming. Furthermore, due to conversion errors, repeated hue changes may result in color loss.
  def hue_change(hue)
    raise "not implemented"
  end

  # Draws a string str in the bitmap box (x, y, width, height) or rect (Rect).
  #
  # If the text length exceeds the box's width, the text width will automatically be reduced by up to 60 percent.
  #
  # Horizontal text is left-aligned by default; set align to 1 to center the text and to 2 to right-align it. Vertical text is always centered.
  #
  # As this process is time-consuming, redrawing the text with every frame is not recommended.
  #
  # @overload draw_text(x, y, width, height, str[, align])
  # @overload draw_text(rect, str[, align])
  def draw_text(*args)
    raise "not implemented"
  end

  # @return [Rect] the box used when drawing a string str with the draw_text method.
  #   Does not include the angled portions of italicized text.
  def text_size(str)
     raise "not implemented"
  end

  private

  def load_file(file)
     raise "not implemented"
  end
end

class Sprite
  # additional sprite attributes
  attr_reader :storedBitmap
  attr_accessor :direction
  attr_accessor :speed
  attr_accessor :toggle
  attr_accessor :end_x, :end_y
  attr_accessor :param
  attr_accessor :ex, :ey
  attr_accessor :zx, :zy
  #-----------------------------------------------------------------------------
  #  MTS compatibility layer
  #-----------------------------------------------------------------------------
  def id?(val); return nil; end
  #-----------------------------------------------------------------------------
  #  draws rect bitmap
  #-----------------------------------------------------------------------------
  def drawRect(width, height, color)
    self.bitmap = Bitmap.new(width,height)
    self.bitmap.fill_rect(0,0,width,height,color)
  end
  #-----------------------------------------------------------------------------
  #  resets additional values
  #-----------------------------------------------------------------------------
  def default
    @speed = 1; @toggle = 1; @end_x = 0; @end_y = 0
    @ex = 0; @ey = 0; @zx = 1; @zy = 1; @param = 1; @direction = 1
  end
  #-----------------------------------------------------------------------------
  #  gets zoom
  #-----------------------------------------------------------------------------
  def zoom
    return self.zoom_x
  end
  #-----------------------------------------------------------------------------
  #  sets all zoom values
  #-----------------------------------------------------------------------------
  def zoom=(val)
    self.zoom_x = val
    self.zoom_y = val
  end
  #-----------------------------------------------------------------------------
  #  centers sprite anchor
  #-----------------------------------------------------------------------------
  def center(snap = false)
    self.ox = self.src_rect.width/2
    self.oy = self.src_rect.height/2
    # aligns with the center of the sprite's viewport
    if snap && self.viewport
      self.x = self.viewport.rect.width/2
      self.y = self.viewport.rect.height/2
    end
  end
  #-----------------------------------------------------------------------------
  #  sets sprite anchor to bottom
  #-----------------------------------------------------------------------------
  def bottom
    self.ox = self.src_rect.width/2
    self.oy = self.src_rect.height
  end
  #-----------------------------------------------------------------------------
  #  applies screenshot as sprite bitmap
  #-----------------------------------------------------------------------------
  def snapScreen
    bmp = Graphics.snap_to_bitmap
    width = self.viewport ? viewport.rect.width : Graphics.width
    height = self.viewport ? viewport.rect.height : Graphics.height
    x = self.viewport ? viewport.rect.x : 0
    y = self.viewport ? viewport.rect.y : 0
    self.bitmap = Bitmap.new(width,height)
    self.bitmap.blt(0,0,bmp,Rect.new(x,y,width,height)); bmp.dispose
  end
  #-----------------------------------------------------------------------------
  #  skews sprite's bitmap
  #-----------------------------------------------------------------------------
  def skew(angle = 90)
    return false if !self.bitmap
    angle = angle*(Math::PI/180)
    bitmap = self.storedBitmap ? self.storedBitmap : self.bitmap
    rect = Rect.new(0,0,bitmap.width,bitmap.height)
    width = rect.width
    width += ((rect.height-1)/Math.tan(angle)).abs if angle != 90
    self.bitmap = Bitmap.new(width,rect.height)
    for i in 0...rect.height
      y = rect.height-i
      x = (angle == 90) ? 0 : i/Math.tan(angle)
      self.bitmap.blt(x+rect.x,y+rect.y,bitmap,Rect.new(0,y,rect.width,1))
    end
    @calMidX = (angle <= 90) ? bitmap.width/2 : (self.bitmap.width - bitmap.width/2)
  end
  #-----------------------------------------------------------------------------
  #  gets the mid-point anchor of sprite
  #-----------------------------------------------------------------------------
  def midX?
    return @calMidX if @calMidX
    return self.bitmap.width/2 if self.bitmap
    return self.ox
  end
  #-----------------------------------------------------------------------------
  #  blurs the contents of the sprite bitmap
  #-----------------------------------------------------------------------------
  def blur_sprite(blur_val = 2, opacity = 35)
    bitmap = self.bitmap
    self.bitmap = Bitmap.new(bitmap.width,bitmap.height)
    self.bitmap.blt(0,0,bitmap,Rect.new(0,0,bitmap.width,bitmap.height))
    x = 0; y = 0
    for i in 1...(8 * blur_val)
      dir = i % 8
      x += (1 + (i / 8))*([0,6,7].include?(dir) ? -1 : 1)*([1,5].include?(dir) ? 0 : 1)
      y += (1 + (i / 8))*([1,4,5,6].include?(dir) ? -1 : 1)*([3,7].include?(dir) ? 0 : 1)
      self.bitmap.blt(x-blur_val,y+(blur_val*2),bitmap,Rect.new(0,0,bitmap.width,bitmap.height),opacity)
    end
  end
  #-----------------------------------------------------------------------------
  #  gets average sprite color
  #-----------------------------------------------------------------------------
  def getAvgColor(freq = 2)
    return Color.new(0,0,0,0) if !self.bitmap
    bmp = self.bitmap
    width = self.bitmap.width/freq
    height = self.bitmap.height/freq
    red = 0; green = 0; blue = 0
    n = width*height
    for x in 0...width
      for y in 0...height
        color = bmp.get_pixel(x*freq,y*freq)
        if color.alpha > 0
          red += color.red
          green += color.green
          blue += color.blue
        end
      end
    end
    avg = Color.new(red/n,green/n,blue/n)
    return avg
  end
  #-----------------------------------------------------------------------------
  #  draws outline on bitmap
  #-----------------------------------------------------------------------------
  def create_outline(color, thickness = 2)
    return false if !self.bitmap
    drawBitmapOutline(self.bitmap, color, thickness)
  end
  #-----------------------------------------------------------------------------
  #  applies hard-color onto bitmap pixels
  #-----------------------------------------------------------------------------
  def colorize(color)
    return false if !self.bitmap
    bmp = self.bitmap.clone
    self.bitmap = Bitmap.new(bmp.width,bmp.height)
    for x in 0...bmp.width
      for y in 0...bmp.height
        pixel = bmp.get_pixel(x,y)
        self.bitmap.set_pixel(x,y,color) if pixel.alpha > 0
      end
    end
  end
  #-----------------------------------------------------------------------------
  #  creates a glow around sprite
  #-----------------------------------------------------------------------------
  def glow(color, opacity = 35, keep = true)
    return false if !self.bitmap
    temp_bmp = self.bitmap.clone
    self.colorize(color)
    self.blur_sprite(3,opacity)
    src = self.bitmap.clone
    self.bitmap.clear
    self.bitmap.stretch_blt(Rect.new(-0.005*src.width,-0.015*src.height,src.width*1.01,1.02*src.height),src,Rect.new(0,0,src.width,src.height))
    self.bitmap.blt(0,0,temp_bmp,Rect.new(0,0,temp_bmp.width,temp_bmp.height)) if keep
  end
  #-----------------------------------------------------------------------------
  #  fuzzes sprite outlines
  #-----------------------------------------------------------------------------
  def fuzz(color, opacity = 35)
    return false if !self.bitmap
    self.colorize(color)
    self.blur_sprite(3,opacity)
    src = self.bitmap.clone
    self.bitmap.clear
    self.bitmap.stretch_blt(Rect.new(-0.005*src.width,-0.015*src.height,src.width*1.01,1.02*src.height),src,Rect.new(0,0,src.width,src.height))
  end
  #-----------------------------------------------------------------------------
  #  caches current bitmap additionally
  #-----------------------------------------------------------------------------
  def memorize_bitmap(bitmap = nil)
    @storedBitmap = bitmap if !bitmap.nil?
    @storedBitmap = self.bitmap.clone if bitmap.nil?
  end
  #-----------------------------------------------------------------------------
  #  returns cached bitmap
  #-----------------------------------------------------------------------------
  def restore_bitmap
    self.bitmap = @storedBitmap.clone
  end
  #-----------------------------------------------------------------------------
  #  applies tone value across all tone colors
  #-----------------------------------------------------------------------------
  def toneAll(val)
    self.tone.red += val
    self.tone.green += val
    self.tone.blue += val
  end
  #-----------------------------------------------------------------------------
  #  downloads a bitmap and applies it to sprite
  #-----------------------------------------------------------------------------
  def onlineBitmap(url)
    pbDownloadToFile(url,"_temp.png")
    return if !FileTest.exist?("_temp.png")
    self.bitmap = pbBitmap("_temp")
    File.delete("_temp.png")
  end
  #-----------------------------------------------------------------------------
  #  applies mask to bitmap
  #-----------------------------------------------------------------------------
  def mask(mask = nil, xpush = 0, ypush = 0) # Draw sprite on a sprite/bitmap
    return false if !self.bitmap
    self.bitmap = self.bitmap.mask(mask,xpush,ypush)
  end
  #-----------------------------------------------------------------------------
  #  swap out specified colors (resource intensive, best not use on large sprites)
  #-----------------------------------------------------------------------------
  def swapColors(map)
    self.bitmap.swapColors(map) if self.bitmap
  end
  #-----------------------------------------------------------------------------
end

class Rect
  # The X-coordinate of the rectangle's upper left corner.
  attr_accessor :x

  # The Y-coordinate of the rectange's upper left corner.
  attr_accessor :y

  # The rectangle's width.
  attr_accessor :width

  # The rectangle's height.
  attr_accessor :height

  def initialize(x, y, width, height)
    set x, y, width, height
  end

  # Sets all parameters at once.
  def set(x, y, width, height)
    @x = x
    @y = y
    @width = width
    @height = height
  end
end

module RTP
  @rtpPaths=nil

  def self.exists?(filename,extensions=[])
    return false if !filename || filename==""
    eachPathFor(filename) {|path|
       return true if safeExists?(path)
       for ext in extensions
         return true if safeExists?(path+ext)
       end
    }
    return false
  end

  def self.getImagePath(filename)
    return self.getPath(filename,["",".png",".jpg",".gif",".bmp",".jpeg"])
  end

  def self.getAudioPath(filename)
    return self.getPath(filename,["",".mp3",".wav",".wma",".mid",".ogg",".midi"])
  end

  def self.getPath(filename,extensions=[])
    return filename if !filename || filename==""
    eachPathFor(filename) {|path|
       return path if safeExists?(path)
       for ext in extensions
         file=path+ext
         return file if safeExists?(file)
       end
    }
    return filename
  end

 # Gets the absolute RGSS paths for the given file name
  def self.eachPathFor(filename)
    return if !filename
    if filename[/^[A-Za-z]\:[\/\\]/] || filename[/^[\/\\]/]
      # filename is already absolute
      yield filename
    else
      # relative path
      RTP.eachPath {|path|
         if path=="./"
           yield filename
         else
           yield path+filename
         end
      }
    end
  end

  # Gets all RGSS search paths
  def self.eachPath
    # XXX: Use "." instead of Dir.pwd because of problems retrieving files if
    # the current directory contains an accent mark
    yield ".".gsub(/[\/\\]/,"/").gsub(/[\/\\]$/,"")+"/"
    if !@rtpPaths
      tmp=Sprite.new
      isRgss2=tmp.respond_to?("wave_amp")
      #tmp.dispose
      tmp = nil
      @rtpPaths=[]
      if isRgss2
        rtp=getGameIniValue("Game","RTP")
        if rtp!=""
          rtp=MiniRegistry.get(MiniRegistry::HKEY_LOCAL_MACHINE,
             "SOFTWARE\\Enterbrain\\RGSS2\\RTP",rtp,nil)
          if rtp && safeIsDirectory?(rtp)
            @rtpPaths.push(rtp.sub(/[\/\\]$/,"")+"/")
          end
        end
      else
        %w( RTP1 RTP2 RTP3 ).each{|v|
           rtp=getGameIniValue("Game",v)
           if rtp!=""
             rtp=MiniRegistry.get(MiniRegistry::HKEY_LOCAL_MACHINE,
                "SOFTWARE\\Enterbrain\\RGSS\\RTP",rtp,nil)
             if rtp && safeIsDirectory?(rtp)
               @rtpPaths.push(rtp.sub(/[\/\\]$/,"")+"/")
             end
           end
        }
      end
    end
    @rtpPaths.each{|x| yield x }
  end

  private

  def self.getGameIniValue(section,key)
    val = "\0"*256
    #gps = Win32API.new('kernel32', 'GetPrivateProfileString',%w(p p p p l p), 'l')
    #gps.call(section, key, "", val, 256, ".\\Game.ini")
    val.delete!("\0")
    return val
  end

  @@folder=nil

  def self.isDirWritable(dir)
    return false if !dir || dir==""
    loop do
      name=dir.gsub(/[\/\\]$/,"")+"/writetest"
      for i in 0...12
        name+=sprintf("%02X",rand(256))
      end
      name+=".tmp"
      if !safeExists?(name)
        retval=false
        begin; File.open(name,"wb"){retval=true};
        rescue Errno::EINVAL, Errno::EACCES, Errno::ENOENT
        ensure; File.delete(name) rescue nil; end
        return retval
      end
    end
  end

  def self.ensureGameDir(dir)
    title=RTP.getGameIniValue("Game","Title")
    title="RGSS Game" if title==""
    title=title.gsub(/[^\w ]/,"_")
    newdir=dir.gsub(/[\/\\]$/,"")+"/"+title
    # Convert to UTF-8 because of ANSI function
    newdir=getUnicodeStringFromAnsi(newdir)
    Dir.mkdir(newdir) rescue nil
    ret=safeIsDirectory?(newdir) ? newdir : dir
    return ret
  end

  def self.getSaveFileName(fileName)
    return getSaveFolder().gsub(/[\/\\]$/,"")+"/"+fileName
  end

  def self.getSaveFolder
    if !@@folder
      # XXX: Use "." instead of Dir.pwd because of problems retrieving files if
      # the current directory contains an accent mark
      pwd="."
      # Get the known folder path for saved games
      savedGames=getKnownFolder([0x4c5c32ff,0xbb9d,0x43b0,
         0xb5,0xb4,0x2d,0x72,0xe5,0x4e,0xaa,0xa4])
      if savedGames && savedGames!="" && isDirWritable(savedGames)
        pwd=ensureGameDir(savedGames)
      end
      if isDirWritable(pwd)
        @@folder=pwd
      else
        appdata=ENV["LOCALAPPDATA"]
        if isDirWritable(appdata)
          appdata=ensureGameDir(appdata)
        else
          appdata=ENV["APPDATA"]
          if isDirWritable(appdata)
            appdata=ensureGameDir(appdata)
          elsif isDirWritable(pwd)
            appdata=pwd
          else
            appdata="."
          end
        end
        @@folder=appdata
      end
    end
    return @@folder
  end
end

module FileInputMixin
  def fgetb
    ret = 0
    each_byte do |i|
      ret = i || 0
      break
    end
    return ret
  end

  def fgetw
    x = 0
    ret = 0
    each_byte do |i|
      break if !i
      ret |= (i << x)
      x += 8
      break if x == 16
    end
    return ret
  end

  def fgetdw
    x = 0
    ret = 0
    each_byte do |i|
      break if !i
      ret |= (i << x)
      x += 8
      break if x == 32
    end
    return ret
  end

  def fgetsb
    ret = fgetb
    ret -= 256 if (ret & 0x80) != 0
    return ret
  end

  def xfgetb(offset)
    self.pos = offset
    return fgetb
  end

  def xfgetw(offset)
    self.pos = offset
    return fgetw
  end

  def xfgetdw(offset)
    self.pos = offset
    return fgetdw
  end

  def getOffset(index)
    self.binmode
    self.pos = 0
    offset = fgetdw >> 3
    return 0 if index >= offset
    self.pos = index * 8
    return fgetdw
  end

  def getLength(index)
    self.binmode
    self.pos = 0
    offset = fgetdw >> 3
    return 0 if index >= offset
    self.pos = index * 8 + 4
    return fgetdw
  end

  def readName(index)
    self.binmode
    self.pos = 0
    offset = fgetdw >> 3
    return "" if index >= offset
    self.pos = index << 3
    offset = fgetdw
    length = fgetdw
    return "" if length == 0
    self.pos = offset
    return read(length)
  end
end

module FileOutputMixin
  def fputb(b)
    b &= 0xFF
    write(b.chr)
  end

  def fputw(w)
    2.times do
      b = w & 0xFF
      write(b.chr)
      w >>= 8
    end
  end

  def fputdw(w)
    4.times do
      b = w & 0xFF
      write(b.chr)
      w >>= 8
    end
  end
end

class StringInput
  include FileInputMixin
  def initialize(x)
    # lol
  end
  def pos=(value)
    seek(value)
  end

  def each_byte
    while !eof?
      yield getc
    end
  end

  def binmode; end
end

module PokeBattle_SceneConstants
  # Default focal points of user and target in animations - do not change!
  FOCUSUSER_X   = 128   # 144
  FOCUSUSER_Y   = 224   # 188
  FOCUSTARGET_X = 384   # 352
  FOCUSTARGET_Y = 96    # 108, 98
end

class Array
  def shuffle
    dup.shuffle!
  end unless method_defined? :shuffle

  def ^(other) # xor of two arrays
    return (self|other)-(self&other)
  end

  def shuffle!
    size.times do |i|
      r = Kernel.rand(size)
      self[i], self[r] = self[r], self[i]
    end
    self
  end unless method_defined? :shuffle!
end

module FileTest
  Image_ext = ['.bmp', '.png', '.jpg', '.jpeg', '.gif']
  Audio_ext = ['.mp3', '.mid', '.midi', '.ogg', '.wav', '.wma']

  def self.audio_exist?(filename)
    return RTP.exists?(filename,Audio_ext)
  end

  def self.image_exist?(filename)
    return RTP.exists?(filename,Image_ext)
  end
end

module Enumerable
  def transform
    ret=[]
    self.each(){|item| ret.push(yield(item)) }
    return ret
  end
end

class AnimFrame
  X          = 0
  Y          = 1
  ZOOMX      = 2
  ANGLE      = 3
  MIRROR     = 4
  BLENDTYPE  = 5
  VISIBLE    = 6
  PATTERN    = 7
  OPACITY    = 8
  ZOOMY      = 11
  COLORRED   = 12
  COLORGREEN = 13
  COLORBLUE  = 14
  COLORALPHA = 15
  TONERED    = 16
  TONEGREEN  = 17
  TONEBLUE   = 18
  TONEGRAY   = 19
  LOCKED     = 20
  FLASHRED   = 21
  FLASHGREEN = 22
  FLASHBLUE  = 23
  FLASHALPHA = 24
  PRIORITY   = 25
  FOCUS      = 26
end

# Works around a problem with FileTest.directory if directory contains accent marks
def safeIsDirectory?(f)
  ret=false
  Dir.chdir(f) { ret=true } rescue nil
  return ret
end

# Works around a problem with FileTest.exist if path contains accent marks
def safeExists?(f)
  ret=false
  if f[/\A[\x20-\x7E]*\z/]
    return FileTest.exist?(f)
  end
  begin
    File.open(f,"rb") { ret=true }
  rescue Errno::ENOENT, Errno::EINVAL, Errno::EACCES
    ret=false
  end
  return ret
end

# Similar to "Dir.glob", but designed to work around a problem with accessing
# files if a path contains accent marks.
# "dir" is the directory path, "wildcard" is the filename pattern to match.
def safeGlob(dir,wildcard)
  ret=[]
  afterChdir=false
  begin
    Dir.chdir(dir){
       afterChdir=true
       Dir.glob(wildcard){|f|
          ret.push(dir+"/"+f)
       }
    }
    rescue Errno::ENOENT
    raise if afterChdir
  end
  if block_given?
    ret.each{|f|
       yield(f)
    }
  end
  return (block_given?) ? nil : ret
end


def tryLoadData(file)
  begin
    File.open(file, "rb"){ |f|
      loadfile = Marshal.load(f)
    }
    return loadfile
  rescue
    return nil
  end
end

def pbSafeCopyFile(x,y,z=nil)
  if safeExists?(x)
    safetocopy=true
    filedata=nil
    if safeExists?(y)
      different=false
      if FileTest.size(x)!=FileTest.size(y)
        different=true
      else
        filedata2=""
        File.open(x,"rb"){|f| filedata=f.read }
        File.open(y,"rb"){|f| filedata2=f.read }
        if filedata!=filedata2
          different=true
        end
      end
      if different
        safetocopy=Kernel.pbConfirmMessage(
           _INTL("A different file named '{1}' already exists. Overwrite it?",y))
      else
        # No need to copy
        return
      end
    end
    if safetocopy
      if !filedata
        File.open(x,"rb"){|f| filedata=f.read }
      end
      File.open(z ? z : y,"wb"){|f| f.write(filedata) }
    end
  end
end

def pbCreateCel(x,y,pattern,focus=4)
  frame=[]
  frame[AnimFrame::X]=x
  frame[AnimFrame::Y]=y
  frame[AnimFrame::PATTERN]=pattern
  frame[AnimFrame::FOCUS]=focus # 1=target, 2=user, 3=user and target, 4=screen
  frame[AnimFrame::LOCKED]=0
  pbResetCel(frame)
  return frame
end

def pbResetCel(frame)
  return if !frame
  frame[AnimFrame::ZOOMX]=100
  frame[AnimFrame::ZOOMY]=100
  frame[AnimFrame::BLENDTYPE]=0
  frame[AnimFrame::VISIBLE]=1
  frame[AnimFrame::ANGLE]=0
  frame[AnimFrame::MIRROR]=0
  frame[AnimFrame::OPACITY]=255
  frame[AnimFrame::COLORRED]=0
  frame[AnimFrame::COLORGREEN]=0
  frame[AnimFrame::COLORBLUE]=0
  frame[AnimFrame::COLORALPHA]=0
  frame[AnimFrame::TONERED]=0
  frame[AnimFrame::TONEGREEN]=0
  frame[AnimFrame::TONEBLUE]=0
  frame[AnimFrame::TONEGRAY]=0
  frame[AnimFrame::FLASHRED]=0
  frame[AnimFrame::FLASHGREEN]=0
  frame[AnimFrame::FLASHBLUE]=0
  frame[AnimFrame::FLASHALPHA]=0
  frame[AnimFrame::PRIORITY]=1 # 0=back, 1=front, 2=behind focus, 3=before focus
end

def pbStringToAudioFile(str)
  if str[/^(.*)\:\s*(\d+)\s*\:\s*(\d+)\s*$/]   # Of the format "XXX: ###: ###"
    file   = $1
    volume = $2.to_i
    pitch  = $3.to_i
    return RPG::AudioFile.new(file,volume,pitch)
  elsif str[/^(.*)\:\s*(\d+)\s*$/]             # Of the format "XXX: ###"
    file   = $1
    volume = $2.to_i
    return RPG::AudioFile.new(file,volume,100)
  else
    return RPG::AudioFile.new(str,100,100)
  end
end

def pbResolveAudioFile(str,volume=nil,pitch=nil)
  if str.is_a?(String)
    str = pbStringToAudioFile(str)
    str.volume = volume || 100
    str.pitch  = pitch || 100
  end
  if str.is_a?(RPG::AudioFile)
    if volume || pitch
      return RPG::AudioFile.new(str.name,volume || str.volume || 100 ,
                                         pitch || str.pitch || 100)
    else
      return str
    end
  end
  return str
end

def pbSEPlay(param,volume=nil,pitch=nil)
  return if !param
  param = pbResolveAudioFile(param,volume,pitch)
  if param.name && param.name!=""
    if $game_system && $game_system.respond_to?("se_play")
      $game_system.se_play(param)
      return
    end
    if (RPG.const_defined?(:SE) rescue false)
      b = RPG::SE.new(param.name,param.volume,param.pitch)
      if b && b.respond_to?("play")
        b.play
        return
      end
    end
    Audio.se_play(canonicalize("Audio/SE/"+param.name),param.volume,param.pitch)
  end
end

def pbAllocateAnimation(animations,name)
  for i in 1...animations.length
    anim=animations[i]
    if !anim
      return i
    end
#    if name && name!="" && anim.name==name
#      # use animation with same name
#      return i
#    end
    if anim.length==1 && anim[0].length==2 && anim.name==""
      # assume empty
      return i
    end
  end
  oldlength=animations.length
  #animations.resize(10)
  return oldlength
end

class PBAnimation < Array
  include Enumerable
  attr_accessor :graphic
  attr_accessor :hue
  attr_accessor :name
  attr_accessor :position
  attr_accessor :speed
  attr_reader :array
  attr_reader :timing
  attr_accessor :id
  MAXSPRITES=30

  def speed
    @speed=20 if !@speed
    return @speed
  end

  def initialize(size=1)
    @array=[]
    @timing=[]
    @name=""
    @id=-1
    @graphic=""
    @hue=0
    @scope=0
    @position=4 # 1=target, 2=user, 3=user and target, 4=screen
    size=1 if size<1 # Always create at least one frame
    size.times do
      addFrame
    end
  end

  def length
    return @array.length
  end

  def each
    @array.each {|i| yield i }
  end

  def [](i)
    return @array[i]
  end

  def []=(i,value)
    @array[i]=value
  end

  def insert(*arg)
    return @array.insert(*arg)
  end

  def delete_at(*arg)
    return @array.delete_at(*arg)
  end

  def playTiming(frame,bgGraphic,bgColor,foGraphic,foColor,oldbg=[],oldfo=[],user=nil)
    for i in @timing
      if i.frame==frame
        case i.timingType
          when 0   # Play SE
            if i.name && i.name!=""
              pbSEPlay(i.name,i.volume,i.pitch)
            else
              poke=(user && user.pokemon) ? user.pokemon : 1
              #name=(pbCryFile(poke) rescue "001Cry")
              pbSEPlay(name,i.volume,i.pitch)
            end
#            if sprite
#              sprite.flash(i.flashColor,i.flashDuration*2) if i.flashScope==1
#              sprite.flash(nil,i.flashDuration*2) if i.flashScope==3
#            end
          when 1   # Set background graphic (immediate)
            if i.name && i.name!=""
              bgGraphic.setBitmap("Graphics/Animations/"+i.name)
              bgGraphic.ox=-i.bgX || 0
              bgGraphic.oy=-i.bgY || 0
              bgGraphic.color=Color.new(i.colorRed || 0,i.colorGreen || 0,i.colorBlue || 0,i.colorAlpha || 0)
              bgGraphic.opacity=i.opacity || 0
              bgColor.opacity=0
            else
              bgGraphic.setBitmap(nil)
              bgGraphic.opacity=0
              bgColor.color=Color.new(i.colorRed || 0,i.colorGreen || 0,i.colorBlue || 0,i.colorAlpha || 0)
              bgColor.opacity=i.opacity || 0
            end
          when 2   # Move/recolour background graphic
            if bgGraphic.bitmap!=nil
              oldbg[0]=bgGraphic.ox || 0
              oldbg[1]=bgGraphic.oy || 0
              oldbg[2]=bgGraphic.opacity || 0
              oldbg[3]=bgGraphic.color.clone || Color.new(0,0,0,0)
            else
              oldbg[0]=0
              oldbg[1]=0
              oldbg[2]=bgColor.opacity || 0
              oldbg[3]=bgColor.color.clone || Color.new(0,0,0,0)
            end
          when 3   # Set foreground graphic (immediate)
            if i.name && i.name!=""
              foGraphic.setBitmap("Graphics/Animations/"+i.name)
              foGraphic.ox=-i.bgX || 0
              foGraphic.oy=-i.bgY || 0
              foGraphic.color=Color.new(i.colorRed || 0,i.colorGreen || 0,i.colorBlue || 0,i.colorAlpha || 0)
              foGraphic.opacity=i.opacity || 0
              foColor.opacity=0
            else
              foGraphic.setBitmap(nil)
              foGraphic.opacity=0
              foColor.color=Color.new(i.colorRed || 0,i.colorGreen || 0,i.colorBlue || 0,i.colorAlpha || 0)
              foColor.opacity=i.opacity || 0
            end
          when 4   # Move/recolour foreground graphic
            if foGraphic.bitmap!=nil
              oldfo[0]=foGraphic.ox || 0
              oldfo[1]=foGraphic.oy || 0
              oldfo[2]=foGraphic.opacity || 0
              oldfo[3]=foGraphic.color.clone || Color.new(0,0,0,0)
            else
              oldfo[0]=0
              oldfo[1]=0
              oldfo[2]=foColor.opacity || 0
              oldfo[3]=foColor.color.clone || Color.new(0,0,0,0)
            end
        end
      end
    end
    for i in @timing
      case i.timingType
        when 2
          if i.duration && i.duration>0 && frame>=i.frame && frame<=(i.frame+i.duration)
            fraction=(frame-i.frame)*1.0/i.duration
            if bgGraphic.bitmap!=nil
              bgGraphic.ox=oldbg[0]-(i.bgX-oldbg[0])*fraction if i.bgX!=nil
              bgGraphic.oy=oldbg[1]-(i.bgY-oldbg[1])*fraction if i.bgY!=nil
              bgGraphic.opacity=oldbg[2]+(i.opacity-oldbg[2])*fraction if i.opacity!=nil
              cr=(i.colorRed!=nil) ? oldbg[3].red+(i.colorRed-oldbg[3].red)*fraction : oldbg[3].red
              cg=(i.colorGreen!=nil) ? oldbg[3].green+(i.colorGreen-oldbg[3].green)*fraction : oldbg[3].green
              cb=(i.colorBlue!=nil) ? oldbg[3].blue+(i.colorBlue-oldbg[3].blue)*fraction : oldbg[3].blue
              ca=(i.colorAlpha!=nil) ? oldbg[3].alpha+(i.colorAlpha-oldbg[3].alpha)*fraction : oldbg[3].alpha
              bgGraphic.color=Color.new(cr,cg,cb,ca)
            else
              bgColor.opacity=oldbg[2]+(i.opacity-oldbg[2])*fraction if i.opacity!=nil
              cr=(i.colorRed!=nil) ? oldbg[3].red+(i.colorRed-oldbg[3].red)*fraction : oldbg[3].red
              cg=(i.colorGreen!=nil) ? oldbg[3].green+(i.colorGreen-oldbg[3].green)*fraction : oldbg[3].green
              cb=(i.colorBlue!=nil) ? oldbg[3].blue+(i.colorBlue-oldbg[3].blue)*fraction : oldbg[3].blue
              ca=(i.colorAlpha!=nil) ? oldbg[3].alpha+(i.colorAlpha-oldbg[3].alpha)*fraction : oldbg[3].alpha
              bgColor.color=Color.new(cr,cg,cb,ca)
            end
          end
        when 4
          if i.duration && i.duration>0 && frame>=i.frame && frame<=(i.frame+i.duration)
            fraction=(frame-i.frame)*1.0/i.duration
            if foGraphic.bitmap!=nil
              foGraphic.ox=oldfo[0]-(i.bgX-oldfo[0])*fraction if i.bgX!=nil
              foGraphic.oy=oldfo[1]-(i.bgY-oldfo[1])*fraction if i.bgY!=nil
              foGraphic.opacity=oldfo[2]+(i.opacity-oldfo[2])*fraction if i.opacity!=nil
              cr=(i.colorRed!=nil) ? oldfo[3].red+(i.colorRed-oldfo[3].red)*fraction : oldfo[3].red
              cg=(i.colorGreen!=nil) ? oldfo[3].green+(i.colorGreen-oldfo[3].green)*fraction : oldfo[3].green
              cb=(i.colorBlue!=nil) ? oldfo[3].blue+(i.colorBlue-oldfo[3].blue)*fraction : oldfo[3].blue
              ca=(i.colorAlpha!=nil) ? oldfo[3].alpha+(i.colorAlpha-oldfo[3].alpha)*fraction : oldfo[3].alpha
              foGraphic.color=Color.new(cr,cg,cb,ca)
            else
              foColor.opacity=oldfo[2]+(i.opacity-oldfo[2])*fraction if i.opacity!=nil
              cr=(i.colorRed!=nil) ? oldfo[3].red+(i.colorRed-oldfo[3].red)*fraction : oldfo[3].red
              cg=(i.colorGreen!=nil) ? oldfo[3].green+(i.colorGreen-oldfo[3].green)*fraction : oldfo[3].green
              cb=(i.colorBlue!=nil) ? oldfo[3].blue+(i.colorBlue-oldfo[3].blue)*fraction : oldfo[3].blue
              ca=(i.colorAlpha!=nil) ? oldfo[3].alpha+(i.colorAlpha-oldfo[3].alpha)*fraction : oldfo[3].alpha
              foColor.color=Color.new(cr,cg,cb,ca)
            end
          end
      end
    end
  end

  def resize(len)
    if len<@array.length
      @array[len,@array.length-len]=[]
    elsif len>@array.length
      (len-@array.length).times do
        addFrame
      end
    end
  end

  def addFrame
    pos=@array.length
    @array[pos]=[]
    for i in 0...PBAnimation::MAXSPRITES # maximum sprites plus user and target
      if i==0
        @array[pos][i]=pbCreateCel(
           PokeBattle_SceneConstants::FOCUSUSER_X,
           PokeBattle_SceneConstants::FOCUSUSER_Y,-1) # Move's user
        @array[pos][i][AnimFrame::FOCUS]=2
        @array[pos][i][AnimFrame::LOCKED]=1
      elsif i==1
        @array[pos][i]=pbCreateCel(
           PokeBattle_SceneConstants::FOCUSTARGET_X,
           PokeBattle_SceneConstants::FOCUSTARGET_Y,-2) # Move's target
        @array[pos][i][AnimFrame::FOCUS]=1
        @array[pos][i][AnimFrame::LOCKED]=1
      end
    end
    return @array[pos]
  end
end

class PBAnimTiming
  attr_accessor :frame
  attr_accessor :timingType   # 0=play SE, 1=set bg, 2=bg mod
  attr_accessor :name         # Name of SE file or BG file
  attr_accessor :volume
  attr_accessor :pitch
  attr_accessor :bgX          # x coordinate of bg (or to move bg to)
  attr_accessor :bgY          # y coordinate of bg (or to move bg to)
  attr_accessor :opacity      # Opacity of bg (or to change bg to)
  attr_accessor :colorRed     # Color of bg (or to change bg to)
  attr_accessor :colorGreen   # Color of bg (or to change bg to)
  attr_accessor :colorBlue    # Color of bg (or to change bg to)
  attr_accessor :colorAlpha   # Color of bg (or to change bg to)
  attr_accessor :duration     # How long to spend changing to the new bg coords/color
  attr_accessor :flashScope
  attr_accessor :flashColor
  attr_accessor :flashDuration

  def initialize(type=0)
    @frame=0
    @timingType=type
    @name=""
    @volume=80
    @pitch=100
    @bgX=nil
    @bgY=nil
    @opacity=nil
    @colorRed=nil
    @colorGreen=nil
    @colorBlue=nil
    @colorAlpha=nil
    @duration=5
    @flashScope=0
    @flashColor=Color.new(255,255,255,255)
    @flashDuration=5
  end

  def timingType
    @timingType=0 if !@timingType
    return @timingType
  end

  def duration
    @duration=5 if !@duration
    return @duration
  end

  def to_s
    if self.timingType==0
      return "[#{@frame+1}] Play SE: #{name} (volume #{@volume}, pitch #{@pitch})"
    elsif self.timingType==1
      text=sprintf("[%d] Set BG: \"%s\"",@frame+1,name)
      text+=sprintf(" (color=%s,%s,%s,%s)",
         @colorRed!=nil ? @colorRed.to_i : "-",
         @colorGreen!=nil ? @colorGreen.to_i : "-",
         @colorBlue!=nil ? @colorBlue.to_i : "-",
         @colorAlpha!=nil ? @colorAlpha.to_i : "-")
      text+=sprintf(" (opacity=%s)",@opacity.to_i)
      text+=sprintf(" (coords=%s,%s)",
         @bgX!=nil ? @bgX : "-",
         @bgY!=nil ? @bgY : "-")
      return text
    elsif self.timingType==2
      text=sprintf("[%d] Change BG: @%d",@frame+1,duration)
      if @colorRed!=nil || @colorGreen!=nil || @colorBlue!=nil || @colorAlpha!=nil
        text+=sprintf(" (color=%s,%s,%s,%s)",
           @colorRed!=nil ? @colorRed.to_i : "-",
           @colorGreen!=nil ? @colorGreen.to_i : "-",
           @colorBlue!=nil ? @colorBlue.to_i : "-",
           @colorAlpha!=nil ? @colorAlpha.to_i : "-")
      end
      if @opacity!=nil
        text+=sprintf(" (opacity=%s)",@opacity.to_i)
      end
      if @bgX!=nil || @bgY!=nil
        text+=sprintf(" (coords=%s,%s)",
           @bgX!=nil ? @bgX : "-",
           @bgY!=nil ? @bgY : "-")
      end
      return text
    elsif self.timingType==3
      text=sprintf("[%d] Set FG: \"%s\"",@frame+1,name)
      text+=sprintf(" (color=%s,%s,%s,%s)",
         @colorRed!=nil ? @colorRed.to_i : "-",
         @colorGreen!=nil ? @colorGreen.to_i : "-",
         @colorBlue!=nil ? @colorBlue.to_i : "-",
         @colorAlpha!=nil ? @colorAlpha.to_i : "-")
      text+=sprintf(" (opacity=%s)",@opacity.to_i)
      text+=sprintf(" (coords=%s,%s)",
         @bgX!=nil ? @bgX : "-",
         @bgY!=nil ? @bgY : "-")
      return text
    elsif self.timingType==4
      text=sprintf("[%d] Change FG: @%d",@frame+1,duration)
      if @colorRed!=nil || @colorGreen!=nil || @colorBlue!=nil || @colorAlpha!=nil
        text+=sprintf(" (color=%s,%s,%s,%s)",
           @colorRed!=nil ? @colorRed.to_i : "-",
           @colorGreen!=nil ? @colorGreen.to_i : "-",
           @colorBlue!=nil ? @colorBlue.to_i : "-",
           @colorAlpha!=nil ? @colorAlpha.to_i : "-")
      end
      if @opacity!=nil
        text+=sprintf(" (opacity=%s)",@opacity.to_i)
      end
      if @bgX!=nil || @bgY!=nil
        text+=sprintf(" (coords=%s,%s)",
           @bgX!=nil ? @bgX : "-",
           @bgY!=nil ? @bgY : "-")
      end
      return text
    end
    return ""
  end
end

class PBAnimations < Array
  include Enumerable
  attr_reader :array
  attr_accessor :selected

  def initialize(size=1)
    @array=[]
    @selected=0
  end

  def length
    return @array.length
  end

  def each
    @array.each {|i| yield i }
  end

  def [](i)
    return @array[i]
  end

  def []=(i,value)
    @array[i]=value
  end

  def compact
    @array.compact!
  end

  def resize(len)
    startidx=@array.length
    endidx=len
    if startidx>endidx
      for i in endidx...startidx
        @array.pop
      end
    else
      for i in startidx...endidx
        @array.push(PBAnimation.new)
      end
    end
    self.selected=len if self.selected>=len
  end
end

def loadBase64Anim(s)
  return Marshal.restore(Zlib::Inflate.inflate(s.unpack("m")[0]))
end

def pbConvertAnimToNewFormat(textdata)
  needconverting=false
  for i in 0...textdata.length
    next if !textdata[i]
    for j in 0...PBAnimation::MAXSPRITES
      next if !textdata[i][j]
      needconverting=true if textdata[i][j][AnimFrame::FOCUS]==nil
      break if needconverting
    end
    break if needconverting
  end
  if needconverting
    for i in 0...textdata.length
      next if !textdata[i]
      for j in 0...PBAnimation::MAXSPRITES
        next if !textdata[i][j]
        textdata[i][j][AnimFrame::PRIORITY]=1 if textdata[i][j][AnimFrame::PRIORITY]==nil
        if j==0 # User battler
          textdata[i][j][AnimFrame::FOCUS]=2
          textdata[i][j][AnimFrame::X]=PokeBattle_SceneConstants::FOCUSUSER_X
          textdata[i][j][AnimFrame::Y]=PokeBattle_SceneConstants::FOCUSUSER_Y
        elsif j==1 # Target battler
          textdata[i][j][AnimFrame::FOCUS]=1
          textdata[i][j][AnimFrame::X]=PokeBattle_SceneConstants::FOCUSTARGET_X
          textdata[i][j][AnimFrame::Y]=PokeBattle_SceneConstants::FOCUSTARGET_Y
        else
          textdata[i][j][AnimFrame::FOCUS]=(textdata.position || 4)
          if textdata.position==1
            textdata[i][j][AnimFrame::X]+=PokeBattle_SceneConstants::FOCUSTARGET_X
            textdata[i][j][AnimFrame::Y]+=PokeBattle_SceneConstants::FOCUSTARGET_Y-2
          end
        end
      end
    end
  end
  return needconverting
end


animationFolders = []
if safeIsDirectory?("Animations")
  Dir.foreach("Animations"){|fb|
    f = "Animations/"+fb
    if safeIsDirectory?(f) && fb != "." && fb != ".."
      animationFolders.push(f)
    end
  }
end
if animationFolders.length == 0
  p "No animations to import."
else
  animations = tryLoadData("Data/PkmnAnimations.rxdata")
  animations = PBAnimations.new if !animations
  for folder in animationFolders
    p folder
    audios = []
    files = Dir.glob(folder + "/*.*")
    %w( wav ogg mid wma mp3 ).each{|ext|
      upext = ext.upcase
      audios.concat(files.find_all{|f| f[f.length-3,3]==ext})
      audios.concat(files.find_all{|f| f[f.length-3,3]==upext})
    }
    for audio in audios
      pbSafeCopyFile(audio,RTP.getAudioPath("Audio/SE/"+File.basename(audio)),"Audio/SE/"+File.basename(audio))
    end
    images = []
    %w( png jpg bmp gif ).each{|ext|
       upext=ext.upcase
       images.concat(files.find_all{|f| f[f.length-3,3]==ext})
       images.concat(files.find_all{|f| f[f.length-3,3]==upext})
    }
    for image in images
      pbSafeCopyFile(image,RTP.getImagePath("Graphics/Animations/"+File.basename(image)),"Graphics/Animations/"+File.basename(image))
    end
    anms = Dir[folder + "/*.anm"]
    for anm in anms
      if anm != nil
        textdata=loadBase64Anim(File.read(anm))
        if textdata != nil
          index=pbAllocateAnimation(animations,textdata.name)
          if textdata.name==""
            textdata.name = File.basename(folder)
          end
          textdata.id = -1
          pbConvertAnimToNewFormat(textdata)
          animations[index]=textdata
        end
      end
    end
  end
File.open("Data/PkmnAnimations.rxdata", "wb") { |f|
  Marshal.dump(animations, f)
}
p "All animations were imported."
STDOUT.flush
end
