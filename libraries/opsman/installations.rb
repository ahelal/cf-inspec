=begin
 name: om_installations
 desc: |
         histroy of apply changes in opsman.
 api:
   - https://docs.pivotal.io/pivotalcf/2-4/opsman-api/#getting-a-list-of-recent-install-events

 methods:
     - status_of_last_run: status of last run
     - status_of_last_completed_run: status of last completed run
     - duration_of_last_completed_run: duration in seconds of last completed run
     - last_run: raw format of last run
     - last_completed_run: raw format of completed last run
     - raw_attribute: contains the raw api response.

 example: |
    describe om_installations do
      its('status_of_last_run') { should eq 'succeeded' }
      its('status_of_last_completed_run') { should eq 'succeeded' }
      its('duration_of_last_completed_run') { should be < 60 * 60 }
    end
=end

class OmInstallation < Inspec.resource(1)
  name 'om_installations'

  def initialize
    @opsman = Opsman.new
    @installations = raw_content
  rescue => e
    raise Inspec::Exceptions::ResourceSkipped, "OM API error: #{e}"
  end

  def status_of_last_run
    last_run['status']
  end

  def status_of_last_completed_run
    last_completed_run['status']
  end

  def duration_of_last_completed_run
    run = last_completed_run
    start = DateTime.parse(run['started_at'])
    stop = DateTime.parse(run['finished_at'])
    ((stop - start) * 24 * 60).to_i
  end

  def last_run
    @installations[0]
  end

  def last_completed_run
    @installations.each do |installation|
      return installation if %w[succeeded failed].include? installation['status']
    end
  end

  def raw_content
    obj = @opsman.get('/api/v0/installations')
    raise 'Opsman has no installations.' if obj['installations'].empty?
    obj['installations']
  end
end
