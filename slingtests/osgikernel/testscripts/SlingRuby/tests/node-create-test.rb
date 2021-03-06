#!/usr/bin/env ruby

require 'sling/sling'
require 'sling/test'
require 'test/unit/ui/console/testrunner.rb'
include SlingInterface
include SlingUsers
include SlingSites

class TC_NodeCreateTest < SlingTest

  def test_create_node
    puts("test_create_node---------------------------------------------------START")
    testpath = "test/path"
    create_node(testpath, "a" => "foo", "b" => "bar")
    props = @s.get_node_props(testpath)
    assert_equal("foo", props["a"], "Expected property to be set")
    assert_equal("bar", props["b"], "Expected property to be set")
    puts("test_create_node---------------------------------------------------END")
  end

  def test_create_file_node
    puts("test_create_file_node----------------------------------------------START")
    filedata = "<html><head><title>fish</title></head><body><p>cat</p></body></html>"
    filepath = "test/filepath"
    create_file_node(filepath, "file", filedata)
    res = @s.execute_get(@s.url_for(filepath + "/file"))
    assert_equal(200, res.code.to_i, "Expected GET to succeed")
    assert_equal(filedata, res.body, "Expected body back unmodified")
    puts("test_create_file_node----------------------------------------------END")
  end

  def test_create_file_node_and_version
    puts("test_create_file_node_and_version----------------------------------START")
    filedata = "<html><head><title>fish</title></head><body><p>cat</p></body></html>"
    filepath = "test/filepath"
    create_file_node(filepath, "file", filedata)
    res = @s.execute_get(@s.url_for(filepath + "/file"))
    assert_equal(200, res.code.to_i, "Expected GET to succeed")
    assert_equal(filedata, res.body, "Expected body back unmodified")
	puts("Attempting version operation ")
    res = @s.execute_post(@s.url_for(filepath + "/file.save.html"), "dummy")
    assert_equal(200, res.code.to_i, "Expected POST to save to succeed, looks like versioning is not working check the logs. "+res.body)
	puts(res.body)
	
	puts("Attempting To List Versions ")
    res = @s.execute_get(@s.url_for(filepath + "/file.versions.json"), "dummy")
    assert_equal(200, res.code.to_i, "Expected GET to versions to succeed, looks like versioning is not working check the logs. "+res.body)
	puts(res.body)
	
    filedata = "<html><head><title>fishfingers</title></head><body><p>cat</p></body></html>"
    filepath = "test/filepath"
    create_file_node(filepath, "file", filedata)
    res = @s.execute_get(@s.url_for(filepath + "/file"))
    assert_equal(200, res.code.to_i, "Expected GET to of second version succeed")
    assert_equal(filedata, res.body, "Expected body back unmodified")
    res = @s.execute_get(@s.url_for(filepath + "/file.versions.json"), "dummy")
    assert_equal(200, res.code.to_i, "Expected GET to versions to succeed, looks like versioning is not working check the logs. "+res.body)
	puts(res.body)
    puts("test_create_file_node_and_version----------------------------------END")
  end
  
  def test_create_file_node_and_get_version_history
    puts("test_create_file_node_and_get_version_history----------------------START")
    filedata = "<html><head><title>fish</title></head><body><p>cat</p></body></html>"
    filepath = "test/filepath"
    create_file_node(filepath, "file", filedata)
    res = @s.execute_get(@s.url_for(filepath + "/file"))
    assert_equal(200, res.code.to_i, "Expected GET to succeed")
    assert_equal(filedata, res.body, "Expected body back unmodified")
	puts("Attempting version history operation ")
    res = @s.execute_get(@s.url_for(filepath + "/file.versions.json"), "dummy")
    assert_equal(200, res.code.to_i, "Expected GET to versions to succeed, looks like versioning is not working check the logs. "+res.body)
    puts("test_create_file_node_and_get_version_history----------------------END")
  end

  def test_create_node_and_get_version_history
    puts("test_create_node_and_get_version_history---------------------------START")
    m = Time.now.to_i.to_s
    version_content = { "jcr:rootVersion" => nil }
	nodepath = "test/nodepath/node" + m
    res = @s.execute_post(@s.url_for(nodepath), "testproperty" => "version1" )
    assert_equal(201, res.code.to_i, "Expected POST on create to suceed: "+res.body)
    res = @s.execute_get(@s.url_for(nodepath+".json"))
    assert_equal(200, res.code.to_i, "Expected GET to succeed "+res.body )
	puts("Attempting version history operation ")
    res = @s.execute_get(@s.url_for(nodepath +  ".versions.json"))
    assert_equal(200, res.code.to_i, "Expected GET to versions to succeed, looks like versioning is not working check the logs. "+res.body)
    res = @s.execute_post(@s.url_for(nodepath + ".save.html"))
    assert_equal(200, res.code.to_i, "Expected POST to save to succeed, looks like versioning is not working check the logs. "+res.body)
    version_content[JSON.parse(res.body)["versionName"]] = "version1"
    res = @s.execute_post(@s.url_for(nodepath), "testproperty" => "version2" )
    assert_equal(200, res.code.to_i, "Expected POST on create to suceed: "+res.body)
	res = @s.execute_post(@s.url_for(nodepath + ".save.html"))
    assert_equal(200, res.code.to_i, "Expected POST to save to succeed, looks like versioning is not working check the logs. "+res.body)
    version_content[JSON.parse(res.body)["versionName"]] = "version2"
   res = @s.execute_post(@s.url_for(nodepath), "testproperty" => "version3" )
    assert_equal(200, res.code.to_i, "Expected POST on create to suceed: "+res.body)

    res = @s.execute_get(@s.url_for(nodepath+".json"))
    assert_equal(200, res.code.to_i, "Expected GET to succeed "+res.body )
    res = @s.execute_get(@s.url_for(nodepath +  ".versions.json"), "dummy")
    assert_equal(200, res.code.to_i, "Expected GET to versions to succeed, looks like versioning is not working check the logs. "+res.body)
	puts(res.body)
	history = JSON.parse(res.body)
	assert_equal(3,history['total'],"Was expecting total 3 ")
	assert_equal(3,history['items'],"Was expecting 3 items in response")
	versions = history['versions']
	assert_equal(3,versions.length,"Was expecting 3 versions")
	versions.each_key do |versionName|
	  puts("loading Version "+versionName)
      res = @s.execute_get(@s.url_for(nodepath +  ".version.,"+versionName+",.json"), "dummy")
      assert_equal(200, res.code.to_i, "Expected GET to version "+versionName+" to succeed, looks like versioning is not working check the logs. "+res.body)
      content = JSON.parse(res.body)
      assert(version_content.has_key?(versionName), "Expected version to be expected")  
      assert_equal(version_content[versionName], content["testproperty"], "Expected version content to have been frozen. Looks like versioning is not working. Check the logs")
    end
	
    puts("test_create_node_and_get_version_history---------------------------END")
  end

end

Test::Unit::UI::Console::TestRunner.run(TC_NodeCreateTest)

