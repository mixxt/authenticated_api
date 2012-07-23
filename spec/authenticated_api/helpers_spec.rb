require 'spec_helper'

describe "AuthenticatedApi::Helpers" do
  
  it "should strip the new line character on a Base64 encoding" do
    AuthenticatedApi.b64_encode("some string").should_not match(/\n/)
  end
  
  it "should properly upcase a hash's keys" do
    hsh = { "JoE" => "rOOLz" }
    AuthenticatedApi.capitalize_keys(hsh)["JOE"].should == "rOOLz"
  end
  
end