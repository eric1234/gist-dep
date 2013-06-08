# A database object that can be used like a hash
class DbConfig < ActiveRecord::Base

  # Works somewhat like find_by_key but returns the value of the config
  # instead of the entire config object
  def self.[](key)
    find_by_key(key).try :value
  end

  # If the key already exists will update the value. Otherwise will
  # create the value. If the value given is nil then will delete
  # the object (if it exists)
  def self.[]=(key, value)
    if value.nil?
      find_by_key(key).try :destroy
    else
      config = find_or_initialize_by_key key
      config.value = value
      config.save!
    end
  end

end