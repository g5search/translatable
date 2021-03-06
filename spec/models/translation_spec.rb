require 'spec_helper'

describe Translation do
  before(:each) do
    Translation.send(:store).flushdb
  end

  describe "formatted key" do
    it "should properly format key with locale" do
      Translation.send(:formatted_key, "en-US", "taco").should == 'en-US.taco'
    end
  end

  describe "value getter" do
    it "should remove surrounding double quotes" do
      Translation.new(:value => "\"value\"").value.should == 'value'
      Translation.new(:value => "value\"").value.should == 'value'
      Translation.new(:value => "\"value").value.should == 'value'
    end
  end

  describe "validations" do
    before(:each) do
      Translation.reload!
      @translation = Translation.new
      @translation.valid?
    end

    it "should require locale with min length of 2" do
      @translation.errors[:locale].should =~ ["is too short (minimum is 2 characters)"]

      @translation.locale = 'a'
      @translation.valid?

      @translation.errors[:locale].should eql ["is too short (minimum is 2 characters)"]
    end

    it "sould require key with minimum length of 1" do
      @translation.errors[:key].should =~ ["is too short (minimum is 1 characters)"]

      @translation.key = ''
      @translation.valid?
      @translation.errors[:key].should =~ ["is too short (minimum is 1 characters)"]
    end
  end

  describe "destroy" do
    before(:each) do
      @translation = Translation.new(:locale => 'el', :key => 'loco', :value => 'bolo')
      @translation.save.should be_true

      Translation.find(:locale => 'el', :key => 'loco').should_not be_nil
    end

    it "should destroy translation" do
      @translation.destroy
      
      Translation.find(:locale => 'el', :key => 'loco').should be_nil
    end
  end

  describe "save" do
    it "should save if valid" do
      Translation.new(:locale => 'el', :key => 'loco', :value => 'bolo').save.should be_true
      found = Translation.find(:locale => 'el', :key => 'loco')

      found.key.should == 'loco'
      found.value.should == 'bolo'
      found.locale.should == 'el'
    end

    it "should not save if invalid" do
      Translation.new(:locale => 'rio').save.should be_false
    end
  end

  describe "locales" do
    before(:each) do
      Translation.new(:locale => 'en-US', :key => 'jimmy', :value => 'joe').save
      Translation.new(:locale => 'en-US', :key => 'jimmy', :value => 'jack').save
      Translation.new(:locale => 'xx-YY', :key => 'jimmy', :value => 'joe').save
      Translation.new(:locale => 'xx-YY', :key => 'timmy', :value => 'joe').save
      Translation.new(:locale => 'ss-SS', :key => 'jimmy', :value => 'joe').save
      Translation.new(:locale => 'aa-AA', :key => 'jimmy', :value => 'joe').save
      Translation.new(:locale => 'en-US', :key => 'jimmy', :value => 'joe').save
    end

    specify { Translation.locales.should == ['aa-AA', 'en-US', 'ss-SS', 'xx-YY']}
  end

  describe "create and read" do
    it "should create and read translation by locale" do
      Translation.new(:locale => 'en-US', :key => 'foo', :value => 'bar').save
      Translation.send(:store)['en-US.foo'].should == 'bar'
      Translation.locale_value('en-US', 'foo').should == 'bar'
      Translation.locale_value('es-ES', 'foo').should be_nil
    end

    it "should include all key values" do
      Translation.new(:locale => 'en-US', :key => 'jimmy', :value => 'joe').save
      Translation.new(:locale => 'en-US', :key => 'timmy', :value => 'toe').save

      Translation.available_keys('en-US').include?('jimmy').should be_true
      Translation.available_keys('en-US').include?('timmy').should be_true
      Translation.available_keys('en-US').include?('not exists').should be_false

      Translation.find(:locale => 'en-US').first.locale.should == 'en-US'
      Translation.find(:locale =>'en-US').first.key.should == 'jimmy'
      Translation.find(:locale =>'en-US').first.value.should == 'joe'

      Translation.find(:locale =>'en-US').last.locale.should == 'en-US'
      Translation.find(:locale =>'en-US').last.key.should == 'timmy'
      Translation.find(:locale =>'en-US').last.value.should == 'toe'
    end

    it "should filter_by" do
      Translation.new(:locale => 'en-US', :key => 'nokey2', :value => 'bar').save
      Translation.new(:locale => 'en-US', :key => 'baz', :value => '1').save
      Translation.new(:locale => 'en-US', :key => 'bim.baz', :value => '2').save
      Translation.new(:locale => 'en-US', :key => 'baz.bo', :value => '3').save
      Translation.new(:locale => 'en-US', :key => 'nokey', :value => 'bar').save

      Translation.find(:locale => 'en-US', :filter_by => 'baz').collect(&:value).should == ['1', '3', '2']
    end
  end

  describe "reload!" do
    it "should flush and load the translations" do
      Translation.available_keys('en-US').should be_empty
      Translation.new(:locale => 'en-US', :key => 'timmy', :value => 'joe').save
      Translation.available_keys('en-US').count.should == 1

      Translation.reload!
      Translation.available_keys('en-US').should be_empty
    end
  end
end
