
class RequestCache
  def initialize
    @cache_dir = ENV['INSPEC_CACHE_DIR'] || "#{ENV['HOME']}/.inspec_cache"
    @cache_time = ENV['INSPEC_CACHE_TIME'] || '0'
    @cache_enabled = @cache_time.to_i > 0
    cache_setup
  end

  def encode(_url, path, headers)
    k = headers.to_s
    Base64.encode64(@om_target.to_s + path + k)
  end

  def get_cache(id)
    return false unless @cache_enabled
    cache_file_path, cache_exist = check_cache_file(id)
    return false unless cache_exist
    diff_seconds = (Time.new - File.stat(cache_file_path).ctime).to_i
    return false if diff_seconds > @cache_time.to_i
    JSON.parse(File.open(cache_file_path).read)
  end

  def write_cache(id, contet)
    return false unless @cache_enabled
    cache_file_path = "#{@cache_dir}/#{id}.json"
    File.write(cache_file_path, contet)
    true
  end

  private

  def cache_setup
    return false unless @cache_enabled
    Dir.mkdir @cache_dir unless File.exist?(@cache_dir)
  end

  def check_cache_file(id)
    cache_file_path = "#{@cache_dir}/#{id}.json"
    [cache_file_path, File.file?(cache_file_path)]
  end
end
