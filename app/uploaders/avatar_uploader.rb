# encoding: utf-8

class AvatarUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  storage :file
  process :validate_dimensions
  process :crop
  process resize_and_pad: [ 256, 256, :transparent ]

  version :thumb do
    process resize_and_pad: [ 64, 64, :transparent]
  end

  def default_url
    name = [ version_name, 'default.png' ].compact.join('_')
    "/images/avatar_fallback/" + name
  end

  def extension_white_list
    %w(jpg jpeg png)
  end

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def filename
    "#{secure_token}.#{file.extension}" if original_filename.present?
  end

  protected

  def crop(crop_data = model.avatar_crop_data)
    return if crop_data.blank?
    manipulate! do |img|
      x = crop_data[:x]
      y = crop_data[:y]
      w = crop_data[:width]
      h = crop_data[:height]
      img.crop("#{w}x#{h}+#{x}+#{y}")
      img
    end
  end

  def secure_token
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) ||
      model.instance_variable_set(var, SecureRandom.uuid)
  end
end
