require_relative "./cbt"

describe "Test Login Example" do 
	it "can login with valid credentials" do
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

        "Archiving old to-dos"
        @driver.find_element(:link_text, "archive").click
        elems = @driver.find_elements(:class, "done-false")
        expect(elems.length).to eq(4)

        @score = "pass"
	end
end