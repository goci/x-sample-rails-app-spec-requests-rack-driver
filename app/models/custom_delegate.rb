class CustomDelegate
  class << self
    def new(delegate_name)
      all_stubs = YAML.load(File.read(File.join(Rails.root, 'config', 'stubs.yml')))
      stubs = all_stubs[Rails.env]
      if stubs && stubs[delegate_name]  
        stubs[delegate_name].constantize
      else
        delegate_name.constantize
      end
    end
  end
end
