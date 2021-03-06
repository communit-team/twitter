require 'cgi'
require 'twitter/enumerable'
require 'twitter/rest/request'
require 'twitter/utils'
require 'uri'

module Twitter
  class PremiumSearchCounts
    include Twitter::Enumerable
    include Twitter::Utils
    # @return [Hash]
    attr_reader :attrs, :rate_limit, :entries, :total_count
    alias to_h attrs
    alias to_hash to_h

    # Initializes a new PremiumSearchCounts object
    #
    # @param request [Twitter::REST::Request]
    # @return [Twitter::PremiumSearchCounts]
    def initialize(request)
      @client = request.client
      @request_method = request.verb
      @path = request.path
      @options = request.options
      @collection = []
      self.attrs = request.perform
    end

    def entries
      @collection
    end

    def total_count
      self.attrs[:totalCount]
    end

    private

    # @return [Boolean]
    def last?
      !next_page?
    end

    # @return [Boolean]
    def next_page?
      !!@attrs[:next]
    end

    # Returns a Hash of query parameters for the next result in the search
    #
    # @note Returned Hash can be merged into the previous search options list to easily access the next page.
    # @return [Hash] The parameters needed to fetch the next page.
    def next_page
      {next: @attrs[:next]} if next_page?
    end

    # @return [Hash]
    def fetch_next_page
      @options[:request_body] = :json if @request_method == :json_post
      response = Twitter::REST::Request.new(@client, @request_method, @path, @options.merge(next_page)).perform
      self.attrs = response
    end

    # @param attrs [Hash]
    # @return [Hash]
    def attrs=(attrs)
      @attrs = attrs
      @attrs.fetch(:results, []).collect do |data_volume|
        @collection << DataVolume.new(data_volume)
      end
      @attrs
    end
  end
end