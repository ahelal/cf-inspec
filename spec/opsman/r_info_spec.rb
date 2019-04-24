require_relative '../spec_helper'
require 'inspec'
require 'opsman/opsman'

describe 'opsman info resource' do
  it 'returns version' do
    ENV['OM_TARGET'] = 'Set'
    allow_any_instance_of(Opsman).to receive(:get).and_return('info' => {
                                                                'version' => 'v2.1-build.79'
                                                              })
    allow_any_instance_of(Opsman).to receive(:auth).and_return(false)
    ominfo = OmInfo.new
    expect(ominfo.version).to eq 'v2.1-build.79'
  end
end
