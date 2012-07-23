require 'spec_helper'

describe AuthenticatedApi::Signature do

  let(:signature) do
    signature = AuthenticatedApi::Signature.new('get', 'Example.com', '/', {'something' => 'value'})
  end

  it "stores method" do
    signature.method.should eq 'get'
  end
  it "stores host" do
    signature.host.should eq 'Example.com'
  end
  it "stores uri" do
    signature.uri.should eq '/'
  end
  it "stores params" do
    signature.params.should eq({'something' => 'value'})
  end
  it "builds canonicalized params" do
    signature.canonicalized_params.should eq 'something=value'
  end
  it "builds string to sign" do
    signature.string_to_sign.should eq "GET\nexample.com\n/something=value"
  end

end