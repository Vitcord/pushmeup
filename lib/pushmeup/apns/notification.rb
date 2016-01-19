module APNS
  class Notification
    attr_accessor :device_token, :alert, :category, :badge, :sound, :other, :silent

    def initialize(device_token, message, silent = false)
      self.device_token = device_token
      if message.is_a?(Hash)
        self.alert = message[:alert]
        self.category = message[:category]
        self.badge = message[:badge]
        self.sound = message[:sound]
        self.other = message[:other]
        self.silent = silent
      elsif message.is_a?(String)
        self.alert = message
      else
        raise "Notification needs to have either a Hash or String"
      end
    end

    def packaged_notification
      pt = self.packaged_token
      pm = self.packaged_message
      [0, 0, 32, pt, 0, pm.bytesize, pm].pack("ccca*cca*")
    end

    def packaged_token
      [device_token.gsub(/[\s|<|>]/,'')].pack('H*')
    end

    def packaged_message
      aps = {'aps'=> {} }
      aps['aps']['alert'] = self.alert if self.alert
      aps['aps']['category'] = self.category if self.category
      aps['aps']['badge'] = self.badge if self.badge
      aps['aps']['sound'] = self.sound if self.sound
      aps['aps']['content-available'] = 1 if self.silent
      aps.merge!(self.other) if self.other
      aps.to_json.gsub(/\\u([\da-fA-F]{4})/) {|m| [$1].pack("H*").unpack("n*").pack("U*")}
    end

    def ==(that)
      device_token == that.device_token &&
      alert == that.alert &&
      category == that.category &&
      badge == that.badge &&
      sound == that.sound &&
      other == that.other &&
      silent == that.silent
    end

  end
end
