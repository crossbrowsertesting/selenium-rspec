** Selenium Testing with CBT and RSpec

[RSpec](http://rspec.info/) provides an awesome tool for writing and executable examples of how your code should behave. This makes it perfect for writing [Selenium](http://www.seleniumhq.org/) tests in Ruby, and because Ruby works well with our Cloud Service out of the box, we'll show you to do the same with RSpec. We'll start by getting a few necessary dependecies:

First let's get RSpec intsalled. Its easiest to do so with [Gem](https://rubygems.org/):

```
gem install rspec
```

We'll also need Selenium:

```
gem install selenium-webdriver
```

Lastly, we'll need [Request-Client](https://github.com/rest-client/rest-client) so we can make RESTful calls to our API:

```
gem install request-client
```

Now we're ready to get started. From your terminal, navigate to a new directory where we can start writing our tests. From there, create a file called "cbt.rb". This will allow us to create the environment for testing to CBT configurations. Copy to following code into that file:

```
require "selenium-webdriver"
require "rspec"
require "rest-client"
require "io/console"

RSpec.configure do |config|
	config.around(:example) do |example|
		username = 'you%40yourdomain.com'					# change this to the username associated with your account
		authkey = 'yourauthkey'								# change this to the authkey found in the Manage Account section of our site

		caps = Selenium::WebDriver::Remote::Capabilities.new

		caps["name"] = "Login Form Example"
		caps["build"] = "1.0"
		caps["browser_api_name"] = "Chrome54x64"
		caps["os_api_name"] = "Win10"
		caps["screen_resolution"] = "1024x768"
		caps["record_video"] = "true"
		caps["record_network"] = "true"

		puts "Starting tunnel..."
		
		# uncomment the following to make your test start a tunnel

		=begin
			tunnel = IO.popen("cbt_tunnels --username " + username + " --authkey " + authkey + "asadmin", "r+")
		rescue Exception => ex
			puts "#{ex.class}: #{ex.message}"
		=end

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

			# uncomment the following if you've chosen to start a tunnel
			=begin
				tunnel.close
			rescue Exception => ex
				puts "#{ex.class}: #{ex.message}"
			=end
		end
	end
end

```

As you can see from the code, we've used Selenium to create a Remot WebDriver that's pointed to our hub and uses your username and authorization key. This will start a test to Chrome 54 on Windows 10. Our capabilities also allow you to record videos of your test and record network traffic. If you uncomment the lines where we instantiate a tunnel you can also start a local connection so you can test locally hosted content. Just ensure you've install cbt_tunnels beforehand. We're not done yet, now we need to write our first test in RSpec. Luckally we can now extend all of our tests from this same context to test in the cloud. Create another file called "todo_example.rb" and copy the following code to see RSpec in action:

```
require_relative "./cbt"

describe "Todo Example" do 
	it "can test a todo-app" do
		# maximize the browser window
		@driver.manage.window.maximize
        puts "Loading URL"
        @driver.navigate.to("http://crossbrowsertesting.github.io/todo-app.html")

        puts "Clicking Checkbox"
        @driver.find_element(:name, "todo-4").click
        puts "Clicking Checkbox"
	    @driver.find_element(:name, "todo-5").click

        elems = @driver.find_elements(:class, "done-true")
        expect(elems.length).to eq(2)
        
        puts "Entering Text"
        @driver.find_element(:id, "todotext").send_keys("Run your first Selenium Test")
        @driver.find_element(:id, "addbutton").click

        spanText = @driver.find_element(:xpath, "/html/body/div/div/div/ul/li[6]/span").text
        expect(spanText).to eql("Run your first Selenium Test")

        puts "Archiving old to-dos"
        @driver.find_element(:link_text, "archive").click
        elems = @driver.find_elements(:class, "done-false")
        expect(elems.length).to eq(4)

        @score = "pass"
	end
end
```

You might not be able to tell what this is doing until we run it, so let's go ahead and do that. Save this file, and return to that directory in your terminal:

```
rspec todo_example.rb
```

Go over to our app, and see it working. You should see where we're testing a basic Angular To-Do-App. Selenium will checkmark boxes, add to the list, and even check that our archive link works. Its simple, but its meant to show you the basics of how Selenium can work with functional testing for your own web applications. At the end we set the score to pass (if we made it through without issues), so you know which test cases you need to look for. 

That's just the start of what you can do with Selenium! There's really so much more you can do, and RSpec makes it easy to set up and perform your tests on the fly. If you have any questions or concerns as you use our service, don't hesitate to [get in touch](mailto: info@crossbrowsertesting.com). We're always happy to help!