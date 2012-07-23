require 'spec_helper'

describe AuthenticatedApi do
  
  describe "generating secret keys" do
  
    it { should respond_to :generate_secret_key }
  
    it "should generate secret keys that are 89 characters" do
      subject.generate_secret_key.size.should be(89)
    end

    it "should generate keys that have a Hamming Distance of at least 65" do
      key1 = subject.generate_secret_key
      key2 = subject.generate_secret_key
      Amatch::Hamming.new(key1).match(key2).should be > 65
    end
    
  end
  
end
