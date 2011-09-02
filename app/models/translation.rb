class Translation
  include ActiveModel::Validations

  attr_accessor :locale, :key, :value

  validates :locale, :presence => true, :length => {:minimum => 2}
  validates :key, :presence => true, :length => {:minimum => 1}

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def value
    unless @value.blank?
      if @value.first == "\""
        val = @value[1..-1] 
      else
        val = @value
      end
      val = val[0..-2] if val.last == "\""
    end

    val || @value
  end

  def save
    if valid?
      Translation.send(:save, locale, key, value)
      true
    else
      false
    end
  end

  class << self
    def find(filter)
      locale = filter[:locale]

      return Translation.new(:locale => locale, :key => filter[:key], :value => locale_value(locale, filter[:key])) if filter[:key]

      Translation.available_keys(locale).sort.collect{|key|
        val = Translation.locale_value(locale, key)
        Translation.new(:locale => locale, :key => key, :value => val) if val
      }.compact
    end

    def locales
      store.keys.collect{|key| /([A-Za-z-]+)\./.match(key)[1]}.uniq.sort
    end

    def available_keys(locale)
      keys  = store.keys("#{locale}.*")
      range = Range.new(locale.size + 1, -1)
      keys.collect { |k| k.slice(range) }.sort!
    end

    def locale_value(locale, key)
      store[formatted_key(locale, key)]
    end

    private
    def store
      Translator.store
    end

    def formatted_key(locale, key)
      "#{locale}.#{key}"
    end

    def save(locale, key, value)
      store[formatted_key(locale, key)] = value
    end
  end
end
