require 'spec_helper'

describe AuthenticatedApi::Server do

  let(:access_id) do
    Random.rand(1000)
  end
  let(:secret_key) do
    AuthenticatedApi.generate_secret_key
  end
  let(:headers) do
    {
        'Content-MD5' => "e59ff97941044f85df5297e1c302d260",
        'Content-Type' => "text/plain",
        'Date' => "Mon, 23 Jan 1984 03:29:56 GMT"
    }
  end
  let(:request) do
  end

  let(:signed_request) do
  end

  it "should accept signature of valid request"

end