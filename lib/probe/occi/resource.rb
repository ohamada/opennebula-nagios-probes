# encoding: UTF-8
module Occi
# OCCI Resource class.
# ==== Options
# * connection - Object holding connection info.

  class Resource
    def initialize(connection)
      @connection = connection
    end

    # Callback invoked whenever a subclass is created. This method dynamically defines virtual @endpoint
    # attribute located in child instance, which contains backslash + name of inheriting class. It is used
    # for request building.
    def self.inherited(base)
      path = base.to_s.split('::').last.downcase
      base.send(:define_method, :endpoint) do
        "/#{path}"
      end
    end

    def entity(id)
      "#{endpoint}/#{id}"
    end

    ##
    # Returns the contents of the pool.
    # 200 OK: An XML representation of the pool in the http body.
    def all
      @connection.get(path: endpoint)
    end

    ##
    # Request for the creation of an ER. An XML representation of a
    # VM without the ID element should be passed in the http body.
    # 201 Created: An XML representation of a ER of type COMPUTE with the ID.
    # TODO: not used yet
    def create(body)
      @connection.post(path: endpoint, body: body)
    end

    ##
    # Update request for a Compute identified by +compute_id+.
    # 202 Accepted : The update request is being process, polling required to confirm update.
    # TODO: not used yet
    def update(id, body)
      @connection.put(path: entity(id), body: body)
    end

    ##
    # Returns the representation of the Compute resource identified by +compute_id+.
    # 200 OK: An XML representation of the pool in the http body.
    def find(id)
      @result = @connection.get(path: entity(id))
    end

    ##
    # Deletes the Compute resource identified by +compute_id+.
    # 204 No Content : The Compute has been successfully deleted.
    # TODO: not used yet
    def destroy(id)
      @connection.delete(path: entity(id))
    end
  end
end
