# encoding: UTF-8
require 'httparty'

module Occi
# OCCI Resource class.
# ==== Options
# * connection - Object holding connection info.

  class Resource
    include HTTParty

    #format :xml
    headers = { "Content-Type" => 'text/xml', 'Accept' => 'application/xml'}
    #debug_output

    def initialize(connection)
      self.class.base_uri "#{connection.scheme.to_s}://#{connection.host}:#{connection.port}"
      # Nebula OCCI format
      self.class.basic_auth "#{connection.user}", Digest::SHA1.hexdigest(connection.password)
      # rOCCI format
      #self.class.basic_auth "#{connection.user}", "#{connection.password}"
    end

    # Callback invoked whenever a subclass is created. This method dynamically defines virtual @endpoint
    # attribute located in child instance, which contains backslash + name of inheriting class. It is used
    # for request building.
    def self.inherited(childclass)
      super(childclass)
      path = childclass.to_s.split('::').last.downcase
      childclass.send(:define_method, :endpoint) do
        "/#{path}"
      end
    end

    def entity(id)
      "#{endpoint}/#{id}"
    end

    # Returns the contents of the pool.
    # 200 OK: An XML representation of the pool in the http body.
    # This means query the point /network, /storage etc.
    def all
      begin
        r = self.class.get(endpoint)
      rescue => e
        raise e.class, "Could not initiate basic endpoint connectivity query, maybe HTTP/SSL server problem?"
      end

      raise HTTPResponseError, "Basic pool availibility request failed!" unless r.code.to_s == '200'
      r.body
    end

    # Returns the representation of specific resource identified by +id+.
    # 200 OK: An XML representation of the pool in the http body.
    def find(id)
      begin
        r = self.class.get(entity(id))
      rescue => e
        raise e.class, "Could not initiate specific resource query, maybe HTTP/SSL server problem?"
      end

      raise HTTPResponseError, "Specific resource request failed!" unless r.code.to_s == '200'
      r.body
    end

    # Request for the creation of an ER. An XML representation of a
    # VM without the ID element should be passed in the http body.
    # 201 Created: An XML representation of a ER of type COMPUTE with the ID.
    # TODO: not used yet
    #def create(body)
    #  @connection.post(path: endpoint, body: body)
    #end

    # Update request for a Compute identified by +compute_id+.
    # 202 Accepted : The update request is being process, polling required to confirm update.
    # TODO: not used yet
    #def update(id, body)
    #  #@connection.put(path: entity(id), body: body)
    #end

    # Deletes the Compute resource identified by +compute_id+.
    # 204 No Content : The Compute has been successfully deleted.
    # TODO: not used yet
    #def destroy(id)
    #  #@connection.delete(path: entity(id))
    #end
  end

  class HTTPResponseError < HTTParty::ResponseError
    # Returns the response of the last request
    # @return [Net::HTTPResponse] A subclass of Net::HTTPResponse, e.g.
    # Net::HTTPOK
    attr_reader :message

    # Instantiate an instance of ResponseError with a Net::HTTPResponse object
    # @param [Net::HTTPResponse]
    def initialize(m)
      super(m)
      @message = m
    end
  end
end
