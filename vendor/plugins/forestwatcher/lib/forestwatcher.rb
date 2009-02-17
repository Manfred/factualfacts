require 'net/http'
require 'net/https'

module ForestWatcher
  ENVIRONMENT_MAP = [
    ['Domain     ', 'HTTP_HOST', 'SERVER_NAME'],
    ['Path       ', 'PATH_INFO', 'REQUEST_PATH', 'REQUEST_URI'],
    ['Referer    ', 'HTTP_REFERER'],
    ['User-agent ', 'HTTP_USER_AGENT']
  ]
  
  def self.included(base) # :nodoc:
    base.extend ClassMethods
  end
  
  module ClassMethods
    # Makes sure <tt>post_exception</tt> is called every time <tt>rescue_action_in_public</tt> is invoked on the
    # controller.
    #
    # *<tt>url</tt>: The URL to post to
    # *<tt>options</tt>: For options see <tt>post_exception</tt>
    def report_errors_to(url, options={})
      define_method :rescue_action_in_public do |exception|
        post_exception options.merge(:environment => request.env, :exception => exception, :params => params, :url => url)
        super
      end
    end
  end
  
  # Posts details about an exception to a Forestwatcher website.
  # Options:
  #   *<tt>:exception</tt>: Exception instance, or a string
  #   *<tt>:params</tt>: Params from the request
  #   *<tt>:url</tt>: Url to post to. Remember that the name of the application is encoded in the
  #     url you want to post to.
  #   *<tt>:environment</tt>: A hash with all the environment keys
  #   *<tt>:username</tt>: Username if you want to use basic authentication
  #   *<tt>:password</tt>: Password if you want ot use basic authentication
  #
  # Example:
  #   post_exception :exception => e, :params => params, :url => 'http://example.com/myapp'
  #   post_exception :exception => e, :params => params, :url => 'http://example.com:3004/otherapp'
  def post_exception(options={})
    # Don't throw our own errors
    begin
      require 'net/http'
      require 'net/https'
      
      url = URI.parse options[:url]
      req = Net::HTTP::Post.new(url.path, 'Content-type' => 'text/plain; charset=utf-8')
      if options[:username] and options[:password]
        req.basic_auth options[:username], options[:password]
      end
      
      req.body = ''
      if options[:environment]
        ForestWatcher::ENVIRONMENT_MAP.each do |item|
          key = item[1..-1].find { |key| options[:environment][key] }
          req.body << "#{item[0]}: #{options[:environment][key]}\n" if key
        end
      end
      if options[:params]
        req.body << "Params     : #{options[:params].inspect}\n"
      end
      if options[:exception]
        req.body << "Exception  : #{options[:exception].inspect}\n"
      end
      if options[:environment]
        req.body << "\n--- Environment\n\n" unless req.body.empty?
        req.body << "#{options[:environment].inspect}\n"
      end
      if options[:exception].respond_to?(:backtrace)
        req.body << "\n--- Backtrace\n\n"
        req.body << options[:exception].backtrace.join("\n")
      end
      
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true if url.scheme == 'https'
      res = http.start { |http| http.request(req) }
      unless res.code == '200'
        logger.info "Failed to send error to: #{options[:url]} (#{res.inspect})"
      end
    rescue Exception => e
      logger.info "Failed to send error to: #{options[:url]} (#{e.message})"
    end
  end
end
