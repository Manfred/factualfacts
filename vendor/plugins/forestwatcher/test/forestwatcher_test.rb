require 'rubygems' rescue LoadError

require 'test/unit'
require 'mocha'

require File.dirname(__FILE__) + '/../lib/forestwatcher'
require File.dirname(__FILE__) + '/receptor'

class MockHTTP
  attr_accessor :request
  attr_accessor :code
  
  def start
    yield self
  end
  
  def request(request=nil)
    unless request.nil?
      @request = request
      self
    else
      @request
    end
  end
end

class Test::Unit::TestCase
  # We define this here, so we can test that the supers implementation of rescue_action_in_public is called.
  def rescue_action_in_public(exception)
    @super_rescue_action_in_public_called ||= 0
    @super_rescue_action_in_public_called += 1
  end
end

class ForestwatcherTest < Test::Unit::TestCase
  ENVIRONMENT = {"SERVER_NAME" => "example.com", "HTTP_REFERER"=>"/posts", "PATH_INFO"=>"/posts/12", "HTTP_ACCEPT_ENCODING"=>"gzip,deflate", "HTTP_USER_AGENT"=>"Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)", "HTTP_FROM"=>"googlebot(at)googlebot.com", "SCRIPT_NAME"=>"/", "SERVER_PROTOCOL"=>"HTTP/1.1", "HTTP_HOST"=>"example.com", "REMOTE_ADDR"=>"127.0.0.1", "SERVER_SOFTWARE"=>"Mongrel 1.1.1", "REQUEST_PATH"=>"/posts/12", "HTTP_VERSION"=>"HTTP/1.0", "REQUEST_URI"=>"/posts/12", "SERVER_PORT"=>"80", "GATEWAY_INTERFACE"=>"CGI/1.2", "HTTP_ACCEPT"=>"*/*", "HTTP_X_FORWARDED_FOR"=>"6.2.2.1", "HTTP_CONNECTION"=>"close", "HTTP_X_REAL_IP"=>"6.2.2.1", "REQUEST_METHOD"=>"GET"}
  PARAMS = {"action"=>"show", "controller"=>"posts", "id"=>"12"}
  
  include ForestWatcher
  
  def setup
    @mock_http = MockHTTP.new
    @mock_http.code = '200'
    Net::HTTP.stubs(:new).returns(@mock_http)
  end
  
  def test_post_exception_with_full_options
    post_exception :url => 'http://test.host/myapp', :exception => exception, :params => PARAMS, :environment => ENVIRONMENT
    
    assert logger.messages.empty?
    body = @mock_http.request.body
    
    assert_match %r{Domain     : example.com}, body
    assert_match %r{Path       : /posts/12}, body
    assert_match %r{Referer    : /posts}, body
    assert_match %r{User-agent : Mozilla/5.0}, body
    assert_match %r{Exception  : #<ArgumentError: Needs to work>}, body
    assert_match %r{Params     : \{"action"=>"show", "id"=>"12", "controller"=>"posts"\}}, body
  end
  
  def test_post_exception_without_options
    post_exception :url => 'http://test.host/myapp'
    assert logger.messages.empty?
    assert_equal '', @mock_http.request.body.strip
  end
  
  def test_post_exception_without_url
    post_exception
    assert_match %r{bad URI}, logger.messages.first.last
  end
  
  def test_render_error_template
    self.class.report_errors_to 'http://test.host/myapp'
    self.stubs(:request).returns(stub_everything('Request'))
    self.stubs(:params).returns(stub_everything('Params'))
    self.stubs(:post_exception)
    
    assert_equal nil, @super_rescue_action_in_public_called
    rescue_action_in_public(nil)
    assert_equal 1, @super_rescue_action_in_public_called
  end
  
  protected
  
  def logger
    Receptor.instance
  end
  
  def exception
    begin
      raise ArgumentError, "Needs to work"
    rescue ArgumentError => e
      return e
    end
  end
end
