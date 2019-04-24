require_relative 'spec_helper'
require 'api_cache'

describe 'cache time is not set' do
  before(:all) do
    ENV['INSPEC_CACHE_TIME'] = ''
    ENV['INSPEC_CACHE_DIR'] = Dir.tmpdir + '/' + (0...8).map { (65 + rand(26)).chr }.join
    @cache = RequestCache.new
  end
  it 'setup cache dir does not exist and read/write are ignored' do
    expect(File).not_to exist(ENV['INSPEC_CACHE_DIR'])
    expect(@cache.write_cache('ID', 'X')).to eq(false)
    expect(@cache.get_cache('ID')).to eq(false)
  end
end

describe 'cache time is bigger then 0' do
  let(:content) { { 'CONTENT' => true } }
  before(:all) do
    ENV['INSPEC_CACHE_TIME'] = '10'
    ENV['INSPEC_CACHE_DIR'] = Dir.mktmpdir
    @cache = RequestCache.new
  end
  it 'Setup cache dir exist and read and write are successful' do
    expect(File).to exist(ENV['INSPEC_CACHE_DIR'])
    expect(@cache.write_cache('ID', '{"CONTENT": true}')).to eq(true)
    expect(@cache.get_cache('ID')).to eq(content)
  end
  after(:all) do
    FileUtils.remove_dir(ENV['INSPEC_CACHE_DIR'], true)
  end
end

describe 'id should be unqiue' do
  before(:all) do
    @cache = RequestCache.new
    @a = @cache.encode('A', 'B', 'C' => 1)
    @b = @cache.encode('A', 'x', 'C' => 1)
    @cv = @cache.encode('A', 'B', 'C' => 'x')
    @ck = @cache.encode('A', 'B', 'x' => 1)
    @a_duplicate = @cache.encode('A', 'B', 'C' => 1)
  end
  it 'does not match' do
    expect(@a).not_to eq(@b)
    expect(@a).not_to eq(@cv)
    expect(@a).not_to eq(@ck)
    expect(@b).not_to eq(@cv)
    expect(@b).not_to eq(@ck)
    expect(@cv).not_to eq(@ck)
  end
  it 'matchs' do
    expect(@a).to eq(@a_duplicate)
  end
end
