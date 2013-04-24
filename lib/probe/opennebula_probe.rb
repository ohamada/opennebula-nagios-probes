require 'nagios-probe'

class OpennebulaProbe < Nagios::Probe

  CRIT_MSG = 'Failed to establish connection with the remote server'
  WARN_MSG = 'Failed to query specified remote resources'
  OK_MSG = 'Remote resources successfully queried'

  def initialize(opts)
    super(opts)

    @endpoint = "#{@opts.protocol.to_s}://#{@opts.hostname}:#{@opts.port.to_s}#{@opts.path}"
  end

  def crit_message
    CRIT_MSG
  end

  def warn_message
    WARN_MSG
  end

  def ok_message
    OK_MSG
  end
end
