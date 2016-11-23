require "selenium-webdriver"
require "rspec"
require "rest-client"
require "io/console"

RSpec.configure do |config|
	config.around(:example) do |example|
		username = 'you%40yourdomain.com'
		authkey = 'yourauthkey'

		caps = Selenium::WebDriver::Remote::Capabilities.new

		caps["name"] = "Login Form Example"
		caps["build"] = "1.0"
		caps["browser_api_name"] = "Chrome54x64"
		caps["os_api_name"] = "Win10"
		caps["screen_resolution"] = "1024x768"
		caps["record_video"] = "true"
		caps["record_network"] = "true"

		puts "Starting tunnel..."
		
		begin
			tunnel = IO.popen("cbt_tunnels --username " + username + " --authkey " + authkey + "asadmin", "r+")
		rescue Exception => ex
			puts "#{ex.class}: #{ex.message}"
		end

		@driver = Selenium::WebDriver.for(:remote,
			:url => "http://#{username}:#{authkey}@hub.crossbrowsertesting.com:80/wd/hub",
			:desired_capabilities => caps)
		@score = "fail"
		session_id = @driver.session_id

		begin
			example.run
		ensure
			response = RestClient.put("https://#{username}:#{authkey}@crossbrowsertesting.com/api/v3/selenium/#{session_id}", "action=set_score&score=#{@score}")
			@driver.quit
			begin
				tunnel.close
			rescue Exception => ex
				puts "#{ex.class}: #{ex.message}"
			end
		end
	end
end
