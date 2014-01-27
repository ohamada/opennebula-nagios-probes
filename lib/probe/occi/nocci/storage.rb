# encoding: UTF-8
module Occi
# OCCI Storage class.

  class Storage < Resource
    def create(upload)
      @connection.post endpoint, upload: upload
    end
  end
end
