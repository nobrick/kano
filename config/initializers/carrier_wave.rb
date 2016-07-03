module CarrierWave
  module MiniMagick
    # Check for images that are larger than you probably want in case of denial
    # of service by pixel flood attack.

    def validate_dimensions
      manipulate! do |img|
        if img.dimensions.any? { |i| i > 8000 }
          raise CarrierWave::ProcessingError, 'dimensions too large'
        end
        img
      end
    end
  end
end
