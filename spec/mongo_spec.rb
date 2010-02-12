require File.dirname(__FILE__) + '/spec_helper.rb'
require 'rubygems'
require 'mongo'

# Time to add your specs!
# http://rspec.info/
describe "MongoDB" do

  before :all do
    @db = Mongo::Connection.new.db("mongoship")
    @shipments = @db.collection("shipments")
    @shipments.remove
  end
  
  it "contact mongo" do
    @db.should_not be_nil
  end

  it "gets a collection" do
    @shipments.should respond_to :insert
  end
  
  it "can insert some record" do
    @shipments.insert(:date => Time.now).class.should == Mongo::ObjectID
  end

  it "can insert as shipmenet-like record" do
    @shipments.insert(:date => Time.now,
      :num => 1,
      :shipping_lines => [
        {
          :item_id => 1,
          :qty => 1,
          :price => 10.00
        }
      ],
      :package => [
        {
          :type => :crate,
          :tracking_number => "tracking",
          :pkg_lines => [
            {
              :item_id => 1,
              :qty => 1
            }
          ]
        }
      ]).class.should == Mongo::ObjectID
  end
  
  it "finds something" do
    @shipments.find_one.class == Mongo::ObjectID
  end
  
  it "retrieves the shipment" do
    @shipments.find_one(:num => 1).class == Mongo::ObjectID
  end

  it "retrieves the shipment data" do
    ship = @shipments.find_one(:num => 1)
    ship["_id"].class.should == Mongo::ObjectID
    ship["package"].first["tracking_number"].should == "tracking"
  end

  it "queries by internal property" do
    ship = @shipments.find({"package" => {"$elemMatch" => {"tracking_number" => "tracking"}}}).first
    ship["_id"].class.should == Mongo::ObjectID
    ship["package"].first["tracking_number"].should == "tracking"
  end
end
